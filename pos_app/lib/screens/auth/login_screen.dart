import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/local/app_database.dart';
import '../../di/injection.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_providers.dart';
import '../../providers/products_providers.dart';
import '../../providers/theme_provider.dart';
import '../../services/whatsapp_otp_service.dart';
import '../../widgets/branding/mascot_widget.dart';
import '../../widgets/branding/gradient_background.dart';
import '../../widgets/branding/feature_badge.dart';
import '../../widgets/auth/phone_input_field.dart';
import '../../widgets/auth/otp_input_field.dart';
import '../../widgets/common/language_selector.dart';

/// شاشة تسجيل الدخول بـ OTP عبر WhatsApp
///
/// تسمح للمستخدم بإدخال رقم الجوال واستلام رمز التحقق عبر WhatsApp
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpKey = GlobalKey<OtpInputFieldState>();
  String _otpValue = '';
  bool _otpSent = false;
  bool _isLoading = false;
  bool _otpVerified = false;
  CountryData _selectedCountry = CountryData.saudiArabia;

  String? _error;
  int _remainingAttempts = 3;
  Duration _resendCooldown = Duration.zero;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final cooldown = WhatsAppOtpService.getCooldownRemaining(
          '${_selectedCountry.dialCode}${_phoneController.text.replaceAll(' ', '')}',
        );
        setState(() {
          _resendCooldown = cooldown ?? Duration.zero;
        });
        if (_resendCooldown == Duration.zero) {
          _cooldownTimer?.cancel();
        }
      }
    });
  }

  String get _fullPhoneNumber {
    return '${_selectedCountry.dialCode}${_phoneController.text.replaceAll(' ', '')}';
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

  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context);
    final phoneDigits = _phoneController.text.replaceAll(' ', '');
    if (phoneDigits.length < 9) {
      setState(() => _error = l10n?.pleaseEnterValidPhone ?? 'يرجى إدخال رقم جوال صحيح');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Try Supabase OTP first
    final supabaseSent = await ref.read(authStateProvider.notifier).sendSupabaseOtp(_fullPhoneNumber);

    if (supabaseSent && mounted) {
      setState(() {
        _isLoading = false;
        _otpSent = true;
        _startCooldownTimer();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.otpSentViaWhatsApp ?? 'تم إرسال رمز التحقق'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Fallback to WhatsApp OTP
    final result = await WhatsAppOtpService.sendOtp(
      phone: _fullPhoneNumber,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _otpSent = true;
        _startCooldownTimer();

        // في وضع التطوير: عرض OTP في SnackBar مع زر نسخ
        if (result.devOtp != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n?.devOtpMessage(result.devOtp!) ?? 'رمز التطوير: ${result.devOtp}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: Colors.white),
                    tooltip: l10n?.copyCode ?? 'نسخ',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result.devOtp!));
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ],
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n?.otpSentViaWhatsApp ?? 'تم إرسال رمز التحقق عبر WhatsApp'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        _error = result.error;
        if (result.blockedUntil != null) {
          final remaining = result.blockedUntil!.difference(DateTime.now());
          _error = l10n?.waitMinutes(remaining.inMinutes) ?? 'تم تجاوز الحد الأقصى. انتظر ${remaining.inMinutes} دقيقة';
        } else if (result.cooldown != null) {
          _error = l10n?.waitSeconds(result.cooldown!.inSeconds) ?? 'يرجى الانتظار ${result.cooldown!.inSeconds} ثانية';
        }
      }
    });
  }

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

    // Try Supabase verification first
    final supabaseVerified = await ref.read(authStateProvider.notifier).verifySupabaseOtp(
      phone: _fullPhoneNumber,
      otp: otpToVerify,
    );

    if (supabaseVerified && mounted) {
      // تحديث بيانات المستخدم في قاعدة البيانات المحلية
      await _updateLocalUserOnLogin(_fullPhoneNumber);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _otpVerified = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go('/store-select');
        }
      });
      return;
    }

    // Fallback to WhatsApp OTP verification
    final result = await WhatsAppOtpService.verifyOtp(
      phone: _fullPhoneNumber,
      otp: otpToVerify,
    );

    if (!mounted) return;

    // تحديث حالة المصادقة عبر AuthNotifier
    if (result.isSuccess) {
      await ref.read(authStateProvider.notifier).verifyLocalOtp(
        phone: _fullPhoneNumber,
        otpResult: result,
      );
      // تحديث بيانات المستخدم في قاعدة البيانات المحلية
      await _updateLocalUserOnLogin(_fullPhoneNumber);
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _otpVerified = true;
        // انتظر قليلاً لإظهار حالة النجاح
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/store-select');
          }
        });
      } else {
        _error = result.error;
        _remainingAttempts = result.remainingAttempts ?? 0;
        if (result.remainingAttempts == 0) {
          _otpSent = false;
          _otpValue = '';
          _otpKey.currentState?.clear();
          _error = l10n?.maxAttemptsReached ?? 'تم تجاوز الحد الأقصى. يرجى طلب رمز جديد';
        }
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > Duration.zero) return;

    final l10n = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await WhatsAppOtpService.resendOtp(
      phone: _fullPhoneNumber,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _startCooldownTimer();
        _remainingAttempts = 3;
        _error = null;
        _otpValue = '';
        _otpKey.currentState?.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.otpResent ?? 'تم إعادة إرسال رمز التحقق'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        _error = result.error;
      }
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;

    return Scaffold(
      body: isWideScreen
          ? _buildWideLayout()
          : _buildNarrowLayout(),
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
                  // شعار Al-Hal POS في الأعلى
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

                  // المحتوى المركزي
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // الـ Mascot - حجم أصغر لإظهار العناصر تحته
                            const MascotWidget(
                              size: MascotSize.medium,
                              pose: MascotPose.waving,
                              animate: true,
                            ),

                            const SizedBox(height: 32),

                            // النص الترحيبي
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
                                      l10n?.welcomeSubtitle ??
                                          'سجّل دخولك لإدارة متجرك بسهولة وسرعة',
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

                            // شارات المميزات
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
          // الهيدر مع الـ Mascot
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
                            l10n?.welcomeTitle ?? 'مرحباً بك في نظام الحل',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n?.welcomeSubtitleShort ?? 'نظام نقاط البيع المتكامل',
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

          // نموذج تسجيل الدخول
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
                // زر الوضع الليلي واللغة (في الأعلى)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // اختيار اللغة - الآن ديناميكي
                    const LanguageSelectorButton(
                      showLabel: true,
                      compact: false,
                    ),

                    // زر الوضع الليلي
                    IconButton(
                      onPressed: () {
                        ref.read(themeProvider.notifier).toggleDarkMode();
                      },
                      icon: Icon(
                        isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                      ),
                      tooltip: isDarkMode
                          ? (l10n?.dayMode ?? 'الوضع النهاري')
                          : (l10n?.nightMode ?? 'الوضع الليلي'),
                    ),
                  ],
                ),

                SizedBox(height: isMobile ? 24 : 48),

                // العنوان
                Text(
                  l10n?.login ?? 'تسجيل الدخول',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n?.enterPhoneToContinue ?? 'أدخل رقم جوالك للمتابعة',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 32),

                // حقل رقم الجوال
                PhoneInputField(
                  controller: _phoneController,
                  initialCountry: _selectedCountry,
                  enabled: !_otpSent,
                  errorText: !_otpSent ? _error : null,
                  onCountryChanged: (country) {
                    setState(() => _selectedCountry = country);
                  },
                  onSubmitted: _otpSent ? null : _sendOtp,
                ),

                if (_otpSent) ...[
                  const SizedBox(height: 24),

                  // حقل رمز التحقق
                  _buildOtpField(),
                ],

                const SizedBox(height: 24),

                // زر الإرسال/التحقق
                WhatsAppOtpButton(
                  onPressed: _otpSent ? _verifyOtp : _sendOtp,
                  isLoading: _isLoading,
                  enabled: !_isLoading,
                ),

                if (_otpSent) ...[
                  const SizedBox(height: 16),

                  // أزرار إعادة الإرسال وتغيير الرقم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _resendCooldown > Duration.zero || _isLoading
                            ? null
                            : _resendOtp,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: _resendCooldown > Duration.zero
                                  ? AppColors.textTertiary
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _resendCooldown > Duration.zero
                                  ? (l10n?.resendIn(_formatDuration(_resendCooldown)) ?? 'إعادة الإرسال (${_formatDuration(_resendCooldown)})')
                                  : (l10n?.resendCode ?? 'إعادة إرسال الرمز'),
                              style: TextStyle(
                                color: _resendCooldown > Duration.zero
                                    ? AppColors.textTertiary
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _otpSent = false;
                                  _otpValue = '';
                                  _otpVerified = false;
                                  _error = null;
                                  _remainingAttempts = 3;
                                });
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n?.changeNumber ?? 'تغيير الرقم',
                              style: const TextStyle(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: isMobile ? 32 : 48),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// حقل رمز التحقق - 6 خانات منفصلة
  Widget _buildOtpField() {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.verificationCode ?? 'رمز التحقق',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // 6 خانات منفصلة مع التحقق التلقائي
        OtpInputField(
          key: _otpKey,
          onCompleted: (otp) {
            _otpValue = otp;
            // التحقق التلقائي عند إكمال الإدخال
            _verifyOtp(otp);
          },
          onChanged: (value) {
            setState(() {
              _otpValue = value;
              // مسح الخطأ عند بدء الكتابة
              if (_error != null && value.isNotEmpty) {
                _error = null;
              }
            });
          },
          isError: _error != null,
          isSuccess: _otpVerified,
          enabled: !_isLoading,
        ),

        // رسالة الخطأ
        if (_error != null && _otpSent) ...[
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
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
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
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تم التحقق بنجاح',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 13,
                    ),
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
                color: _remainingAttempts == 1
                    ? AppColors.error
                    : AppColors.warning,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
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
        // شعارات المميزات (للموبايل فقط)
        if (MediaQuery.of(context).size.width <= 900) ...[
          const FeatureBadgesRow(
            types: [
              FeatureBadgeType.fast,
              FeatureBadgeType.secure,
              FeatureBadgeType.cloud,
            ],
            compact: true,
            light: false,
            spacing: 12,
          ),
          const SizedBox(height: 16),
        ],

        // الروابط مع أيقونات
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 4,
          children: [
            // الدعم الفني
            TextButton.icon(
              onPressed: () {
                // TODO: Open support page
              },
              icon: Icon(
                Icons.support_agent_rounded,
                size: 16,
                color: footerTextColor,
              ),
              label: Text(
                l10n?.technicalSupport ?? 'الدعم الفني',
                style: TextStyle(
                  color: footerTextColor,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '•',
              style: TextStyle(color: footerDotColor),
            ),
            // سياسة الخصوصية
            TextButton.icon(
              onPressed: () {
                // TODO: Open privacy policy
              },
              icon: Icon(
                Icons.privacy_tip_outlined,
                size: 16,
                color: footerTextColor,
              ),
              label: Text(
                l10n?.privacyPolicy ?? 'سياسة الخصوصية',
                style: TextStyle(
                  color: footerTextColor,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '•',
              style: TextStyle(color: footerDotColor),
            ),
            // الشروط والأحكام
            TextButton.icon(
              onPressed: () {
                // TODO: Open terms
              },
              icon: Icon(
                Icons.description_outlined,
                size: 16,
                color: footerTextColor,
              ),
              label: Text(
                l10n?.termsAndConditions ?? 'الشروط والأحكام',
                style: TextStyle(
                  color: footerTextColor,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // حقوق النشر - يدعم الوضع الفاتح والداكن
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? const Color(0xFF0F172A) // Slate-900 للداكن
                : const Color(0xFFF1F5F9), // Slate-100 للفاتح
            border: isDarkMode 
                ? null 
                : Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Text(
            'جميع الحقوق محفوظة © 2026 نظام الحي الذكي',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
