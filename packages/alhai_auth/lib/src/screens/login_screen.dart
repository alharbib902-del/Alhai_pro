import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../providers/auth_providers.dart';
import '../providers/theme_provider.dart';
import '../services/whatsapp_otp_service.dart';
import '../widgets/branding/mascot_widget.dart';
import '../widgets/branding/gradient_background.dart';
import '../widgets/branding/feature_badge.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/common/language_selector.dart';

/// خطوات تسجيل الدخول (خطوتين فقط أمام المستخدم)
enum LoginStep { phone, otp }

/// شاشة تسجيل الدخول - خطوتين
///
/// 1. إدخال رقم الجوال → فحص الحساب
/// 2. إدخال رمز التحقق OTP → إكمال الدخول
///
/// في الخلفية: بعد تأكيد OTP → تسجيل دخول بالإيميل تلقائياً
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpKey = GlobalKey<OtpInputFieldState>();
  String _otpValue = '';
  bool _isLoading = false;
  bool _otpVerified = false;
  CountryData _selectedCountry = CountryData.saudiArabia;

  // === حالة الخطوات ===
  LoginStep _currentStep = LoginStep.phone;
  String? _userEmail;
  String? _userName;
  String? _storeName;

  /// رمز التحقق الثابت (للتطوير)
  static const String _devOtp = '123456';

  String? _error;
  int _remainingAttempts = 3;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber {
    var digits = _phoneController.text.replaceAll(' ', '');
    // إزالة الصفر الأول من الأرقام المحلية السعودية
    // 0500000001 → 500000001
    if (_selectedCountry.dialCode == '+966' && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return '${_selectedCountry.dialCode}$digits';
  }

  /// تحديث بيانات المستخدم في قاعدة البيانات المحلية بعد نجاح التحقق
  Future<void> _updateLocalUserOnLogin(String phone) async {
    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);
      final user = await db.usersDao.getUserByPhone(phone);
      if (user != null) {
        await db.usersDao.updateLastLogin(user.id);
        if (storeId != null) {
          await db.auditLogDao.logLogin(storeId, user.id, user.name);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('خطأ في تحديث بيانات المستخدم المحلي: $e');
      }
    }
  }

  // ==========================================================================
  // الخطوة 1: فحص رقم الجوال
  // ==========================================================================

  Future<void> _checkPhone() async {
    final l10n = AppLocalizations.of(context);
    final phoneDigits = _phoneController.text.replaceAll(' ', '');

    // التحقق من طول الرقم
    if (phoneDigits.length < 9) {
      setState(() => _error = l10n?.pleaseEnterValidPhone ?? 'يرجى إدخال رقم جوال صحيح');
      return;
    }

    // التحقق من صيغة الرقم السعودي
    if (_selectedCountry.dialCode == '+966') {
      final saudiPattern = RegExp(r'^0[5][0-9]{8}$');
      if (!saudiPattern.hasMatch(phoneDigits)) {
        setState(() => _error = l10n?.pleaseEnterValidPhone ?? 'رقم الجوال يجب أن يبدأ بـ 05 ويتكون من 10 أرقام');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // فحص الكاشير في Supabase
    final result = await ref.read(authStateProvider.notifier).checkCashierByPhone(_fullPhoneNumber);

    if (!mounted) return;

    setState(() {
      _isLoading = false;

      final exists = result['exists'] == true;
      if (!exists) {
        _error = 'لا يوجد حساب مرتبط بهذا الرقم';
        return;
      }

      final hasEmail = result['has_email'] == true;
      if (!hasEmail) {
        _error = 'الحساب غير مكتمل. يرجى مراجعة المدير لإضافة البريد الإلكتروني';
        return;
      }

      // الحساب موجود وعنده إيميل → ننتقل مباشرة لخطوة OTP
      _userEmail = result['email'] as String?;
      _userName = result['name'] as String?;
      _storeName = result['store_name'] as String?;
      _currentStep = LoginStep.otp;
      _error = null;
    });

    // عرض رسالة الترحيب
    if (_currentStep == LoginStep.otp && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('مرحباً ${_userName ?? ''}! أدخل رمز التحقق'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ==========================================================================
  // الخطوة 2: التحقق من OTP + دخول بالإيميل في الخلفية
  // ==========================================================================

  Future<void> _verifyOtp([String? otp]) async {
    final l10n = AppLocalizations.of(context);
    final otpToVerify = otp ?? _otpValue;

    if (otpToVerify.length < 6) {
      setState(() => _error = l10n?.enterOtpFully ?? 'يرجى إدخال رمز التحقق كاملاً');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // التحقق من الرمز الثابت (للتطوير)
    if (otpToVerify == _devOtp) {
      if (kDebugMode) {
        debugPrint('✅ OTP verified (dev mode): $_devOtp');
      }

      // === إنشاء جلسة محلية (مطلوب لـ Router Guard) ===
      final authNotifier = ref.read(authStateProvider.notifier);

      // محاولة الدخول بالإيميل في الخلفية (Supabase)
      bool supabaseSignedIn = false;
      if (_userEmail != null) {
        try {
          if (kDebugMode) {
            debugPrint('🔐 Background sign-in with email: $_userEmail');
          }
          final signInResult = await authNotifier.signInWithEmailPassword(
            email: _userEmail!,
            password: _devOtp,
          );
          supabaseSignedIn = signInResult.success;
          if (kDebugMode) {
            debugPrint('🔐 Background sign-in result: $supabaseSignedIn');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Background sign-in failed: $e');
          }
        }
      }

      // لو Supabase ما نجح → ننشئ جلسة محلية عبر verifyLocalOtp
      if (!supabaseSignedIn) {
        if (kDebugMode) {
          debugPrint('📝 Creating local session...');
        }
        await authNotifier.verifyLocalOtp(
          phone: _fullPhoneNumber,
          otpResult: WhatsAppOtpVerifyResult.success(),
        );
      }

      // تحديث بيانات المستخدم المحلي
      await _updateLocalUserOnLogin(_fullPhoneNumber);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _otpVerified = true;
      });

      // الانتقال لاختيار المتجر
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.go('/store-select');
      });
      return;
    }

    // الرمز غير صحيح
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _remainingAttempts--;
      if (_remainingAttempts <= 0) {
        _error = l10n?.maxAttemptsReached ?? 'تم تجاوز الحد الأقصى. يرجى المحاولة لاحقاً';
        _otpValue = '';
        _otpKey.currentState?.clear();
        _remainingAttempts = 3;
      } else {
        _error = 'رمز التحقق غير صحيح';
      }
    });
  }

  /// الرجوع لخطوة الهاتف
  void _goBack() {
    setState(() {
      _error = null;
      _currentStep = LoginStep.phone;
      _otpValue = '';
      _otpKey.currentState?.clear();
      _remainingAttempts = 3;
      _otpVerified = false;
      _userEmail = null;
      _userName = null;
      _storeName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = context.isDesktop;

    return Scaffold(
      body: isWideScreen ? _buildWideLayout() : _buildNarrowLayout(),
    );
  }

  /// تخطيط للشاشات العريضة (Desktop/Tablet)
  Widget _buildWideLayout() {
    return Row(
      children: [
        // الجانب الأيسر - الخلفية مع الـ Mascot
        Expanded(
          flex: 5,
          child: LoginBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.point_of_sale_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Al-Hal POS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const MascotWidget(
                              size: MascotSize.medium,
                              pose: MascotPose.waving,
                              animate: true,
                            ),
                            const SizedBox(height: 32),
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return Column(
                                  children: [
                                    Text(
                                      l10n?.welcomeTitle ?? 'مرحباً بك مجدداً! 👋',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      l10n?.welcomeSubtitle ?? 'سجّل دخولك لإدارة متجرك',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 40),
                            const FeatureBadgesRow(
                              types: [
                                FeatureBadgeType.fast,
                                FeatureBadgeType.secure,
                                FeatureBadgeType.cloud,
                              ],
                              compact: true,
                              light: true,
                              spacing: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // الجانب الأيمن - نموذج تسجيل الدخول
        Expanded(
          flex: 4,
          child: _buildLoginForm(),
        ),
      ],
    );
  }

  /// تخطيط للشاشات الضيقة (Mobile)
  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          LoginBackground(
            height: 280,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MascotWidget(
                    size: MascotSize.medium,
                    pose: MascotPose.waving,
                    animate: true,
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return Column(
                        children: [
                          Text(
                            l10n?.welcomeTitle ?? 'مرحباً بك مجدداً! 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n?.welcomeSubtitleShort ?? 'سجّل دخولك لإدارة متجرك',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          _buildLoginForm(isMobile: true),
        ],
      ),
    );
  }

  /// نموذج تسجيل الدخول
  Widget _buildLoginForm({bool isMobile = false}) {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 24 : 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // زر اللغة والوضع الليلي
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const LanguageSelectorButton(showLabel: true, compact: false),
                    IconButton(
                      onPressed: () => ref.read(themeProvider.notifier).toggleDarkMode(),
                      icon: Icon(
                        isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                      ),
                      tooltip: isDarkMode
                          ? (l10n?.dayMode ?? 'الوضع النهاري')
                          : (l10n?.nightMode ?? 'الوضع الليلي'),
                    ),
                  ],
                ),

                SizedBox(height: isMobile ? 24 : 48),

                // مؤشر الخطوات + العنوان
                _buildStepHeader(),

                const SizedBox(height: 32),

                // محتوى الخطوة الحالية
                _buildCurrentStepContent(),

                const SizedBox(height: 24),

                // زر الإجراء
                _buildActionButton(),

                // أزرار إضافية (رجوع)
                _buildStepActions(),

                SizedBox(height: isMobile ? 32 : 48),

                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// عنوان الخطوة الحالية
  Widget _buildStepHeader() {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    String title;
    String subtitle;

    switch (_currentStep) {
      case LoginStep.phone:
        title = l10n?.login ?? 'تسجيل الدخول';
        subtitle = l10n?.enterPhoneToContinue ?? 'أدخل رقم جوالك للمتابعة';
      case LoginStep.otp:
        title = 'رمز التحقق';
        subtitle = _storeName != null
            ? '🏪 $_storeName'
            : 'أدخل رمز التحقق للمتابعة';
    }

    // مؤشر الخطوات (نقطتين)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (int i = 0; i < 2; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Container(
                width: i == _currentStep.index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i <= _currentStep.index
                      ? AppColors.primary
                      : (isDarkMode ? Colors.white24 : AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  /// محتوى الخطوة الحالية
  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case LoginStep.phone:
        return _buildPhoneStep();
      case LoginStep.otp:
        return _buildOtpStep();
    }
  }

  /// الخطوة 1: حقل الهاتف
  Widget _buildPhoneStep() {
    return PhoneInputField(
      controller: _phoneController,
      initialCountry: _selectedCountry,
      enabled: !_isLoading,
      errorText: _error,
      onCountryChanged: (country) {
        setState(() => _selectedCountry = country);
      },
      onSubmitted: _checkPhone,
    );
  }

  /// الخطوة 2: حقل OTP
  Widget _buildOtpStep() {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // رقم الجوال (قراءة فقط)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
            border: Border.all(
              color: isDarkMode ? Colors.white12 : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.phone_android_rounded,
                color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    _phoneController.text,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Text(
                _selectedCountry.flag,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          l10n?.verificationCode ?? 'رمز التحقق',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        OtpInputField(
          key: _otpKey,
          onCompleted: (otp) {
            _otpValue = otp;
            _verifyOtp(otp);
          },
          onChanged: (value) {
            setState(() {
              _otpValue = value;
              if (_error != null && value.isNotEmpty) _error = null;
            });
          },
          isError: _error != null,
          isSuccess: _otpVerified,
          enabled: !_isLoading,
        ),

        // رسالة الخطأ
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],

        // حالة النجاح
        if (_otpVerified) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تم التحقق بنجاح! جاري الدخول...',
                    style: TextStyle(color: AppColors.success, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],

        // المحاولات المتبقية
        if (_remainingAttempts < 3 && _remainingAttempts > 0 && !_otpVerified) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n?.remainingAttempts(_remainingAttempts) ?? 'المحاولات المتبقية: $_remainingAttempts',
              style: TextStyle(
                color: _remainingAttempts == 1 ? AppColors.error : AppColors.warning,
                fontSize: 12,
              ),
            ),
          ),
        ],

        // تلميح رمز التطوير
        if (kDebugMode) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.developer_mode_rounded, color: AppColors.info, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'وضع التطوير - الرمز: $_devOtp',
                    style: const TextStyle(color: AppColors.info, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: AppColors.info, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: _devOtp));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم نسخ الرمز'),
                        backgroundColor: AppColors.info,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// زر الإجراء الرئيسي حسب الخطوة
  Widget _buildActionButton() {
    final l10n = AppLocalizations.of(context);

    switch (_currentStep) {
      case LoginStep.phone:
        return ElevatedButton(
          onPressed: _isLoading ? null : _checkPhone,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  l10n?.next ?? 'التالي',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        );

      case LoginStep.otp:
        return ElevatedButton.icon(
          onPressed: _isLoading || _otpVerified ? null : () => _verifyOtp(),
          icon: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.verified_user_rounded),
          label: Text(
            _otpVerified
                ? 'تم التحقق ✓'
                : 'تحقق',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _otpVerified ? AppColors.success : AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        );
    }
  }

  /// أزرار إضافية (رجوع)
  Widget _buildStepActions() {
    final l10n = AppLocalizations.of(context);

    if (_currentStep == LoginStep.phone) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: TextButton(
          onPressed: _isLoading ? null : _goBack,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                l10n?.changeNumber ?? 'تغيير الرقم',
                style: const TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Footer مع روابط وأيقونات
  Widget _buildFooter() {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final footerTextColor = isDarkMode ? Colors.white70 : AppColors.textSecondary;
    final footerDotColor = isDarkMode ? Colors.white38 : AppColors.textTertiary;

    return Column(
      children: [
        if (!context.isDesktop) ...[
          const FeatureBadgesRow(
            types: [FeatureBadgeType.fast, FeatureBadgeType.secure, FeatureBadgeType.cloud],
            compact: true,
            light: false,
            spacing: 12,
          ),
          const SizedBox(height: 16),
        ],
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 4,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.support_agent_rounded, size: 16, color: footerTextColor),
              label: Text(
                l10n?.technicalSupport ?? 'الدعم الفني',
                style: TextStyle(color: footerTextColor, fontSize: 13),
              ),
            ),
            Text('•', style: TextStyle(color: footerDotColor)),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.privacy_tip_outlined, size: 16, color: footerTextColor),
              label: Text(
                l10n?.privacyPolicy ?? 'سياسة الخصوصية',
                style: TextStyle(color: footerTextColor, fontSize: 13),
              ),
            ),
            Text('•', style: TextStyle(color: footerDotColor)),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.description_outlined, size: 16, color: footerTextColor),
              label: Text(
                l10n?.termsAndConditions ?? 'الشروط والأحكام',
                style: TextStyle(color: footerTextColor, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            border: isDarkMode
                ? null
                : Border(top: BorderSide(color: Theme.of(context).colorScheme.surfaceContainerLow)),
          ),
          child: Text(
            'جميع الحقوق محفوظة © 2026 نظام الحي الذكي',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
