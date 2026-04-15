import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/services/sentry_service.dart';
import 'package:alhai_auth/alhai_auth.dart' show SecureStorageService;

/// شاشة إدارة قائمة انتظار WhatsApp وقوالب الرسائل
class WhatsAppManagementScreen extends ConsumerStatefulWidget {
  const WhatsAppManagementScreen({super.key});

  @override
  ConsumerState<WhatsAppManagementScreen> createState() =>
      _WhatsAppManagementScreenState();
}

class _WhatsAppManagementScreenState
    extends ConsumerState<WhatsAppManagementScreen>
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
      final msgs = await db
          .customSelect(
            '''SELECT id, recipient_phone, message_type, status, created_at, sent_at, error_message
           FROM whatsapp_messages WHERE store_id = ? ORDER BY created_at DESC LIMIT 50''',
            variables: [Variable.withString(storeId)],
          )
          .get();

      // Load templates
      final tmplRows = await db
          .customSelect(
            'SELECT id, name, content, variables, is_active FROM whatsapp_templates WHERE store_id = ?',
            variables: [Variable.withString(storeId)],
          )
          .get();

      if (mounted) {
        setState(() {
          _messages = msgs
              .map(
                (r) => _WaMessage(
                  id: r.data['id'] as String,
                  phone: r.data['recipient_phone'] as String,
                  type: r.data['message_type'] as String,
                  status: r.data['status'] as String,
                  createdAt: _parseDate(r.data['created_at']),
                  sentAt: r.data['sent_at'] != null
                      ? _parseDateNullable(r.data['sent_at'])
                      : null,
                  error: r.data['error_message'] as String? ?? '',
                ),
              )
              .toList();

          _pendingCount = _messages.where((m) => m.status == 'pending').length;
          _sentCount = _messages.where((m) => m.status == 'sent').length;
          _failedCount = _messages.where((m) => m.status == 'failed').length;

          if (tmplRows.isEmpty) {
            _templates = _defaultTemplates();
          } else {
            _templates = tmplRows
                .map(
                  (r) => _WaTemplate(
                    id: r.data['id'] as String,
                    name: r.data['name'] as String,
                    content: r.data['content'] as String,
                    isActive: (r.data['is_active'] as int?) == 1,
                  ),
                )
                .toList();
          }
          _isLoading = false;
        });
      }

      // Load encrypted API credentials from secure storage
      final savedApiKey =
          await SecureStorageService.read('whatsapp_api_key');
      final savedInstanceId =
          await SecureStorageService.read('whatsapp_instance_id');
      if (mounted && savedApiKey != null) {
        _apiKeyController.text = savedApiKey;
      }
      if (mounted && savedInstanceId != null) {
        _instanceIdController.text = savedInstanceId;
      }
    } catch (e, st) {
      await reportError(
        e,
        stackTrace: st,
        hint: 'whatsapp_management: load data failed',
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_WaTemplate> _defaultTemplates() => [
    _WaTemplate(
      id: '1',
      name: 'فاتورة البيع',
      content:
          'شكراً لتسوّقك من {store_name}!\nرقم الفاتورة: {invoice_no}\nالإجمالي: {total} ر.س',
      isActive: true,
    ),
    _WaTemplate(
      id: '2',
      name: 'تذكير الدين',
      content:
          'عزيزي {customer_name}،\nلديك رصيد مستحق بقيمة {amount} ر.س.\nيرجى التواصل معنا.',
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
    if (!mounted) return;
    setState(() {
      final idx = _messages.indexWhere((m) => m.id == id);
      if (idx >= 0) {
        _messages[idx] = _messages[idx].copyWith(status: 'pending');
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).requeuedMessage),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  Future<void> _cancelMessage(String id) async {
    if (!mounted) return;
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
        title: Text(
          isEdit
              ? AppLocalizations.of(context).editTemplate
              : AppLocalizations.of(context).newTemplate,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).templateName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.sm),
            TextField(
              controller: contentCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).messageText,
                border: const OutlineInputBorder(),
                helperText: AppLocalizations.of(context).templateVariablesHint(
                  '{customer_name}',
                  '{store_name}',
                  '{total}',
                ),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final content = contentCtrl.text.trim();
              if (name.isEmpty || content.isEmpty) return;

              final tmpl = _WaTemplate(
                id:
                    existing?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
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
            child: Text(AppLocalizations.of(context).save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).whatsappManagement),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.queue_rounded, size: 16),
                  const SizedBox(width: AlhaiSpacing.xxs),
                  Text(AppLocalizations.of(context).messageQueue),
                  if (_pendingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_pendingCount',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              icon: const Icon(Icons.message_outlined, size: 16),
              text: AppLocalizations.of(context).templates,
            ),
            Tab(
              icon: const Icon(Icons.settings_outlined, size: 16),
              text: AppLocalizations.of(context).settings,
            ),
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
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: AppLocalizations.of(context).pendingStatus,
                  count: _pendingCount,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: _StatCard(
                  label: AppLocalizations.of(context).sentStatus,
                  count: _sentCount,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Expanded(
                child: _StatCard(
                  label: AppLocalizations.of(context).failedStatus,
                  count: _failedCount,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
        // Filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm),
            children: [
              _filterChip('all', AppLocalizations.of(context).all),
              _filterChip(
                'pending',
                AppLocalizations.of(context).pendingStatus,
              ),
              _filterChip('sent', AppLocalizations.of(context).sentStatus),
              _filterChip('failed', AppLocalizations.of(context).failedStatus),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? AppEmptyState(
                  icon: Icons.inbox_outlined,
                  title: AppLocalizations.of(context).noMessages,
                  description: '',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AlhaiSpacing.sm),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) {
                    final msg = filtered[i];
                    final (color, icon) = _statusStyle(msg.status);
                    return Card(
                      child: ListTile(
                        leading: Icon(icon, color: color),
                        title: Text(
                          msg.phone,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${msg.type} • ${_formatDate(msg.createdAt)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing:
                            msg.status == 'failed' || msg.status == 'pending'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (msg.status == 'failed')
                                    IconButton(
                                      icon: Icon(
                                        Icons.refresh_rounded,
                                        size: 18,
                                        color: AppColors.info,
                                      ),
                                      onPressed: () => _retryMessage(msg.id),
                                      tooltip: AppLocalizations.of(
                                        context,
                                      ).retrySend,
                                    ),
                                  if (msg.status == 'pending')
                                    IconButton(
                                      icon: Icon(
                                        Icons.cancel_outlined,
                                        size: 18,
                                        color: AppColors.error,
                                      ),
                                      onPressed: () => _cancelMessage(msg.id),
                                      tooltip: AppLocalizations.of(
                                        context,
                                      ).cancel,
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
      padding: const EdgeInsetsDirectional.only(end: AlhaiSpacing.xs),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (_) => setState(() => _filterStatus = status),
      ),
    );
  }

  (Color, IconData) _statusStyle(String status) {
    switch (status) {
      case 'sent':
        return (AppColors.success, Icons.check_circle_outline);
      case 'failed':
        return (AppColors.error, Icons.error_outline);
      case 'cancelled':
        return (Theme.of(context).colorScheme.outline, Icons.cancel_outlined);
      default:
        return (AppColors.warning, Icons.schedule_rounded);
    }
  }

  Widget _buildTemplatesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).templateCount(_templates.length),
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showTemplateEditor(),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(AppLocalizations.of(context).newTemplate),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm),
            itemCount: _templates.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AlhaiSpacing.xs),
            itemBuilder: (ctx, i) {
              final t = _templates[i];
              return Card(
                child: ExpansionTile(
                  leading: Icon(
                    Icons.message_outlined,
                    color: t.isActive
                        ? AppColors.success
                        : Theme.of(context).colorScheme.outline,
                  ),
                  title: Text(
                    t.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    t.isActive
                        ? AppLocalizations.of(context).activeStatus
                        : AppLocalizations.of(context).disabledStatus,
                    style: TextStyle(
                      color: t.isActive
                          ? AppColors.success
                          : Theme.of(context).colorScheme.outline,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: t.isActive,
                        onChanged: (v) {
                          setState(
                            () => _templates[i] = t.copyWith(isActive: v),
                          );
                        },
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AlhaiSpacing.md,
                        AlhaiSpacing.zero,
                        AlhaiSpacing.md,
                        AlhaiSpacing.xs,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AlhaiSpacing.sm),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t.content,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: AlhaiSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () =>
                                    _showTemplateEditor(existing: t),
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: Text(AppLocalizations.of(context).edit),
                              ),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                ),
                                onPressed: () {
                                  setState(() => _templates.removeAt(i));
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                ),
                                label: Text(
                                  AppLocalizations.of(context).delete,
                                ),
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
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // API credentials
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).apiSettings,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.sm),
                  TextField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).apiKey,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.key_rounded),
                      hintText: 'wasender_api_xxxxx',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: AlhaiSpacing.sm),
                  TextField(
                    controller: _instanceIdController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Instance ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_android_rounded),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).testingConnection,
                          ),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                    icon: const Icon(Icons.wifi_tethering_rounded, size: 18),
                    label: Text(AppLocalizations.of(context).testConnection),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          // Auto-send settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).sendSettings,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppLocalizations.of(context).autoSend),
                    subtitle: Text(
                      AppLocalizations.of(context).autoSendDescription,
                    ),
                    value: _autoSend,
                    onChanged: (v) => setState(() => _autoSend = v),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppLocalizations.of(context).dailyMessageLimit),
                    subtitle: Text(
                      AppLocalizations.of(context).messagesPerDay(_dailyLimit),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_dailyLimit > 10) {
                              setState(() => _dailyLimit -= 10);
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          '$_dailyLimit',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_dailyLimit < 500) {
                              setState(() => _dailyLimit += 10);
                            }
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                // Save API credentials to encrypted secure storage
                if (_apiKeyController.text.isNotEmpty) {
                  await SecureStorageService.write(
                    'whatsapp_api_key',
                    _apiKeyController.text,
                  );
                }
                if (_instanceIdController.text.isNotEmpty) {
                  await SecureStorageService.write(
                    'whatsapp_instance_id',
                    _instanceIdController.text,
                  );
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(AppLocalizations.of(context).settingsSaved),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: Text(AppLocalizations.of(context).saveSettings),
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
  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
          ),
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
