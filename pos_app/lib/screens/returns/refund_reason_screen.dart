import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// شاشة اختيار سبب الإرجاع
class RefundReasonScreen extends StatefulWidget {
  const RefundReasonScreen({super.key});

  @override
  State<RefundReasonScreen> createState() => _RefundReasonScreenState();
}

class _RefundReasonScreenState extends State<RefundReasonScreen> {
  String? _selectedReason;
  final _notesController = TextEditingController();

  final List<Map<String, dynamic>> _reasons = [
    {'id': 'damaged', 'label': 'منتج تالف', 'icon': Icons.broken_image},
    {'id': 'wrong', 'label': 'خطأ في الطلب', 'icon': Icons.error_outline},
    {'id': 'changed_mind', 'label': 'تغيير رأي العميل', 'icon': Icons.sentiment_dissatisfied},
    {'id': 'expired', 'label': 'منتج منتهي الصلاحية', 'icon': Icons.schedule},
    {'id': 'quality', 'label': 'جودة غير مرضية', 'icon': Icons.thumb_down},
    {'id': 'other', 'label': 'سبب آخر', 'icon': Icons.more_horiz},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سبب الإرجاع'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'اختر سبب الإرجاع',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Reason options
                ...List.generate(_reasons.length, (index) {
                  final reason = _reasons[index];
                  final isSelected = _selectedReason == reason['id'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? Colors.blue.shade50 : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => setState(() => _selectedReason = reason['id'] as String),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
                        child: Icon(
                          reason['icon'] as IconData,
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                      title: Text(
                        reason['label'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Notes
                const Text(
                  'ملاحظات إضافية (اختياري)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'أضف أي ملاحظات إضافية...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),

          // Bottom action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selectedReason == null ? null : _proceedToApproval,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('التالي - موافقة المشرف'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToApproval() {
    context.push('/auth/manager-approval');
  }
}
