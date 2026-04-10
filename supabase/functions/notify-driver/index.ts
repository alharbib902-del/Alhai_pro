import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { getCorsHeaders } from '../_shared/cors.ts'

/**
 * notify-driver: Send FCM push notification to driver on new delivery assignment
 *
 * Called via database webhook when a delivery is inserted/updated with status='assigned'
 * OR called directly via POST with { delivery_id, driver_id }
 *
 * Security: requires a shared secret header (x-webhook-secret) that must match
 * the WEBHOOK_SHARED_SECRET env var. This function uses the service role key
 * to read driver FCM tokens and delivery details, so it must not be callable
 * by unauthenticated clients.
 */

interface NotifyRequest {
  delivery_id: string
  driver_id: string
  type?: 'new_delivery' | 'chat_message' | 'delivery_update'
  title?: string
  body?: string
  data?: Record<string, string>
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
  const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')

  if (!supabaseUrl || !supabaseKey) {
    return new Response(
      JSON.stringify({ code: 'SERVER_ERROR', message: 'Server configuration error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }

  const supabase = createClient(supabaseUrl, supabaseKey)

  try {
    const payload: NotifyRequest = await req.json()
    const { delivery_id, driver_id, type = 'new_delivery' } = payload

    if (!delivery_id || !driver_id) {
      return new Response(
        JSON.stringify({ code: 'VALIDATION_ERROR', message: 'delivery_id and driver_id are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get driver's FCM token
    const { data: driver, error: driverError } = await supabase
      .from('users')
      .select('id, name, fcm_token, phone')
      .eq('id', driver_id)
      .single()

    if (driverError || !driver) {
      return new Response(
        JSON.stringify({ code: 'NOT_FOUND', message: 'Driver not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!driver.fcm_token) {
      return new Response(
        JSON.stringify({ code: 'NO_TOKEN', message: 'Driver has no FCM token registered' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get delivery + order details for notification content
    const { data: delivery, error: deliveryError } = await supabase
      .from('deliveries')
      .select(`
        id, status, delivery_address, delivery_fee, distance_km, estimated_time_minutes,
        orders:order_id (id, order_number, customer_name, customer_phone, total, notes)
      `)
      .eq('id', delivery_id)
      .single()

    if (deliveryError || !delivery) {
      return new Response(
        JSON.stringify({ code: 'NOT_FOUND', message: 'Delivery not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const order = (delivery as any).orders

    // Build notification based on type
    let title: string
    let body: string
    let notificationData: Record<string, string> = {
      type,
      delivery_id,
      order_id: order?.id || '',
    }

    switch (type) {
      case 'new_delivery':
        title = payload.title || 'طلب توصيل جديد'
        body = payload.body || `طلب #${order?.order_number || ''} - ${delivery.delivery_address || 'عنوان التوصيل'}`
        if (delivery.delivery_fee) {
          body += ` - ${delivery.delivery_fee} ر.س`
        }
        notificationData.click_action = 'NEW_DELIVERY'
        break

      case 'chat_message':
        title = payload.title || 'رسالة جديدة'
        body = payload.body || `رسالة جديدة بخصوص الطلب #${order?.order_number || ''}`
        notificationData.click_action = 'OPEN_CHAT'
        break

      case 'delivery_update':
        title = payload.title || 'تحديث التوصيل'
        body = payload.body || `تحديث على الطلب #${order?.order_number || ''}`
        notificationData.click_action = 'OPEN_DELIVERY'
        break

      default:
        title = payload.title || 'تنبيه'
        body = payload.body || 'لديك تنبيه جديد'
    }

    // Add extra data if provided
    if (payload.data) {
      notificationData = { ...notificationData, ...payload.data }
    }

    // Send FCM notification
    if (fcmServerKey) {
      const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `key=${fcmServerKey}`,
        },
        body: JSON.stringify({
          to: driver.fcm_token,
          notification: {
            title,
            body,
            sound: 'default',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
            channel_id: type === 'new_delivery' ? 'delivery_alerts' : 'general',
          },
          data: notificationData,
          priority: 'high',
          android: {
            priority: 'high',
            notification: {
              channel_id: type === 'new_delivery' ? 'delivery_alerts' : 'general',
              sound: type === 'new_delivery' ? 'new_order' : 'default',
            }
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
                badge: 1,
                'content-available': 1,
              }
            }
          }
        })
      })

      const fcmResult = await fcmResponse.json()

      return new Response(
        JSON.stringify({
          success: true,
          fcm_response: fcmResult,
          driver_id,
          delivery_id,
          type,
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // No FCM key configured - log and return success
    return new Response(
      JSON.stringify({
        success: true,
        message: 'FCM not configured, notification logged only',
        driver_id,
        delivery_id,
        type,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Notify driver error:', error)
    return new Response(
      JSON.stringify({ code: 'SERVER_ERROR', message: 'Failed to send notification' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
