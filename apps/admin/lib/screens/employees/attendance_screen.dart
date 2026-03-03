import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart' hide Column;

/// شاشة حضور وانصراف الموظفين
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  List<_AttendanceRecord> _records = [];
  List<_EmployeeOption> _employees = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final db = GetIt.I<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      if (storeId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Load employees (users in this store)
      final users = await db.usersDao.getAllUsers(storeId);
      final dayStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // Load shifts as attendance proxy
      final shifts = await db.customSelect(
        '''SELECT
             s.id,
             s.cashier_id,
             s.opened_at,
             s.closed_at,
             s.status,
             u.name as employee_name
           FROM shifts s
           LEFT JOIN users u ON u.id = s.cashier_id
           WHERE s.store_id = ?
             AND s.opened_at >= ?
             AND s.opened_at < ?
           ORDER BY s.opened_at''',
        variables: [
          Variable.withString(storeId),
          Variable.withDateTime(dayStart),
          Variable.withDateTime(dayEnd),
        ],
      ).get();

      if (mounted) {
        setState(() {
          _employees = users.map((u) => _EmployeeOption(id: u.id, name: u.name.isNotEmpty ? u.name : (u.phone ?? 'موظف'))).toList();
          _records = shifts.map((row) {
            final openedAt = _parseDate(row.data['opened_at']);
            final closedAt = _parseDate(row.data['closed_at']);
            final duration = closedAt.difference(openedAt);
            return _AttendanceRecord(
              employeeId: row.data['cashier_id'] as String,
              employeeName: row.data['employee_name'] as String? ?? 'موظف',
              checkIn: openedAt,
              checkOut: closedAt,
              duration: duration,
              status: row.data['status'] as String,
            );
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime _parseDate(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '--';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '$hس $mد';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentCount = _records.where((r) => r.checkIn != null).length;
    final absentCount = (_employees.length - presentCount).clamp(0, _employees.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حضور وانصراف الموظفين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: _selectDate,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _selectDate,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 18, color: theme.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _AttBadge(label: 'حاضر', count: presentCount, color: AppColors.success),
                    const SizedBox(width: 8),
                    _AttBadge(label: 'غائب', count: absentCount, color: AppColors.error),
                  ],
                ),
              ],
            ),
          ),

          // Summary row
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: _SummaryBox(
                    label: 'الحضور',
                    value: presentCount.toString(),
                    color: AppColors.success,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryBox(
                    label: 'الغياب',
                    value: absentCount.toString(),
                    color: AppColors.error,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryBox(
                    label: 'متأخر',
                    value: _records
                        .where((r) => r.checkIn != null && r.checkIn!.hour >= 9)
                        .length
                        .toString(),
                    color: AppColors.warning,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryBox(
                    label: 'إجمالي الموظفين',
                    value: _employees.length.toString(),
                    color: AppColors.info,
                  )),
                ],
              ),
            ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Theme.of(context).hintColor),
                            const SizedBox(height: 12),
                            Text(
                              'لا يوجد سجلات حضور ليوم '
                              '${_selectedDate.day}/${_selectedDate.month}',
                              style: TextStyle(color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _records.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (ctx, i) {
                          final r = _records[i];
                          final isOpen = r.checkOut == null;
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isOpen
                                    ? AppColors.success.withValues(alpha: 0.15)
                                    : Theme.of(context).colorScheme.surfaceContainerLowest,
                                child: Text(
                                  r.employeeName.isNotEmpty ? r.employeeName[0] : '?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isOpen ? AppColors.success : Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ),
                              title: Text(r.employeeName,
                                  style: const TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: Row(
                                children: [
                                  Icon(Icons.login_rounded, size: 12, color: AppColors.success),
                                  const SizedBox(width: 4),
                                  Text(_formatTime(r.checkIn), style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.logout_rounded, size: 12, color: AppColors.error),
                                  const SizedBox(width: 4),
                                  Text(_formatTime(r.checkOut), style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatDuration(r.duration),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isOpen ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (isOpen)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text('يعمل الآن',
                                          style: TextStyle(fontSize: 10, color: AppColors.success)),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _AttBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _AttBadge({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}

class _AttendanceRecord {
  final String employeeId;
  final String employeeName;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final Duration? duration;
  final String status;
  const _AttendanceRecord({
    required this.employeeId,
    required this.employeeName,
    required this.checkIn,
    required this.checkOut,
    required this.duration,
    required this.status,
  });
}

class _EmployeeOption {
  final String id;
  final String name;
  const _EmployeeOption({required this.id, required this.name});
}
