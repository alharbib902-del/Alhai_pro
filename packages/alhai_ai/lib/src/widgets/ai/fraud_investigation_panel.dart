/// لوحة التحقيق في الاحتيال - Fraud Investigation Panel
///
/// تعرض الجدول الزمني للأحداث والملاحظات وعناصر التحكم في الحالة
library;

import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_fraud_detection_service.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// لوحة التحقيق
class FraudInvestigationPanel extends StatefulWidget {
  final FraudAlert alert;
  final Investigation investigation;
  final ValueChanged<InvestigationStatus>? onStatusChanged;
  final ValueChanged<String>? onNoteAdded;

  const FraudInvestigationPanel({
    super.key,
    required this.alert,
    required this.investigation,
    this.onStatusChanged,
    this.onNoteAdded,
  });

  @override
  State<FraudInvestigationPanel> createState() =>
      _FraudInvestigationPanelState();
}

class _FraudInvestigationPanelState extends State<FraudInvestigationPanel> {
  final _noteController = TextEditingController();
  late InvestigationStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.investigation.status;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Color _getStatusColor(InvestigationStatus status) {
    switch (status) {
      case InvestigationStatus.open:
        return AppColors.warning;
      case InvestigationStatus.underInvestigation:
        return AppColors.info;
      case InvestigationStatus.closed:
        return AppColors.success;
      case InvestigationStatus.escalated:
        return AppColors.error;
    }
  }

  String _getStatusLabel(InvestigationStatus status, AppLocalizations l10n) {
    switch (status) {
      case InvestigationStatus.open:
        return l10n.open;
      case InvestigationStatus.underInvestigation:
        return 'قيد التحقيق'; // Under Investigation
      case InvestigationStatus.closed:
        return l10n.closed;
      case InvestigationStatus.escalated:
        return 'تم التصعيد'; // Escalated
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                l10n.investigation,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Status dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xxs),
                decoration: BoxDecoration(
                  color: _getStatusColor(_currentStatus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        _getStatusColor(_currentStatus).withValues(alpha: 0.3),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<InvestigationStatus>(
                    value: _currentStatus,
                    isDense: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: _getStatusColor(_currentStatus),
                      size: 18,
                    ),
                    style: TextStyle(
                      color: _getStatusColor(_currentStatus),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    dropdownColor:
                        isDark ? const Color(0xFF334155) : Colors.white,
                    items: InvestigationStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusLabel(status, l10n)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _currentStatus = value);
                        widget.onStatusChanged?.call(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.md),

          // Suggested action
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الإجراء المقترح', // Suggested Action
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AlhaiSpacing.xxxs),
                      Text(
                        widget.alert.suggestedAction,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.mdl),

          // Timeline header
          Text(
            'الجدول الزمني', // Timeline
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),

          // Timeline events
          ...widget.investigation.timeline.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isLast = index == widget.investigation.timeline.length - 1;

            return _TimelineItem(
              event: event,
              isLast: isLast,
              isDark: isDark,
              formattedTime: _formatDateTime(event.timestamp),
            );
          }),

          const SizedBox(height: AlhaiSpacing.md),

          // Add note
          Text(
            'إضافة ملاحظة', // Add Note
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب ملاحظة...', // Write a note...
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : AppColors.textMuted,
                      fontSize: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.sm, vertical: 10),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.grey50,
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              IconButton(
                onPressed: () {
                  if (_noteController.text.isNotEmpty) {
                    widget.onNoteAdded?.call(_noteController.text);
                    _noteController.clear();
                  }
                },
                icon: const AdaptiveIcon(Icons.send_rounded),
                color: AppColors.primary,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// عنصر الجدول الزمني - Timeline Item
class _TimelineItem extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;
  final bool isDark;
  final String formattedTime;

  const _TimelineItem({
    required this.event,
    required this.isLast,
    required this.isDark,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot and line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.grey200,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AlhaiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    event.description,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
