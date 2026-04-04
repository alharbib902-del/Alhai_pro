/// Phone Input Field - حقل إدخال رقم الجوال
///
/// حقل إدخال رقم الجوال مع علم السعودية ومفتاح الدولة
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

/// بيانات الدولة
class CountryData {
  final String code;
  final String dialCode;
  final String name;
  final String nameAr;
  final String flag;

  const CountryData({
    required this.code,
    required this.dialCode,
    required this.name,
    required this.nameAr,
    required this.flag,
  });

  static const saudiArabia = CountryData(
    code: 'SA',
    dialCode: '+966',
    name: 'Saudi Arabia',
    nameAr: 'السعودية',
    flag: '🇸🇦',
  );

  static const uae = CountryData(
    code: 'AE',
    dialCode: '+971',
    name: 'United Arab Emirates',
    nameAr: 'الإمارات',
    flag: '🇦🇪',
  );

  static const kuwait = CountryData(
    code: 'KW',
    dialCode: '+965',
    name: 'Kuwait',
    nameAr: 'الكويت',
    flag: '🇰🇼',
  );

  static const bahrain = CountryData(
    code: 'BH',
    dialCode: '+973',
    name: 'Bahrain',
    nameAr: 'البحرين',
    flag: '🇧🇭',
  );

  static const qatar = CountryData(
    code: 'QA',
    dialCode: '+974',
    name: 'Qatar',
    nameAr: 'قطر',
    flag: '🇶🇦',
  );

  static const oman = CountryData(
    code: 'OM',
    dialCode: '+968',
    name: 'Oman',
    nameAr: 'عُمان',
    flag: '🇴🇲',
  );

  static const List<CountryData> gulfCountries = [
    saudiArabia,
    uae,
    kuwait,
    bahrain,
    qatar,
    oman,
  ];
}

/// حقل إدخال رقم الجوال
class PhoneInputField extends StatefulWidget {
  final TextEditingController? controller;
  final CountryData initialCountry;
  final ValueChanged<String>? onChanged;
  final ValueChanged<CountryData>? onCountryChanged;
  final VoidCallback? onSubmitted;
  final String? errorText;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  const PhoneInputField({
    super.key,
    this.controller,
    this.initialCountry = CountryData.saudiArabia,
    this.onChanged,
    this.onCountryChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late CountryData _selectedCountry;
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerSheet(
        countries: CountryData.gulfCountries,
        selectedCountry: _selectedCountry,
        onSelect: (country) {
          setState(() => _selectedCountry = country);
          widget.onCountryChanged?.call(country);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان
        Padding(
          padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
          child: Text(
            'رقم الجوال',
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // حقل الإدخال
        Container(
          decoration: BoxDecoration(
            color: widget.enabled
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : _isFocused
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.outline,
              width: hasError || _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // زر اختيار الدولة
              InkWell(
                onTap: widget.enabled ? _showCountryPicker : null,
                borderRadius: BorderRadius.horizontal(
                  right: Directionality.of(context) == TextDirection.rtl
                      ? Radius.zero
                      : const Radius.circular(12),
                  left: Directionality.of(context) == TextDirection.rtl
                      ? const Radius.circular(12)
                      : Radius.zero,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.md,
                    vertical: AlhaiSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadiusDirectional.horizontal(
                      end: const Radius.circular(11),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // العلم
                      Text(
                        _selectedCountry.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: AlhaiSpacing.xs),
                      // مفتاح الدولة
                      Text(
                        _selectedCountry.dialCode,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.xxs),
                      // سهم
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // الفاصل
              Container(
                width: 1,
                height: 30,
                color: Theme.of(context).colorScheme.outline,
              ),

              // حقل الرقم
              Expanded(
                child: Focus(
                  onFocusChange: (focused) {
                    setState(() => _isFocused = focused);
                  },
                  child: TextField(
                    controller: _controller,
                    focusNode: widget.focusNode,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                    decoration: InputDecoration(
                      hintText: '05X XXX XXXX',
                      hintStyle: TextStyle(
                        color: isDarkMode
                            ? Colors.white38
                            : AppColors.textTertiary,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.md,
                        vertical: AlhaiSpacing.md,
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                      _PhoneNumberFormatter(),
                    ],
                    onChanged: widget.onChanged,
                    onSubmitted: (_) => widget.onSubmitted?.call(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // رسالة الخطأ
        if (hasError) ...[
          const SizedBox(height: AlhaiSpacing.xs),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// منسق رقم الجوال (05X XXX XXXX)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      // Format: 05X XXX XXXX → spaces after index 3 and 6
      if (i == 3 || i == 6) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// شاشة اختيار الدولة
class _CountryPickerSheet extends StatelessWidget {
  final List<CountryData> countries;
  final CountryData selectedCountry;
  final ValueChanged<CountryData> onSelect;

  const _CountryPickerSheet({
    required this.countries,
    required this.selectedCountry,
    required this.onSelect,
  });

  String _localizedCountryName(BuildContext context, CountryData country) {
    final l10n = AppLocalizations.of(context)!;
    switch (country.code) {
      case 'SA':
        return l10n.saudiArabia;
      case 'AE':
        return l10n.uae;
      case 'KW':
        return l10n.kuwait;
      case 'BH':
        return l10n.bahrain;
      case 'QA':
        return l10n.qatar;
      case 'OM':
        return l10n.oman;
      default:
        return country.nameAr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surface;
    final handleColor = colorScheme.outlineVariant;
    final titleColor = colorScheme.onSurface;
    final subtitleColor = colorScheme.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // المقبض
          Container(
            margin: const EdgeInsets.only(top: AlhaiSpacing.sm),
            width: AlhaiSpacing.xxl,
            height: AlhaiSpacing.dragHandleHeight,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // العنوان
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.mdl),
            child: Text(
              'اختر الدولة',
              style: TextStyle(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // قائمة الدول
          ...countries.map((country) {
            final isSelected = country.code == selectedCountry.code;
            return ListTile(
              onTap: () => onSelect(country),
              leading: Text(
                country.flag,
                style: const TextStyle(fontSize: 32),
              ),
              title: Text(
                _localizedCountryName(context, country),
                style: TextStyle(
                  color: titleColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                '${country.name} (${country.dialCode})',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                    )
                  : null,
            );
          }),

          const SizedBox(height: AlhaiSpacing.mdl),
        ],
      ),
    );
  }
}

/// زر إرسال OTP عبر واتساب
class WhatsAppOtpButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  const WhatsAppOtpButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة واتساب
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.chat_rounded,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  const Text(
                    'إرسال رمز التحقق',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
