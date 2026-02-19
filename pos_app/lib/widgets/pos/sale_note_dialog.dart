import 'package:flutter/material.dart';

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
  final _quickNotes = ['توصيل', 'تغليف هدية', 'هش - حساس', 'عاجل', 'حجز'];

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
    return AlertDialog(
      title: const Text('ملاحظة على الفاتورة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickNotes
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
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            maxLength: 200,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'أضف ملاحظة...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        if (_controller.text.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}
