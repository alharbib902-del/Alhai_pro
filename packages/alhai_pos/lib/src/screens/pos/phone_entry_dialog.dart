/// نافذة إدخال رقم جوال العميل - Phone Entry Dialog
///
/// نافذة خفيفة تظهر بعد الضغط على "ادفع" وقبل شاشة الدفع
/// لجمع رقم جوال العميل مع إمكانية البحث عن عميل موجود أو التخطي
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:get_it/get_it.dart';

// ============================================================================
// PhoneEntryResult - نتيجة إدخال رقم الجوال
// ============================================================================

/// نتيجة إدخال رقم الجوال
class PhoneEntryResult {
  final String? phone;
  final String? customerId;
  final String? customerName;

  const PhoneEntryResult({this.phone, this.customerId, this.customerName});
  const PhoneEntryResult.skipped()
    : phone = null,
      customerId = null,
      customerName = null;

  bool get wasSkipped => phone == null;
  bool get hasExistingCustomer => customerId != null;
}

// ============================================================================
// PhoneEntryDialog - نافذة إدخال رقم الجوال
// ============================================================================

/// نافذة إدخال رقم جوال العميل قبل الدفع
class PhoneEntryDialog extends StatefulWidget {
  final String storeId;

  const PhoneEntryDialog({super.key, required this.storeId});

  /// عرض النافذة وإرجاع النتيجة
  static Future<PhoneEntryResult> show(
    BuildContext context, {
    required String storeId,
  }) async {
    final result = await showModalBottomSheet<PhoneEntryResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhoneEntryDialog(storeId: storeId),
    );
    return result ?? const PhoneEntryResult.skipped();
  }

  @override
  State<PhoneEntryDialog> createState() => _PhoneEntryDialogState();
}

class _PhoneEntryDialogState extends State<PhoneEntryDialog> {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();
  late final CustomersDao _customersDao;

  Timer? _debounceTimer;
  List<_MatchedCustomer> _matchedCustomers = [];
  _MatchedCustomer? _selectedCustomer;
  bool _isSearching = false;
  String? _validationHint;

  /// الحد الأقصى لنتائج البحث المعروضة
  static const _maxResults = 3;

  /// مدة تأخير البحث
  static const _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _customersDao = GetIt.I<AppDatabase>().customersDao;
    _phoneController.addListener(_onPhoneChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ==========================================================================
  // البحث والتحقق
  // ==========================================================================

  /// عند تغيير نص الهاتف
  void _onPhoneChanged() {
    final raw = _phoneController.text;
    final sanitized = InputSanitizer.sanitizePhone(raw);

    // تنظيف المدخل إذا تغير
    if (sanitized != raw) {
      _phoneController.text = sanitized;
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: sanitized.length),
      );
      return;
    }

    // إعادة ضبط العميل المختار عند تغيير النص يدويا
    if (_selectedCustomer != null && sanitized != _selectedCustomer!.phone) {
      setState(() => _selectedCustomer = null);
    }

    // تحديث تلميح التحقق
    _updateValidationHint(sanitized);

    // بدء البحث بتأخير
    _debounceTimer?.cancel();
    if (sanitized.length >= 3) {
      _debounceTimer = Timer(
        _debounceDuration,
        () => _searchCustomers(sanitized),
      );
    } else {
      setState(() {
        _matchedCustomers = [];
        _isSearching = false;
      });
    }
  }

  /// تحديث تلميح التحقق من صيغة الرقم
  void _updateValidationHint(String phone) {
    if (phone.isEmpty) {
      setState(() => _validationHint = null);
      return;
    }

    String? hint;

    if (phone.startsWith('05')) {
      // صيغة سعودية محلية
      if (phone.length < 10) {
        hint =
            '${10 - phone.length} ${AppLocalizations.of(context).digitsRemaining}';
      } else if (phone.length > 10) {
        hint = AppLocalizations.of(context).phoneNumberTooLong;
      }
    } else if (phone.startsWith('+966')) {
      // صيغة دولية سعودية
      if (phone.length < 13) {
        hint =
            '${13 - phone.length} ${AppLocalizations.of(context).digitsRemaining}';
      }
    } else if (phone.length < 8) {
      hint = AppLocalizations.of(context).enterValidPhoneNumber;
    }

    setState(() => _validationHint = hint);
  }

  /// التحقق من صحة رقم الهاتف
  bool _isPhoneValid(String phone) {
    if (phone.isEmpty) return false;

    // صيغة سعودية: يبدأ بـ 05 و 10 أرقام
    if (phone.startsWith('05') && phone.length == 10) return true;

    // صيغة دولية: يبدأ بـ +966 و 12+ رقم
    if (phone.startsWith('+966') && phone.length >= 13) return true;

    // قبول أي رقم بـ 8 أرقام أو أكثر (مرن)
    if (phone.replaceAll('+', '').length >= 8) return true;

    return false;
  }

  /// البحث عن عملاء مطابقين
  Future<void> _searchCustomers(String query) async {
    if (!mounted) return;
    setState(() => _isSearching = true);

    try {
      final results = await _customersDao.searchCustomers(
        query,
        widget.storeId,
      );
      if (!mounted) return;

      setState(() {
        _matchedCustomers = results
            .where((c) => c.phone != null && c.phone!.isNotEmpty)
            .take(_maxResults)
            .map(
              (c) => _MatchedCustomer(
                id: c.id,
                name: c.name,
                phone: c.phone ?? '',
              ),
            )
            .toList();
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _matchedCustomers = [];
        _isSearching = false;
      });
    }
  }

  // ==========================================================================
  // الإجراءات
  // ==========================================================================

  /// تخطي إدخال رقم الجوال
  void _skip() {
    Navigator.pop(context, const PhoneEntryResult.skipped());
  }

  /// المتابعة مع الرقم المدخل
  void _proceed() {
    final phone = _phoneController.text.trim();

    if (_selectedCustomer != null) {
      Navigator.pop(
        context,
        PhoneEntryResult(
          phone: _selectedCustomer!.phone,
          customerId: _selectedCustomer!.id,
          customerName: _selectedCustomer!.name,
        ),
      );
      return;
    }

    if (phone.isNotEmpty) {
      Navigator.pop(context, PhoneEntryResult(phone: phone));
      return;
    }

    // إذا لم يدخل رقم، تخطي
    _skip();
  }

  /// اختيار عميل من نتائج البحث
  void _selectCustomer(_MatchedCustomer customer) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCustomer = customer;
      _phoneController.text = customer.phone;
      _phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: customer.phone.length),
      );
      _matchedCustomers = [];
      _validationHint = null;
    });
  }

  // ==========================================================================
  // واجهة المستخدم
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final phone = _phoneController.text.trim();
    final hasPhone = phone.isNotEmpty;
    final isValid = _isPhoneValid(phone);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            _skip();
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            _proceed();
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusXl),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مقبض السحب
              _buildDragHandle(colorScheme),

              // العنوان
              _buildHeader(l10n),

              const Divider(height: 1),

              // حقل إدخال رقم الجوال
              _buildPhoneInput(colorScheme, l10n),

              // تلميح التحقق
              if (_validationHint != null && !_isPhoneValid(phone))
                _buildValidationHint(),

              // العميل المطابق
              if (_selectedCustomer != null)
                _buildSelectedCustomer(colorScheme),

              // نتائج البحث
              if (_matchedCustomers.isNotEmpty && _selectedCustomer == null)
                _buildSearchResults(colorScheme),

              // مؤشر البحث
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.sm),
                  child: SizedBox(height: 2, child: LinearProgressIndicator()),
                ),

              const SizedBox(height: AppSizes.sm),

              // أزرار الإجراءات
              _buildActions(colorScheme, l10n, hasPhone, isValid),

              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// مقبض السحب
  Widget _buildDragHandle(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Container(
        width: AlhaiSpacing.dragHandleWidth,
        height: AlhaiSpacing.dragHandleHeight,
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// عنوان النافذة مع زر الإغلاق
  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Row(
        children: [
          const Icon(Icons.phone_android, size: 22),
          const SizedBox(width: AppSizes.sm),
          Text(l10n.customerPhoneNumber, style: AppTypography.headlineSmall),
          const Spacer(),
          IconButton(
            onPressed: _skip,
            icon: const Icon(Icons.close),
            tooltip: l10n.close,
          ),
        ],
      ),
    );
  }

  /// حقل إدخال رقم الجوال
  Widget _buildPhoneInput(ColorScheme colorScheme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.sm,
      ),
      child: TextField(
        controller: _phoneController,
        focusNode: _focusNode,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        keyboardType: TextInputType.phone,
        maxLength: 15,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+]'))],
        decoration: InputDecoration(
          counterText: '',
          hintText: '05xxxxxxxx',
          hintStyle: AppTypography.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          prefixIcon: const Icon(Icons.phone_outlined),
          suffixIcon: _phoneController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _phoneController.clear();
                    _focusNode.requestFocus();
                  },
                  tooltip: l10n.clearField,
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
        style: AppTypography.titleLarge.copyWith(letterSpacing: 1.5),
        onSubmitted: (_) => _proceed(),
      ),
    );
  }

  /// تلميح التحقق
  Widget _buildValidationHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.warning),
          const SizedBox(width: AppSizes.xs),
          Text(
            _validationHint!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
          ),
        ],
      ),
    );
  }

  /// عرض العميل المختار
  Widget _buildSelectedCustomer(ColorScheme colorScheme) {
    final customer = _selectedCustomer!;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.successSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 20),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    customer.phone,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedCustomer = null;
                  _phoneController.clear();
                  _focusNode.requestFocus();
                });
              },
              icon: const Icon(Icons.close, size: 18),
              visualDensity: VisualDensity.compact,
              tooltip: AppLocalizations.of(context).clearField,
            ),
          ],
        ),
      ),
    );
  }

  /// قائمة نتائج البحث
  Widget _buildSearchResults(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.xs),
            child: Text(
              AppLocalizations.of(context).existingCustomers,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          ...List.generate(_matchedCustomers.length, (index) {
            final customer = _matchedCustomers[index];
            return _buildCustomerTile(customer, colorScheme);
          }),
        ],
      ),
    );
  }

  /// عنصر عميل في قائمة النتائج
  Widget _buildCustomerTile(
    _MatchedCustomer customer,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: () => _selectCustomer(customer),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0] : '?',
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        customer.phone,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
                const AdaptiveIcon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// أزرار تخطي ومتابعة
  Widget _buildActions(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    bool hasPhone,
    bool isValid,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Row(
        children: [
          // زر التخطي
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _skip,
              icon: const Icon(Icons.skip_next_outlined, size: 20),
              label: Text(l10n.skip),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // زر المتابعة
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: hasPhone ? _proceed : null,
              icon: const Icon(Icons.arrow_forward, size: 20),
              label: Text(
                _selectedCustomer != null
                    ? l10n.continueWithCustomer
                    : l10n.continueAction,
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// نموذج عميل مطابق (داخلي)
// ============================================================================

/// نموذج مختصر لعميل مطابق من نتائج البحث
class _MatchedCustomer {
  final String id;
  final String name;
  final String phone;

  const _MatchedCustomer({
    required this.id,
    required this.name,
    required this.phone,
  });
}
