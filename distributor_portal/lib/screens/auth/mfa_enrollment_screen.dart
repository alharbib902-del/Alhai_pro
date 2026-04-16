/// MFA Enrollment Screen - TOTP setup wizard.
///
/// Flow: Intro → Scan QR → Verify Code → Backup Codes → Done.
/// Only accessible to super_admin users from Settings.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../core/utils/web_download.dart'
    if (dart.library.io) '../../core/utils/web_download_stub.dart';
import '../../data/services/mfa_service.dart';
import '../../providers/mfa_providers.dart';

/// Steps in the enrollment wizard.
enum _EnrollStep { intro, scan, verify, backupCodes, done }

class MfaEnrollmentScreen extends ConsumerStatefulWidget {
  const MfaEnrollmentScreen({super.key});

  @override
  ConsumerState<MfaEnrollmentScreen> createState() =>
      _MfaEnrollmentScreenState();
}

class _MfaEnrollmentScreenState extends ConsumerState<MfaEnrollmentScreen> {
  _EnrollStep _step = _EnrollStep.intro;
  EnrollmentData? _enrollment;
  List<String>? _backupCodes;
  final _codeController = TextEditingController();
  bool _codesSaved = false;
  bool _isLoading = false;
  String? _error;
  int _verifyAttempts = 0;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _startEnrollment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(mfaServiceProvider);
      _enrollment = await service.startEnrollment();
      if (!mounted) return;
      setState(() {
        _step = _EnrollStep.scan;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'حدث خطأ أثناء بدء التسجيل. حاول مرة أخرى.';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      setState(() => _error = 'أدخل رمزاً مكوّناً من 6 أرقام');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(mfaServiceProvider);
      await service.verifyEnrollment(
        factorId: _enrollment!.factorId,
        code: code,
      );

      // Generate + store backup codes
      _backupCodes = service.generateBackupCodes();
      await service.storeBackupCodes(_backupCodes!);

      if (!mounted) return;
      setState(() {
        _step = _EnrollStep.backupCodes;
        _isLoading = false;
      });
    } catch (e) {
      _verifyAttempts++;
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (_verifyAttempts >= 5) {
          _error = 'عدد المحاولات الخاطئة كثير. أعد العملية من البداية.';
        } else {
          _error = 'الرمز غير صحيح. تأكد من التطبيق وحاول مرة أخرى.';
        }
      });
    }
  }

  void _downloadCodes() {
    if (_backupCodes == null || !kIsWeb) return;

    final date = DateTime.now().toIso8601String().split('T').first;
    final content = [
      'Alhai Distributor Portal - رموز الاستعادة',
      '=' * 45,
      '',
      'تاريخ الإنشاء: $date',
      '',
      'احفظ هذه الرموز في مكان آمن.',
      'كل رمز يُستخدم مرة واحدة فقط.',
      '',
      ..._backupCodes!.map((c) => '  $c'),
      '',
      '=' * 45,
    ].join('\n');

    downloadTextFile(
      content: content,
      filename: 'alhai-backup-codes-$date.txt',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'المصادقة الثنائية',
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        centerTitle: false,
        leading: _step == _EnrollStep.backupCodes
            ? null // Can't go back from backup codes step
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_step == _EnrollStep.intro) {
                    context.pop();
                  } else if (_step == _EnrollStep.scan) {
                    setState(() => _step = _EnrollStep.intro);
                  } else if (_step == _EnrollStep.verify) {
                    setState(() {
                      _step = _EnrollStep.scan;
                      _error = null;
                      _codeController.clear();
                    });
                  }
                },
              ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _buildStepContent(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isDark) {
    return switch (_step) {
      _EnrollStep.intro => _buildIntro(isDark),
      _EnrollStep.scan => _buildScan(isDark),
      _EnrollStep.verify => _buildVerify(isDark),
      _EnrollStep.backupCodes => _buildBackupCodes(isDark),
      _EnrollStep.done => _buildDone(isDark),
    };
  }

  // ─── Step 0: Introduction ──────────────────────────────────────

  Widget _buildIntro(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.security_rounded, size: 56, color: AppColors.primary),
        ),
        const SizedBox(height: AlhaiSpacing.lg),
        Text(
          'تعزيز أمان حسابك',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        Text(
          'المصادقة الثنائية تضيف طبقة حماية إضافية لحسابك. '
          'حتى لو عرف أحد كلمة مرورك، لن يستطيع الدخول بدون تطبيق المصادقة.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextSecondary(isDark),
            height: 1.6,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xl),
        _sectionCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ستحتاج أحد هذه التطبيقات:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              _appTile('Google Authenticator', Icons.phone_android, isDark),
              _appTile('Microsoft Authenticator', Icons.phone_android, isDark),
              _appTile('Authy', Icons.phone_android, isDark),
              _appTile('1Password', Icons.password_rounded, isDark),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AlhaiSpacing.md),
          _errorBanner(_error!, isDark),
        ],
        const SizedBox(height: AlhaiSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isLoading ? null : _startEnrollment,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : const Text(
                    'البدء',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _appTile(String name, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.getTextMuted(isDark)),
          const SizedBox(width: AlhaiSpacing.sm),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 1: Scan QR Code ──────────────────────────────────────

  Widget _buildScan(bool isDark) {
    if (_enrollment == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Text(
          'امسح رمز QR',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        Text(
          'افتح تطبيق المصادقة وامسح الرمز أدناه',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.lg),

        // QR Code
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AlhaiRadius.lg),
            border: Border.all(color: AppColors.getBorder(isDark)),
          ),
          child: QrImageView(
            data: _enrollment!.uri,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.lg),

        // Manual entry section
        _sectionCard(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أو أدخل المفتاح يدوياً:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'مفتاح المصادقة الثنائية',
                      child: SelectableText(
                        _enrollment!.secret,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Semantics(
                    button: true,
                    label: 'نسخ المفتاح',
                    child: IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      color: AppColors.primary,
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _enrollment!.secret),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم نسخ المفتاح'),
                            backgroundColor: AppColors.success,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xl),

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => setState(() {
              _step = _EnrollStep.verify;
              _error = null;
            }),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
              ),
            ),
            child: const Text(
              'تمت الإضافة، تحقّق الآن',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 2: Verify Code ───────────────────────────────────────

  Widget _buildVerify(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pin_rounded, size: 48, color: AppColors.info),
        ),
        const SizedBox(height: AlhaiSpacing.lg),
        Text(
          'أدخل رمز التحقّق',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        Text(
          'أدخل الرمز المكوّن من 6 أرقام من تطبيق المصادقة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextSecondary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xl),

        // Code input
        SizedBox(
          width: 240,
          child: TextField(
            controller: _codeController,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) => _verifyCode(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: AppColors.getTextPrimary(isDark),
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '000000',
              hintStyle: TextStyle(
                color: AppColors.getTextMuted(isDark),
                letterSpacing: 8,
              ),
              filled: true,
              fillColor: AppColors.getSurfaceVariant(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
                borderSide: BorderSide(color: AppColors.getBorder(isDark)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: AlhaiSpacing.md),
          _errorBanner(_error!, isDark),
        ],
        const SizedBox(height: AlhaiSpacing.xl),

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isLoading || _verifyAttempts >= 5 ? null : _verifyCode,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textOnPrimary,
                    ),
                  )
                : const Text(
                    'تحقّق',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),

        if (_verifyAttempts >= 5) ...[
          const SizedBox(height: AlhaiSpacing.md),
          TextButton(
            onPressed: () {
              setState(() {
                _step = _EnrollStep.intro;
                _enrollment = null;
                _verifyAttempts = 0;
                _codeController.clear();
                _error = null;
              });
            },
            child: const Text('إعادة المحاولة من البداية'),
          ),
        ],
      ],
    );
  }

  // ─── Step 3: Backup Codes ──────────────────────────────────────

  Widget _buildBackupCodes(bool isDark) {
    if (_backupCodes == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.lg),
        Text(
          'احفظ رموز الاستعادة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        Text(
          'استخدم هذه الرموز إذا فقدت الوصول لتطبيق المصادقة. '
          'لن تُعرض مرة أخرى — احفظها في مكان آمن.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextSecondary(isDark),
            height: 1.6,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.lg),

        // Codes display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AlhaiSpacing.mdl),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceVariant(isDark),
            borderRadius: BorderRadius.circular(AlhaiRadius.md),
            border: Border.all(color: AppColors.getBorder(isDark)),
          ),
          child: Wrap(
            spacing: AlhaiSpacing.lg,
            runSpacing: AlhaiSpacing.sm,
            alignment: WrapAlignment.center,
            children: _backupCodes!
                .map(
                  (code) => Text(
                    code,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.getTextPrimary(isDark),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.md),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('نسخ الرموز'),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: _backupCodes!.join('\n')),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ الرموز'),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AlhaiSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.md),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('تنزيل'),
                onPressed: _downloadCodes,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AlhaiSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AlhaiRadius.md),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.lg),

        // Confirmation checkbox
        _sectionCard(
          isDark: isDark,
          child: CheckboxListTile(
            value: _codesSaved,
            onChanged: (v) => setState(() => _codesSaved = v ?? false),
            title: Text(
              'حفظت الرموز في مكان آمن',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(isDark),
              ),
            ),
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.lg),

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _codesSaved ? () => setState(() => _step = _EnrollStep.done) : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
              ),
            ),
            child: const Text(
              'تم',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step 4: Done ──────────────────────────────────────────────

  Widget _buildDone(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 64,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.lg),
        Text(
          'تم تفعيل المصادقة الثنائية',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(isDark),
          ),
        ),
        const SizedBox(height: AlhaiSpacing.sm),
        Text(
          'حسابك محمي الآن. ستحتاج رمز المصادقة في كل مرة تسجّل دخول.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.getTextSecondary(isDark),
            height: 1.6,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              ref.invalidate(mfaEnrollmentStatusProvider);
              context.pop(true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AlhaiRadius.md),
              ),
            ),
            child: const Text(
              'حسناً',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Shared Widgets ────────────────────────────────────────────

  Widget _sectionCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AlhaiRadius.lg),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: child,
    );
  }

  Widget _errorBanner(String message, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: AlhaiSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
