import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
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
      final dayStart =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
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
        final l10n = AppLocalizations.of(context);
        setState(() {
          _employees = users
              .map((u) => _EmployeeOption(
                  id: u.id,
                  name: u.name.isNotEmpty
                      ? u.name
                      : (u.phone ?? l10n.employeeFallback)))
              .toList();
          _records = shifts.map((row) {
            final openedAt = _parseDate(row.data['opened_at']);
            final closedAt = _parseDate(row.data['closed_at']);
            final duration = closedAt.difference(openedAt);
            return _AttendanceRecord(
              employeeId: row.data['cashier_id'] as String,
              employeeName:
                  row.data['employee_name'] as String? ?? l10n.employeeFallback,
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
    final l10n = AppLocalizations.of(context);
    return l10n.hoursMinutes(d.inHours, d.inMinutes.remainder(60));
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
    final l10n = AppLocalizations.of(context);
    final presentCount = _records.where((r) => r.checkIn != null).length;
    final absentCount =
        (_employees.length - presentCount).clamp(0, _employees.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.employeeAttendance),
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
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Date banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
              color: theme.colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: _selectDate,
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18,
                            color: theme.colorScheme.onPrimaryContainer),
                        const SizedBox(width: AlhaiSpacing.xs),
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
                      _AttBadge(
                          label: l10n.presentLabel,
                          count: presentCount,
                          color: AppColors.success),
                      const SizedBox(width: AlhaiSpacing.xs),
                      _AttBadge(
                          label: l10n.absentLabel,
                          count: absentCount,
                          color: AppColors.error),
                    ],
                  ),
                ],
              ),
            ),

            // Summary row
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                        child: _SummaryBox(
                      label: l10n.attendanceCount,
                      value: presentCount.toString(),
                      color: AppColors.success,
                    )),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Expanded(
                        child: _SummaryBox(
                      label: l10n.absencesCount,
                      value: absentCount.toString(),
                      color: AppColors.error,
                    )),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Expanded(
                        child: _SummaryBox(
                      label: l10n.lateCount,
                      value: _records
                          .where(
                              (r) => r.checkIn != null && r.checkIn!.hour >= 9)
                          .length
                          .toString(),
                      color: AppColors.warning,
                    )),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Expanded(
                        child: _SummaryBox(
                      label: l10n.totalEmployees,
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
                      ? AppEmptyState.noData(
                          context,
                          title: l10n.noShifts,
                          description: l10n.noAttendanceRecordsForDay(
                              _selectedDate.day, _selectedDate.month),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AlhaiSpacing.sm),
                          itemCount: _records.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AlhaiSpacing.xxs),
                          itemBuilder: (ctx, i) {
                            final r = _records[i];
                            final isOpen = r.checkOut == null;
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isOpen
                                      ? AppColors.success
                                          .withValues(alpha: 0.15)
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerLowest,
                                  child: Text(
                                    r.employeeName.isNotEmpty
                                        ? r.employeeName[0]
                                        : '?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isOpen
                                          ? AppColors.success
                                          : Theme.of(context)
                                              .colorScheme
                                              .outline,
                                    ),
                                  ),
                                ),
                                title: Text(r.employeeName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                                subtitle: Row(
                                  children: [
                                    Icon(Icons.login_rounded,
                                        size: 12, color: AppColors.success),
                                    const SizedBox(width: AlhaiSpacing.xxs),
                                    Text(_formatTime(r.checkIn),
                                        style: const TextStyle(fontSize: 12)),
                                    const SizedBox(width: AlhaiSpacing.sm),
                                    Icon(Icons.logout_rounded,
                                        size: 12, color: AppColors.error),
                                    const SizedBox(width: AlhaiSpacing.xxs),
                                    Text(_formatTime(r.checkOut),
                                        style: const TextStyle(fontSize: 12)),
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
                                        color: isOpen
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                      ),
                                    ),
                                    if (isOpen)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.success
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(l10n.workingNow,
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.success)),
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
      ),
    );
  }
}

class _AttBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _AttBadge(
      {required this.label, required this.count, required this.color});

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
        style:
            TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryBox(
      {required this.label, required this.value, required this.color});

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
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style:
                  TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
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
