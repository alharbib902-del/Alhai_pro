import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../widgets/common/adaptive_icon.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/validators/validators.dart';

/// Internal Notes Section - displays a list of notes with an input
/// field to add new ones. Notes are stored in-memory.
class CustomerNotesSection extends StatefulWidget {
  final bool isDark;

  const CustomerNotesSection({super.key, required this.isDark});

  @override
  State<CustomerNotesSection> createState() => _CustomerNotesSectionState();
}

class _CustomerNotesSectionState extends State<CustomerNotesSection> {
  final List<Map<String, dynamic>> _notes = [];
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Row(
              children: [
                const Icon(
                  Icons.sticky_note_2_outlined,
                  size: 20,
                  color: Color(0xFFF59E0B),
                ),
                SizedBox(width: AlhaiSpacing.xs),
                Text(
                  'Internal Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs,
                    vertical: AlhaiSpacing.xxxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceVariant(isDark),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    '${_notes.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.getBorder(isDark)),
          // Notes list
          if (_notes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Center(
                child: Text(
                  'No notes yet',
                  style: TextStyle(color: AppColors.getTextMuted(isDark)),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AlhaiSpacing.sm),
              itemCount: _notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final note = _notes[index];
                return _buildNoteItem(note, isDark);
              },
            ),
          // Add note input
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    maxLength: 500,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppColors.getTextMuted(isDark),
                      ),
                      filled: true,
                      fillColor: AppColors.getSurfaceVariant(isDark),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        borderSide: BorderSide.none,
                      ),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _addNote(),
                  ),
                ),
                SizedBox(width: AlhaiSpacing.xs),
                IconButton(
                  onPressed: _addNote,
                  icon: const AdaptiveIcon(Icons.send_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(Map<String, dynamic> note, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: (note['color'] as Color).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          alignment: Alignment.center,
          child: Text(
            note['initials'] as String,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: note['color'] as Color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Note content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceVariant(isDark),
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      note['author'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(isDark),
                      ),
                    ),
                    Text(
                      note['date'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.getTextMuted(isDark),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AlhaiSpacing.xxs),
                Text(
                  note['text'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextSecondary(isDark),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addNote() {
    final raw = _noteController.text.trim();
    if (raw.isEmpty) return;
    final text = InputSanitizer.sanitize(raw);
    if (InputSanitizer.containsDangerousContent(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).inputContainsDangerousContent,
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    setState(() {
      _notes.insert(0, {
        'author': 'You',
        'initials': 'Y',
        'color': AppColors.primary,
        'date': _formatNow(),
        'text': text,
      });
    });
    _noteController.clear();
  }

  String _formatNow() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
