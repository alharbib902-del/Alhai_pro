import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _userPassword;
  String? _userName;
  String? _storeName;

  /// رمز التحقق الثابت (للتطوير)
  static const String _devOtp = '123456';

  String? _error;
  int _remainingAttempts = _maxAttempts;

  // === OTP Lockout ===
  static const String _lockoutKey = 'otp_lockout_until';
  static const int _maxAttempts = 3;
  static const Duration _lockoutDuration = Duration(minutes: 5);
  bool _isLockedOut = false;
  DateTime? _lockoutUntil;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _checkLockoutStatus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  /// فحص حالة القفل عند فتح الشاشة (يمنع التحايل بإعادة التحميل)
  Future<void> _checkLockoutStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockoutStr = prefs.getString(_lockoutKey);
      if (lockoutStr != null) {
        final lockoutTime = DateTime.tryParse(lockoutStr);
        if (lockoutTime != null && lockoutTime.isAfter(DateTime.now())) {
          if (mounted) {
            setState(() {
              _isLockedOut = true;
              _lockoutUntil = lockoutTime;
              _remainingAttempts = 0;
            });
            _startLockoutTimer();
          }
        } else {
          // انتهت مدة القفل → حذف
          await prefs.remove(_lockoutKey);
        }
      }
    } catch (_) {}
  }

  /// تفعيل القفل المؤقت بعد 3 محاولات خاطئة
  Future<void> _activateLockout() async {
    final until = DateTime.now().add(_lockoutDuration);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lockoutKey, until.toIso8601String());
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _isLockedOut = true;
      _lockoutUntil = until;
      _error =
          'تم تجاوز الحد الأقصى للمحاولات.\nيرجى الانتظار ${_lockoutDuration.inMinutes} دقائق ثم المحاولة مجدداً.';
      _otpValue = '';
      _otpKey.currentState?.clear();
    });

    _startLockoutTimer();

    // الرجوع لشاشة إدخال الرقم بعد ثانيتين
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _goBack();
    });
  }

  /// بدء مؤقت العد التنازلي لإنهاء القفل
  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutUntil == null || DateTime.now().isAfter(_lockoutUntil!)) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isLockedOut = false;
            _lockoutUntil = null;
            _remainingAttempts = _maxAttempts;
            _error = null;
          });
          // حذف القفل من التخزين
          SharedPreferences.getInstance()
              .then((prefs) => prefs.remove(_lockoutKey));
        }
      } else {
        if (mounted) setState(() {}); // تحديث العد التنازلي في UI
      }
    });
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

    // منع المحاولة أثناء القفل
    if (_isLockedOut) {
      final remaining = _lockoutUntil?.difference(DateTime.now());
      final mins = (remaining?.inSeconds ?? 300) ~/ 60 + 1;
      setState(() {
        _error = 'تم تجاوز الحد الأقصى للمحاولات. انتظر $mins دقائق';
      });
      return;
    }

    final phoneDigits = _phoneController.text.replaceAll(' ', '');

    // التحقق من طول الرقم
    if (phoneDigits.length < 9) {
      setState(() =>
          _error = l10n?.pleaseEnterValidPhone ?? 'يرجى إدخال رقم جوال صحيح');
      return;
    }

    // التحقق من صيغة الرقم السعودي
    if (_selectedCountry.dialCode == '+966') {
      final saudiPattern = RegExp(r'^0[5][0-9]{8}$');
      if (!saudiPattern.hasMatch(phoneDigits)) {
        setState(() => _error = l10n?.pleaseEnterValidPhone ??
            'رقم الجوال يجب أن يبدأ بـ 05 ويتكون من 10 أرقام');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // فحص الكاشير في Supabase
    final result = await ref
        .read(authStateProvider.notifier)
        .checkCashierByPhone(_fullPhoneNumber);

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
        _error =
            'الحساب غير مكتمل. يرجى مراجعة المدير لإضافة البريد الإلكتروني';
        return;
      }

      // الحساب موجود وعنده إيميل → ننتقل مباشرة لخطوة OTP
      _userEmail = result['email'] as String?;
      _userPassword = result['password'] as String?;
      _userName = result['name'] as String?;
      _storeName = result['store_name'] as String?;
      if (kDebugMode) {
        debugPrint(
            '📧 Email: $_userEmail, Password: ${_userPassword != null ? "✅ found" : "❌ missing"}');
      }
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

    // منع المحاولة أثناء القفل
    if (_isLockedOut) {
      final remaining = _lockoutUntil?.difference(DateTime.now());
      final mins = (remaining?.inSeconds ?? 300) ~/ 60 + 1;
      setState(() {
        _error = 'الرقم مقفل مؤقتاً. انتظر $mins دقائق';
      });
      return;
    }

    if (otpToVerify.length < 6) {
      setState(
          () => _error = l10n?.enterOtpFully ?? 'يرجى إدخال رمز التحقق كاملاً');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // التحقق من الرمز الثابت (للتطوير فقط)
    if (kDebugMode && otpToVerify == _devOtp) {
      if (kDebugMode) {
        debugPrint('✅ OTP verified (dev mode): $_devOtp');
      }

      // === إنشاء جلسة محلية (مطلوب لـ Router Guard) ===
      final authNotifier = ref.read(authStateProvider.notifier);

      // محاولة الدخول بالإيميل في الخلفية (Supabase)
      // يستخدم الباسورد المستخرج من check_cashier_by_phone RPC
      bool supabaseSignedIn = false;
      final signInPassword = _userPassword ?? _devOtp;
      if (_userEmail != null) {
        try {
          debugPrint(
              '🔐 Supabase sign-in: email=$_userEmail, password=${_userPassword != null ? "from DB" : "dev fallback"}');
          final signInResult = await authNotifier.signInWithEmailPassword(
            email: _userEmail!,
            password: signInPassword,
          );
          supabaseSignedIn = signInResult.success;
          debugPrint(
              '🔐 Supabase sign-in result: ${supabaseSignedIn ? "✅ SUCCESS" : "❌ FAILED: ${signInResult.error}"}');
        } catch (e) {
          debugPrint('⚠️ Supabase sign-in exception: $e');
        }
      } else {
        debugPrint('⚠️ No email found — cannot sign in to Supabase');
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

    _remainingAttempts--;

    if (_remainingAttempts <= 0) {
      // === قفل مؤقت بعد 3 محاولات خاطئة ===
      setState(() => _isLoading = false);
      await _activateLockout();
    } else {
      setState(() {
        _isLoading = false;
        _error = 'رمز التحقق غير صحيح';
      });
    }
  }

  /// الرجوع لخطوة الهاتف
  void _goBack() {
    setState(() {
      _error = _isLockedOut ? _error : null; // إبقاء رسالة القفل
      _currentStep = LoginStep.phone;
      _otpValue = '';
      _otpKey.currentState?.clear();
      if (!_isLockedOut) _remainingAttempts = _maxAttempts;
      _otpVerified = false;
      _userEmail = null;
      _userPassword = null;
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
                    padding: const EdgeInsets.all(AlhaiSpacing.lg),
                    child: Row(
                      children: [
                        Container(
                          width: AlhaiSpacing.xxl,
                          height: AlhaiSpacing.xxl,
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
                        const SizedBox(width: AlhaiSpacing.sm),
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
                        padding: const EdgeInsets.all(AlhaiSpacing.xxxl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const MascotWidget(
                              size: MascotSize.medium,
                              pose: MascotPose.waving,
                              animate: true,
                            ),
                            const SizedBox(height: AlhaiSpacing.xl),
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return Column(
                                  children: [
                                    Text(
                                      l10n?.welcomeTitle ??
                                          'مرحباً بك مجدداً! 👋',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: AlhaiSpacing.sm),
                                    Text(
                                      l10n?.welcomeSubtitle ??
                                          'سجّل دخولك لإدارة متجرك',
                                      style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: AlhaiSpacing.xxl),
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
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const MascotWidget(
                        size: MascotSize.small,
                        pose: MascotPose.waving,
                        animate: true,
                      ),
                      const SizedBox(height: AlhaiSpacing.md),
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
                              const SizedBox(height: AlhaiSpacing.xs),
                              Text(
                                l10n?.welcomeSubtitleShort ??
                                    'سجّل دخولك لإدارة متجرك',
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
    // استخدام Theme.of(context) بدل Riverpod لضمان التطابق مع حقول الإدخال
    // Riverpod isDarkMode لا يحسب ThemeMode.system → عدم تطابق مع Theme.of(context)
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.all(isMobile ? AlhaiSpacing.lg : AlhaiSpacing.xxxl),
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
                    const LanguageSelectorButton(
                        showLabel: true, compact: false),
                    IconButton(
                      onPressed: () =>
                          ref.read(themeProvider.notifier).toggleDarkMode(),
                      icon: Icon(
                        isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: isDarkMode
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                      tooltip: isDarkMode
                          ? (l10n?.dayMode ?? 'الوضع النهاري')
                          : (l10n?.nightMode ?? 'الوضع الليلي'),
                    ),
                  ],
                ),

                SizedBox(
                    height: isMobile ? AlhaiSpacing.lg : AlhaiSpacing.xxxl),

                // مؤشر الخطوات + العنوان
                _buildStepHeader(),

                const SizedBox(height: AlhaiSpacing.xl),

                // محتوى الخطوة الحالية
                _buildCurrentStepContent(),

                const SizedBox(height: AlhaiSpacing.lg),

                // زر الإجراء
                _buildActionButton(),

                // أزرار إضافية (رجوع)
                _buildStepActions(),

                SizedBox(
                    height: isMobile ? AlhaiSpacing.xl : AlhaiSpacing.xxxl),

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
        subtitle =
            _storeName != null ? '🏪 $_storeName' : 'أدخل رمز التحقق للمتابعة';
    }

    // مؤشر الخطوات (نقطتين)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (int i = 0; i < 2; i++) ...[
              if (i > 0) const SizedBox(width: AlhaiSpacing.xs),
              Container(
                width:
                    i == _currentStep.index ? AlhaiSpacing.lg : AlhaiSpacing.xs,
                height: AlhaiSpacing.xs,
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
        const SizedBox(height: AlhaiSpacing.lg),
        Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
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
          padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md, vertical: 14),
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
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    _phoneController.text,
                    style: TextStyle(
                      color:
                          isDarkMode ? Colors.white70 : AppColors.textSecondary,
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

        const SizedBox(height: AlhaiSpacing.lg),

        Text(
          l10n?.verificationCode ?? 'رمز التحقق',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),

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
          const SizedBox(height: AlhaiSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 20),
                const SizedBox(width: AlhaiSpacing.xs),
                Expanded(
                  child: Text(
                    _error!,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],

        // حالة النجاح
        if (_otpVerified) ...[
          const SizedBox(height: AlhaiSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.success, size: 20),
                SizedBox(width: AlhaiSpacing.xs),
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
        if (_remainingAttempts < 3 &&
            _remainingAttempts > 0 &&
            !_otpVerified) ...[
          const SizedBox(height: AlhaiSpacing.xs),
          Center(
            child: Text(
              l10n?.remainingAttempts(_remainingAttempts) ??
                  'المحاولات المتبقية: $_remainingAttempts',
              style: TextStyle(
                color: _remainingAttempts == 1
                    ? AppColors.error
                    : AppColors.warning,
                fontSize: 12,
              ),
            ),
          ),
        ],

        // تلميح رمز التطوير
        if (kDebugMode) ...[
          const SizedBox(height: AlhaiSpacing.md),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.developer_mode_rounded,
                    color: AppColors.info, size: 18),
                const SizedBox(width: AlhaiSpacing.xs),
                Expanded(
                  child: Text(
                    'وضع التطوير - الرمز: $_devOtp',
                    style: const TextStyle(color: AppColors.info, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded,
                      color: AppColors.info, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: _devOtp));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم نسخ الرمز'),
                        backgroundColor: AppColors.info,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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
            padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  l10n?.next ?? 'التالي',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
        );

      case LoginStep.otp:
        return ElevatedButton.icon(
          onPressed: _isLoading || _otpVerified ? null : () => _verifyOtp(),
          icon: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.verified_user_rounded),
          label: Text(
            _otpVerified ? 'تم التحقق ✓' : 'تحقق',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _otpVerified ? AppColors.success : AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      padding: const EdgeInsets.only(top: AlhaiSpacing.md),
      child: Center(
        child: TextButton(
          onPressed: _isLoading ? null : _goBack,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back_rounded,
                  size: 16, color: AppColors.primary),
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
    final footerTextColor =
        isDarkMode ? Colors.white70 : AppColors.textSecondary;
    final footerDotColor = isDarkMode ? Colors.white38 : AppColors.textTertiary;

    return Column(
      children: [
        if (!context.isDesktop) ...[
          const FeatureBadgesRow(
            types: [
              FeatureBadgeType.fast,
              FeatureBadgeType.secure,
              FeatureBadgeType.cloud
            ],
            compact: true,
            light: false,
            spacing: 12,
          ),
          const SizedBox(height: AlhaiSpacing.md),
        ],
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 4,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.support_agent_rounded,
                  size: 16, color: footerTextColor),
              label: Text(
                l10n?.technicalSupport ?? 'الدعم الفني',
                style: TextStyle(color: footerTextColor, fontSize: 13),
              ),
            ),
            Text('•', style: TextStyle(color: footerDotColor)),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.privacy_tip_outlined,
                  size: 16, color: footerTextColor),
              label: Text(
                l10n?.privacyPolicy ?? 'سياسة الخصوصية',
                style: TextStyle(color: footerTextColor, fontSize: 13),
              ),
            ),
            Text('•', style: TextStyle(color: footerDotColor)),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.description_outlined,
                  size: 16, color: footerTextColor),
              label: Text(
                l10n?.termsAndConditions ?? 'الشروط والأحكام',
                style: TextStyle(color: footerTextColor, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            border: isDarkMode
                ? null
                : Border(
                    top: BorderSide(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerLow)),
          ),
          child: Text(
            'جميع الحقوق محفوظة © 2026 نظام الحي الذكي',
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white70
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
