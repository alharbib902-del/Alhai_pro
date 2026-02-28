import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' hide Column;

/// شاشة إدارة قائمة انتظار WhatsApp وقوالب الرسائل
class WhatsAppManagementScreen extends ConsumerStatefulWidget {
  const WhatsAppManagementScreen({super.key});

  @override
  ConsumerState<WhatsAppManagementScreen> createState() => _WhatsAppManagementScreenState();
}

class _WhatsAppManagementScreenState extends ConsumerState<WhatsAppManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Queue
  List<_WaMessage> _messages = [];
  String _filterStatus = 'all';
  int _pendingCount = 0, _sentCount = 0, _failedCount = 0;

  // Templates
  List<_WaTemplate> _templates = [];

  // Settings
  final _apiKeyController = TextEditingController();
  final _instanceIdController = TextEditingController();
  bool _autoSend = true;
  int _dailyLimit = 100;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiKeyController.dispose();
    _instanceIdController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider) ?? '';

      // Load messages
      final msgs = await db.customSelect(
        '''SELECT id, recipient_phone, message_type, status, created_at, sent_at, error_message
           FROM whatsapp_messages WHERE store_id = ? ORDER BY created_at DESC LIMIT 50''',
        variables: [Variable.withString(storeId)],
      ).get();

      // Load templates
      final tmplRows = await db.customSelect(
        'SELECT id, name, content, variables, is_active FROM whatsapp_templates WHERE store_id = ?',
        variables: [Variable.withString(storeId)],
      ).get();

      if (mounted) {
        setState(() {
          _messages = msgs.map((r) => _WaMessage(
            id: r.data['id'] as String,
            phone: r.data['recipient_phone'] as String,
            type: r.data['message_type'] as String,
            status: r.data['status'] as String,
            createdAt: _parseDate(r.data['created_at']),
            sentAt: r.data['sent_at'] != null ? _parseDateNullable(r.data['sent_at']) : null,
            error: r.data['error_message'] as String? ?? '',
          )).toList();

          _pendingCount = _messages.where((m) => m.status == 'pending').length;
          _sentCount = _messages.where((m) => m.status == 'sent').length;
          _failedCount = _messages.where((m) => m.status == 'failed').length;

          if (tmplRows.isEmpty) {
            _templates = _defaultTemplates();
          } else {
            _templates = tmplRows.map((r) => _WaTemplate(
              id: r.data['id'] as String,
              name: r.data['name'] as String,
              content: r.data['content'] as String,
              isActive: (r.data['is_active'] as int?) == 1,
            )).toList();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_WaTemplate> _defaultTemplates() => [
    _WaTemplate(
      id: '1',
      name: 'فاتورة البيع',
      content: 'شكراً لتسوّقك من {store_name}!\nرقم الفاتورة: {invoice_no}\nالإجمالي: {total} ر.س',
      isActive: true,
    ),
    _WaTemplate(
      id: '2',
      name: 'تذكير الدين',
      content: 'عزيزي {customer_name}،\nلديك رصيد مستحق بقيمة {amount} ر.س.\nيرجى التواصل معنا.',
      isActive: true,
    ),
    _WaTemplate(
      id: '3',
      name: 'ترحيب بالعميل الجديد',
      content: 'أهلاً وسهلاً بك في {store_name}!\nنسعد بخدمتك دائماً.',
      isActive: false,
    ),
  ];

  DateTime _parseDate(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  DateTime? _parseDateNullable(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  Future<void> _retryMessage(String id) async {
    setState(() {
      final idx = _messages.indexWhere((m) => m.id == id);
      if (idx >= 0) {
        _messages[idx] = _messages[idx].copyWith(status: 'pending');
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('تمت إعادة الإرسال إلى قائمة الانتظار'), backgroundColor: AppColors.info),
    );
  }

  Future<void> _cancelMessage(String id) async {
    setState(() {
      final idx = _messages.indexWhere((m) => m.id == id);
      if (idx >= 0) {
        _messages[idx] = _messages[idx].copyWith(status: 'cancelled');
      }
    });
  }

  void _showTemplateEditor({_WaTemplate? existing}) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'تعديل القالب' : 'قالب جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم القالب',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(
                labelText: 'نص الرسالة',
                border: OutlineInputBorder(),
                helperText: 'استخدم {store_name} {customer_name} {total} كمتغيرات',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final content = contentCtrl.text.trim();
              if (name.isEmpty || content.isEmpty) return;

              final tmpl = _WaTemplate(
                id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                content: content,
                isActive: existing?.isActive ?? true,
              );

              setState(() {
                if (isEdit) {
                  final idx = _templates.indexWhere((t) => t.id == existing.id);
                  if (idx >= 0) _templates[idx] = tmpl;
                } else {
                  _templates.add(tmpl);
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة WhatsApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.queue_rounded, size: 16),
                const SizedBox(width: 4),
                Text('قائمة الانتظار'),
                if (_pendingCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(10)),
                    child: Text('$_pendingCount', style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ],
              ]),
            ),
            const Tab(icon: Icon(Icons.message_outlined, size: 16), text: 'القوالب'),
            const Tab(icon: Icon(Icons.settings_outlined, size: 16), text: 'الإعدادات'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildQueueTab(),
                _buildTemplatesTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  Widget _buildQueueTab() {
    final filtered = _filterStatus == 'all'
        ? _messages
        : _messages.where((m) => m.status == _filterStatus).toList();

    return Column(
      children: [
        // Stats row
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(child: _StatCard(label: 'انتظار', count: _pendingCount, color: AppColors.warning)),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(label: 'مُرسل', count: _sentCount, color: AppColors.success)),
              const SizedBox(width: 8),
              Expanded(child: _StatCard(label: 'فشل', count: _failedCount, color: AppColors.error)),
            ],
          ),
        ),
        // Filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _filterChip('all', 'الكل'),
              _filterChip('pending', 'انتظار'),
              _filterChip('sent', 'مُرسل'),
              _filterChip('failed', 'فشل'),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Theme.of(context).hintColor),
                    SizedBox(height: 12),
                    Text('لا توجد رسائل', style: TextStyle(color: Theme.of(context).hintColor)),
                  ]),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) {
                    final msg = filtered[i];
                    final (color, icon) = _statusStyle(msg.status);
                    return Card(
                      child: ListTile(
                        leading: Icon(icon, color: color),
                        title: Text(msg.phone, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          '${msg.type} • ${_formatDate(msg.createdAt)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: msg.status == 'failed' || msg.status == 'pending'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (msg.status == 'failed')
                                    IconButton(
                                      icon: Icon(Icons.refresh_rounded, size: 18, color: AppColors.info),
                                      onPressed: () => _retryMessage(msg.id),
                                      tooltip: 'إعادة الإرسال',
                                    ),
                                  if (msg.status == 'pending')
                                    IconButton(
                                      icon: Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                                      onPressed: () => _cancelMessage(msg.id),
                                      tooltip: 'إلغاء',
                                    ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String status, String label) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (_) => setState(() => _filterStatus = status),
      ),
    );
  }

  (Color, IconData) _statusStyle(String status) {
    switch (status) {
      case 'sent': return (AppColors.success, Icons.check_circle_outline);
      case 'failed': return (AppColors.error, Icons.error_outline);
      case 'cancelled': return (Theme.of(context).colorScheme.outline, Icons.cancel_outlined);
      default: return (AppColors.warning, Icons.schedule_rounded);
    }
  }

  Widget _buildTemplatesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_templates.length} قالب',
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
              FilledButton.icon(
                onPressed: () => _showTemplateEditor(),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('قالب جديد'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _templates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final t = _templates[i];
              return Card(
                child: ExpansionTile(
                  leading: Icon(
                    Icons.message_outlined,
                    color: t.isActive ? AppColors.success : Theme.of(context).colorScheme.outline,
                  ),
                  title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    t.isActive ? 'نشط' : 'معطّل',
                    style: TextStyle(
                      color: t.isActive ? AppColors.success : Theme.of(context).colorScheme.outline,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: t.isActive,
                        onChanged: (v) {
                          setState(() => _templates[i] = t.copyWith(isActive: v));
                        },
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(t.content, style: const TextStyle(fontSize: 13)),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showTemplateEditor(existing: t),
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('تعديل'),
                              ),
                              TextButton.icon(
                                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                onPressed: () {
                                  setState(() => _templates.removeAt(i));
                                },
                                icon: const Icon(Icons.delete_outline, size: 16),
                                label: const Text('حذف'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // API credentials
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إعدادات API', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'مفتاح API',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key_rounded),
                      hintText: 'wasender_api_xxxxx',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _instanceIdController,
                    decoration: const InputDecoration(
                      labelText: 'Instance ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_android_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text('جاري اختبار الاتصال...'), backgroundColor: AppColors.info),
                      );
                    },
                    icon: const Icon(Icons.wifi_tethering_rounded, size: 18),
                    label: const Text('اختبار الاتصال'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Auto-send settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إعدادات الإرسال', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('الإرسال التلقائي'),
                    subtitle: const Text('إرسال الرسائل تلقائياً بعد كل عملية'),
                    value: _autoSend,
                    onChanged: (v) => setState(() => _autoSend = v),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('الحد اليومي للرسائل'),
                    subtitle: Text('$_dailyLimit رسالة/يوم'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () { if (_dailyLimit > 10) setState(() => _dailyLimit -= 10); },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$_dailyLimit', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () { if (_dailyLimit < 500) setState(() => _dailyLimit += 10); },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ الإعدادات'), backgroundColor: AppColors.success),
                );
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('حفظ الإعدادات'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ─── Reusable widgets ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatCard({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('$count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}

// ─── Data models ─────────────────────────────────────────────────────────────

class _WaMessage {
  final String id;
  final String phone;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final String error;

  const _WaMessage({
    required this.id,
    required this.phone,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.sentAt,
    required this.error,
  });

  _WaMessage copyWith({String? status}) => _WaMessage(
    id: id,
    phone: phone,
    type: type,
    status: status ?? this.status,
    createdAt: createdAt,
    sentAt: sentAt,
    error: error,
  );
}

class _WaTemplate {
  final String id;
  final String name;
  final String content;
  final bool isActive;

  const _WaTemplate({
    required this.id,
    required this.name,
    required this.content,
    required this.isActive,
  });

  _WaTemplate copyWith({bool? isActive}) => _WaTemplate(
    id: id,
    name: name,
    content: content,
    isActive: isActive ?? this.isActive,
  );
}
