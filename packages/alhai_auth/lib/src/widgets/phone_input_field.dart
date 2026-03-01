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
          padding: const EdgeInsets.only(bottom: 8),
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
                ? (isDarkMode ? const Color(0xFF2D3748) : Colors.white)
                : (isDarkMode ? const Color(0xFF1E293B) : AppColors.backgroundSecondary),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : _isFocused
                      ? AppColors.primary
                      : (isDarkMode ? const Color(0xFF4A5568) : AppColors.border),
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
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF374151) : AppColors.backgroundSecondary,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(11),
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
                      const SizedBox(width: 8),
                      // مفتاح الدولة
                      Text(
                        _selectedCountry.dialCode,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // سهم
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
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
                color: isDarkMode ? const Color(0xFF4A5568) : AppColors.border,
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
                        color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
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
          const SizedBox(height: 8),
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
      case 'SA': return l10n.saudiArabia;
      case 'AE': return l10n.uae;
      case 'KW': return l10n.kuwait;
      case 'BH': return l10n.bahrain;
      case 'QA': return l10n.qatar;
      case 'OM': return l10n.oman;
      default: return country.nameAr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final handleColor = isDark ? Colors.white24 : AppColors.border;
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.white70 : AppColors.textSecondary;

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
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // العنوان
          Padding(
            padding: const EdgeInsets.all(20),
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

          const SizedBox(height: 20),
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
                  const SizedBox(width: 12),
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
