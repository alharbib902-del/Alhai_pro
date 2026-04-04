import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiColors, AlhaiSpacing;
import 'package:alhai_l10n/alhai_l10n.dart';

/// حوار إضافة ملاحظة على الفاتورة
///
/// يتيح للكاشير إضافة ملاحظات سريعة أو مخصصة على الفاتورة
class SaleNoteDialog extends StatefulWidget {
  final String? initialNote;
  const SaleNoteDialog({super.key, this.initialNote});

  /// عرض الحوار وإرجاع النص أو null إذا تم الإلغاء
  static Future<String?> show(BuildContext context, {String? initialNote}) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => SaleNoteDialog(initialNote: initialNote),
    );
  }

  @override
  State<SaleNoteDialog> createState() => _SaleNoteDialogState();
}

class _SaleNoteDialogState extends State<SaleNoteDialog> {
  late final TextEditingController _controller;
  List<String> _quickNotes(AppLocalizations l10n) => [
        l10n.quickNoteDelivery,
        l10n.quickNoteGiftWrap,
        l10n.quickNoteFragile,
        l10n.quickNoteUrgent,
        l10n.quickNoteReservation
      ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.invoiceNote),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AlhaiSpacing.xs,
            runSpacing: AlhaiSpacing.xs,
            children: _quickNotes(l10n)
                .map((note) => ActionChip(
                      label: Text(note),
                      onPressed: () {
                        final current = _controller.text;
                        _controller.text =
                            current.isEmpty ? note : '$current, $note';
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: _controller.text.length),
                        );
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 200,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.addNoteHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        if (_controller.text.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: Text(l10n.clearNote,
                style: const TextStyle(color: AlhaiColors.error)),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
