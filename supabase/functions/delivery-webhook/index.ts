import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { getCorsHeaders } from '../_shared/cors.ts'

/**
 * delivery-webhook: Handle delivery lifecycle events
 *
 * Triggered by Supabase database webhooks on deliveries table changes.
 * Handles: driver notification on assignment, customer notification on status changes,
 * shift stats updates on completion.
 *
 * Security: requires a shared secret header (x-webhook-secret) that must match
 * the WEBHOOK_SHARED_SECRET env var. This function uses the service role key
 * to bypass RLS, so it must not be callable by unauthenticated clients.
 */

interface WebhookPayload {
  type: 'INSERT' | 'UPDATE' | 'DELETE'
  table: string
  schema: string
  record: Record<string, any>
  old_record: Record<string, any> | null
}

Deno.serve(async (req) => {
  const corsHeaders = getCorsHeaders(req)

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Shared-secret authentication: reject any request that doesn't carry the
  // correct x-webhook-secret header. This MUST run before anything that uses
  // the service role key so the function cannot be invoked anonymously.
  const webhookSecret = Deno.env.get('WEBHOOK_SHARED_SECRET')
  const providedSecret = req.headers.get('x-webhook-secret')
  if (!webhookSecret || providedSecret !== webhookSecret) {
    return new Response(
      JSON.stringify({ code: 'UNAUTHORIZED', error: 'Unauthorized' }),
      { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

  if (!supabaseUrl || !supabaseKey) {
    return new Response(
      JSON.stringify({ code: 'SERVER_ERROR', message: 'Server configuration error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const supabase = createClient(supabaseUrl, supabaseKey)

  try {
    const payload: WebhookPayload = await req.json()
    const { type, record, old_record } = payload
    const actions: string[] = []

    // --- INSERT: New delivery created (assign to driver) ---
    if (type === 'INSERT' && record.driver_id && record.status === 'assigned') {
      // Notify driver about new assignment
      await notifyDriver(supabaseUrl, supabaseKey, webhookSecret, {
        delivery_id: record.id,
        driver_id: record.driver_id,
        type: 'new_delivery',
      })
      actions.push('notified_driver_new_assignment')
    }

    // --- UPDATE: Status changed ---
    if (type === 'UPDATE' && old_record && record.status !== old_record.status) {
      const newStatus = record.status
      const oldStatus = old_record.status

      // Driver assignment changed
      if (record.driver_id !== old_record.driver_id && record.driver_id) {
        await notifyDriver(supabaseUrl, supabaseKey, webhookSecret, {
          delivery_id: record.id,
          driver_id: record.driver_id,
          type: 'new_delivery',
        })
        actions.push('notified_new_driver')
      }

      // Notify customer on key status changes
      if (['picked_up', 'heading_to_customer', 'arrived_at_customer', 'delivered', 'failed'].includes(newStatus)) {
        const { data: order } = await supabase
          .from('orders')
          .select('customer_id')
          .eq('id', record.order_id)
          .single()

        if (order?.customer_id) {
          const { data: customer } = await supabase
            .from('users')
            .select('fcm_token')
            .eq('id', order.customer_id)
            .single()

          if (customer?.fcm_token) {
            const statusMessages: Record<string, { title: string; body: string }> = {
              'picked_up': { title: 'تم استلام طلبك', body: 'السائق استلم طلبك وفي الطريق إليك' },
              'heading_to_customer': { title: 'السائق في الطريق', body: 'السائق في طريقه إليك الآن' },
              'arrived_at_customer': { title: 'السائق وصل', body: 'السائق وصل لموقعك' },
              'delivered': { title: 'تم التوصيل', body: 'تم توصيل طلبك بنجاح' },
              'failed': { title: 'فشل التوصيل', body: 'لم يتم توصيل الطلب، تواصل مع الدعم' },
            }

            const msg = statusMessages[newStatus]
            if (msg) {
              await sendFcm(customer.fcm_token, msg.title, msg.body, {
                type: 'delivery_update',
                delivery_id: record.id,
                order_id: record.order_id,
                status: newStatus,
              })
              actions.push(`notified_customer_${newStatus}`)
            }
          }
        }
      }

      // Update shift stats on delivery completion
      if (newStatus === 'delivered') {
        const { data: activeShift } = await supabase
          .from('driver_shifts')
          .select('id, total_deliveries, total_earnings')
          .eq('driver_id', record.driver_id)
          .eq('status', 'active')
          .single()

        if (activeShift) {
          await supabase
            .from('driver_shifts')
            .update({
              total_deliveries: (activeShift.total_deliveries || 0) + 1,
              total_earnings: parseFloat(activeShift.total_earnings || '0') + parseFloat(record.delivery_fee || '0'),
            })
            .eq('id', activeShift.id)
          actions.push('updated_shift_stats')
        }
      }
    }

    return new Response(
      JSON.stringify({ success: true, actions, delivery_id: record.id }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Delivery webhook error:', error)
    return new Response(
      JSON.stringify({ code: 'SERVER_ERROR', message: 'Webhook processing failed' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// Helper: Call notify-driver function
async function notifyDriver(
  supabaseUrl: string,
  supabaseKey: string,
  webhookSecret: string,
  payload: { delivery_id: string; driver_id: string; type: string }
) {
  try {
    await fetch(`${supabaseUrl}/functions/v1/notify-driver`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${supabaseKey}`,
        'x-webhook-secret': webhookSecret,
      },
      body: JSON.stringify(payload),
    })
  } catch (e) {
    console.error('Failed to call notify-driver:', e)
  }
}

// Helper: Send FCM push notification
async function sendFcm(
  token: string,
  title: string,
  body: string,
  data: Record<string, string>
) {
  const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')
  if (!fcmServerKey) return

  try {
    await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `key=${fcmServerKey}`,
      },
      body: JSON.stringify({
        to: token,
        notification: { title, body, sound: 'default' },
        data,
        priority: 'high',
      })
    })
  } catch (e) {
    console.error('FCM send failed:', e)
  }
}
