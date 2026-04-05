/// شاشة عرض العميل - Customer Display Screen
///
/// شاشة للقراءة فقط تُعرض على الشاشة الثانية الموجهة للعميل.
///
/// يعمل بوضعين:
/// 1. **نفس النافذة**: يستقبل الحالة عبر [StreamProvider] من الكاشير
/// 2. **نافذة مستقلة** (web): يستقبل الحالة عبر BroadcastChannel
///
/// عند فتح الشاشة في نافذة جديدة على الويب، تُنشئ قناة BroadcastChannel
/// خاصة بها لاستقبال الحالات من نافذة الكاشير.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../providers/customer_display_providers.dart';
import '../../services/customer_display/customer_display_service.dart';
import '../../services/customer_display/customer_display_state.dart';
import '../../services/customer_display/web_display_channel_factory.dart'
    as channel_factory;

// The customerDisplayStreamProvider is defined in customer_display_providers.dart
// and imported above. It provides the state stream from the cashier service.
// In standalone web mode, the screen uses its own BroadcastChannel instead.

// ============================================================================
// SCREEN
// ============================================================================

/// شاشة عرض العميل - للقراءة فقط على الشاشة الثانية
class CustomerDisplayScreen extends ConsumerStatefulWidget {
  const CustomerDisplayScreen({super.key});

  @override
  ConsumerState<CustomerDisplayScreen> createState() =>
      _CustomerDisplayScreenState();
}

class _CustomerDisplayScreenState extends ConsumerState<CustomerDisplayScreen>
    with SingleTickerProviderStateMixin {
  /// متحكم الرسوم المتحركة لتأثير النبض في شاشة الانتظار و NFC
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  /// فهرس الشريحة الحالية في شاشة الترحيب الدوارة
  int _idleSlideIndex = 0;

  /// مؤقت تدوير شرائح شاشة الترحيب
  Timer? _idleSlideTimer;

  // ── BroadcastChannel receiver (web standalone mode) ──
  /// Whether this screen is receiving state via its own BroadcastChannel
  /// (i.e. running in a standalone window, not embedded in the cashier app).
  bool _isStandaloneMode = false;

  /// The BroadcastChannel receiver for standalone mode (web only).
  CustomerDisplayChannel? _receiverChannel;

  /// Subscription to the receiver channel's state stream.
  StreamSubscription<CustomerDisplayState>? _receiverSubscription;

  /// Current state received via BroadcastChannel (standalone mode).
  CustomerDisplayState _broadcastState = const CustomerDisplayState.idle();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: AlhaiMotion.standard,
      ),
    );

    _startIdleSlideTimer();
    _initBroadcastReceiver();
  }

  /// Initialize the BroadcastChannel receiver on web.
  ///
  /// On web, the customer display screen creates its own channel to listen
  /// for state updates from the cashier window. This works regardless of
  /// whether the screen is in the same window or a separate window.
  void _initBroadcastReceiver() {
    if (!kIsWeb) return;

    try {
      _receiverChannel = channel_factory.createWebDisplayChannel();
      _receiverSubscription = _receiverChannel!.stateStream.listen(
        (state) {
          if (mounted) {
            setState(() {
              _broadcastState = state;
              _isStandaloneMode = true;
            });
          }
        },
        onError: (Object error) {
          debugPrint('[CustomerDisplay] Receiver error: $error');
        },
      );
      debugPrint('[CustomerDisplay] Receiver channel initialized');
    } catch (e) {
      debugPrint('[CustomerDisplay] Failed to init receiver: $e');
    }
  }

  void _startIdleSlideTimer() {
    _idleSlideTimer?.cancel();
    _idleSlideTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        setState(() => _idleSlideIndex++);
      }
    });
  }

  @override
  void dispose() {
    _idleSlideTimer?.cancel();
    _receiverSubscription?.cancel();
    _receiverChannel?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // تنسيق الأسعار
  // ==========================================================================

  /// تنسيق المبلغ مع رمز العملة
  String _formatPrice(double amount) => '${amount.toStringAsFixed(2)} ر.س';

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    // On web standalone mode, use state from BroadcastChannel directly.
    // Otherwise, use the Riverpod provider (same-window mode).
    final Widget body;
    if (_isStandaloneMode) {
      // الوضع المستقل: استقبال عبر BroadcastChannel
      body = AnimatedSwitcher(
        duration: AlhaiDurations.slow,
        switchInCurve: AlhaiMotion.standardDecelerate,
        switchOutCurve: AlhaiMotion.standardAccelerate,
        child: _buildPhase(_broadcastState),
      );
    } else {
      // الوضع العادي: استقبال عبر Riverpod provider
      final asyncState = ref.watch(customerDisplayStreamProvider);
      body = asyncState.when(
        data: (state) => AnimatedSwitcher(
          duration: AlhaiDurations.slow,
          switchInCurve: AlhaiMotion.standardDecelerate,
          switchOutCurve: AlhaiMotion.standardAccelerate,
          child: _buildPhase(state),
        ),
        loading: () => _buildIdleView(const CustomerDisplayState.idle()),
        error: (_, __) => _buildIdleView(const CustomerDisplayState.idle()),
      );
    }

    // تجاهل أي تفاعل لمس - الشاشة للقراءة فقط
    return IgnorePointer(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: body,
        ),
      ),
    );
  }

  /// توزيع المراحل على الودجت المناسبة
  Widget _buildPhase(CustomerDisplayState state) {
    return switch (state.phase) {
      CustomerDisplayPhase.idle => _buildIdleView(state),
      CustomerDisplayPhase.cart => _buildCartView(state),
      CustomerDisplayPhase.phoneEntry => _buildPhoneEntryView(state),
      CustomerDisplayPhase.payment => _buildCartView(state),
      CustomerDisplayPhase.nfcWaiting => _buildNfcWaitingView(state),
      CustomerDisplayPhase.success => _buildSuccessView(state),
      CustomerDisplayPhase.failure => _buildFailureView(state),
    };
  }

  // ==========================================================================
  // 1. شاشة الترحيب (IDLE)
  // ==========================================================================

  Widget _buildIdleView(CustomerDisplayState state) {
    // بناء قائمة الشرائح الدوارة
    final slides = <Widget>[
      // شريحة 1: شعار المتجر + نسعد بخدمتك
      _buildIdleSlide(
        key: 'slide_store',
        icon: Icons.store_rounded,
        iconColor: AlhaiColors.primary,
        text: '\u0646\u0633\u0639\u062F \u0628\u062E\u062F\u0645\u062A\u0643',
      ),
      // شريحة 3: برنامج الولاء
      _buildIdleSlide(
        key: 'slide_loyalty',
        icon: Icons.card_giftcard_rounded,
        iconColor: AlhaiColors.warning,
        text:
            '\u0627\u0633\u0623\u0644 \u0639\u0646 \u0628\u0631\u0646\u0627\u0645\u062C \u0627\u0644\u0648\u0644\u0627\u0621',
      ),
    ];

    // شريحة NFC - فقط إذا كانت الميزة مفعّلة
    final featureSettings =
        ref.watch(cashierFeatureSettingsProvider).valueOrNull;
    if (featureSettings?.enableNfcPayment == true) {
      slides.insert(
        1,
        _buildIdleSlide(
          key: 'slide_nfc',
          icon: Icons.contactless_rounded,
          iconColor: AlhaiColors.info,
          text:
              '\u0627\u062F\u0641\u0639 \u0628\u062A\u0642\u0631\u064A\u0628 \u0627\u0644\u0628\u0637\u0627\u0642\u0629',
        ),
      );
    }

    final currentSlide = slides[_idleSlideIndex % slides.length];

    return Container(
      key: const ValueKey('idle'),
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topCenter,
          end: AlignmentDirectional.bottomCenter,
          colors: [
            Color(0xFF0F172A), // slate-900
            Color(0xFF1E293B), // slate-800
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // اسم المتجر
            if (state.storeName.isNotEmpty)
              Text(
                state.storeName,
                style: AlhaiTypography.displayLarge.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: AlhaiSpacing.lg),

            // رسالة ترحيب
            Text(
              '\u0645\u0631\u062D\u0628\u0627\u064B \u0628\u0643',
              style: AlhaiTypography.headlineLarge.copyWith(
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AlhaiSpacing.xxl),

            // قسم المحتوى الدوّار
            SizedBox(
              height: 160,
              child: AnimatedSwitcher(
                duration: AlhaiDurations.slow,
                switchInCurve: AlhaiMotion.standardDecelerate,
                switchOutCurve: AlhaiMotion.standardAccelerate,
                child: currentSlide,
              ),
            ),

            const SizedBox(height: AlhaiSpacing.lg),

            // نقطة نابضة للإشارة إلى أن الشاشة نشطة
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseAnimation.value,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AlhaiColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// بناء شريحة واحدة في شاشة الترحيب الدوارة
  Widget _buildIdleSlide({
    required String key,
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Column(
      key: ValueKey(key),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 40),
        ),
        const SizedBox(height: AlhaiSpacing.md),
        Text(
          text,
          style: AlhaiTypography.titleLarge.copyWith(
            color: AppColors.textSecondaryDark,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ==========================================================================
  // 2. عرض الفاتورة (CART / PAYMENT)
  // ==========================================================================

  Widget _buildCartView(CustomerDisplayState state) {
    return Container(
      key: const ValueKey('cart'),
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.all(AlhaiSpacing.xl),
      child: Column(
        children: [
          // ترويسة المتجر
          _buildStoreHeader(state.storeName),
          const SizedBox(height: AlhaiSpacing.lg),

          // جدول المنتجات
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AlhaiRadius.lg),
              ),
              child: Column(
                children: [
                  // رأس الجدول
                  _buildTableHeader(),
                  const Divider(
                    color: AppColors.borderDark,
                    height: 1,
                  ),

                  // عناصر الفاتورة
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        vertical: AlhaiSpacing.xs,
                      ),
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: AppColors.borderDark,
                        height: 1,
                        indent: AlhaiSpacing.md,
                        endIndent: AlhaiSpacing.md,
                      ),
                      itemBuilder: (context, index) {
                        return _buildCartItemRow(state.items[index]);
                      },
                    ),
                  ),

                  // الفاصل قبل المجاميع
                  const Divider(
                    color: AppColors.borderDark,
                    height: 1,
                  ),

                  // المجاميع
                  _buildTotalsSection(state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ترويسة المتجر
  Widget _buildStoreHeader(String storeName) {
    if (storeName.isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        const Icon(
          Icons.store_rounded,
          color: AlhaiColors.primary,
          size: 28,
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Expanded(
          child: Text(
            storeName,
            style: AlhaiTypography.headlineMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// رأس جدول المنتجات
  Widget _buildTableHeader() {
    final headerStyle = AlhaiTypography.labelLarge.copyWith(
      color: AppColors.textSecondaryDark,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '\u0627\u0644\u0645\u0646\u062A\u062C',
              style: headerStyle,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '\u0627\u0644\u0643\u0645\u064A\u0629',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              '\u0627\u0644\u0633\u0639\u0631',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              '\u0627\u0644\u0625\u062C\u0645\u0627\u0644\u064A',
              style: headerStyle,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  /// صف منتج في الفاتورة
  Widget _buildCartItemRow(DisplayCartItem item) {
    final textStyle = AlhaiTypography.bodyLarge.copyWith(
      color: AppColors.textPrimaryDark,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              item.productName,
              style: textStyle.copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              '${item.quantity}',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 100,
            child: Text(
              _formatPrice(item.unitPrice),
              style: textStyle.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              _formatPrice(item.lineTotal),
              style: textStyle.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  /// قسم المجاميع
  Widget _buildTotalsSection(CustomerDisplayState state) {
    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Column(
        children: [
          // المجموع الفرعي
          _buildSummaryRow(
            '\u0627\u0644\u0645\u062C\u0645\u0648\u0639 \u0627\u0644\u0641\u0631\u0639\u064A',
            _formatPrice(state.subtotal),
          ),
          const SizedBox(height: AlhaiSpacing.xs),

          // الخصم (إن وجد)
          if (state.discount > 0) ...[
            _buildSummaryRow(
              '\u0627\u0644\u062E\u0635\u0645',
              '- ${_formatPrice(state.discount)}',
              valueColor: AlhaiColors.success,
            ),
            const SizedBox(height: AlhaiSpacing.xs),
          ],

          // ضريبة القيمة المضافة
          _buildSummaryRow(
            '\u0636\u0631\u064A\u0628\u0629 \u0627\u0644\u0642\u064A\u0645\u0629 \u0627\u0644\u0645\u0636\u0627\u0641\u0629 (15%)',
            _formatPrice(state.tax),
          ),

          const SizedBox(height: AlhaiSpacing.sm),
          const Divider(color: AppColors.borderDark, height: 1),
          const SizedBox(height: AlhaiSpacing.sm),

          // الإجمالي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\u0627\u0644\u0625\u062C\u0645\u0627\u0644\u064A',
                style: AlhaiTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _formatPrice(state.total),
                style: AlhaiTypography.headlineLarge.copyWith(
                  color: AlhaiColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// صف ملخص (فرعي / خصم / ضريبة)
  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AlhaiTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        Text(
          value,
          style: AlhaiTypography.bodyLarge.copyWith(
            color: valueColor ?? AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // 3. إدخال بيانات العميل (PHONE ENTRY)
  // ==========================================================================

  Widget _buildPhoneEntryView(CustomerDisplayState state) {
    return Container(
      key: const ValueKey('phoneEntry'),
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0F172A),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ايقونة
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AlhaiColors.info.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                color: AlhaiColors.info,
                size: 52,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xl),

            // رسالة
            Text(
              '\u062C\u0627\u0631\u064A \u0625\u062F\u062E\u0627\u0644 \u0628\u064A\u0627\u0646\u0627\u062A \u0627\u0644\u0639\u0645\u064A\u0644...',
              style: AlhaiTypography.headlineMedium.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // المبلغ
            if (state.total > 0)
              Text(
                _formatPrice(state.total),
                style: AlhaiTypography.displayLarge.copyWith(
                  color: AlhaiColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: AlhaiSpacing.xxl),

            // مؤشر تحميل
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: AlhaiColors.info,
                strokeWidth: AlhaiSpacing.strokeSm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 4. انتظار NFC (NFC WAITING)
  // ==========================================================================

  Widget _buildNfcWaitingView(CustomerDisplayState state) {
    final nfcStatus = state.nfcStatus ?? NfcDisplayStatus.waitingForTap;
    final isError = nfcStatus == NfcDisplayStatus.failed ||
        nfcStatus == NfcDisplayStatus.cancelled ||
        nfcStatus == NfcDisplayStatus.timeout;

    // رسالة الحالة
    final statusMessage = _getNfcStatusMessage(nfcStatus, state.nfcMessage);
    final statusColor = isError ? AlhaiColors.error : AlhaiColors.info;

    return Container(
      key: const ValueKey('nfcWaiting'),
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0F172A),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // المبلغ
            Text(
              _formatPrice(state.total),
              style: AlhaiTypography.displayLarge.copyWith(
                color: AlhaiColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xxl),

            // ايقونة NFC مع تأثير نبض
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isError ? 1.0 : _pulseAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isError
                          ? Icons.error_outline_rounded
                          : Icons.contactless_rounded,
                      color: statusColor,
                      size: 64,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AlhaiSpacing.xl),

            // رسالة الحالة
            AnimatedSwitcher(
              duration: AlhaiDurations.standard,
              child: Text(
                statusMessage,
                key: ValueKey(statusMessage),
                style: AlhaiTypography.headlineMedium.copyWith(
                  color:
                      isError ? AlhaiColors.error : AppColors.textPrimaryDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // مؤشر معالجة (عند القراءة أو المعالجة)
            if (nfcStatus == NfcDisplayStatus.reading ||
                nfcStatus == NfcDisplayStatus.processing) ...[
              const SizedBox(height: AlhaiSpacing.xl),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: AlhaiColors.info,
                  strokeWidth: AlhaiSpacing.strokeSm,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// الحصول على رسالة حالة NFC
  String _getNfcStatusMessage(NfcDisplayStatus status, String? customMessage) {
    if (customMessage != null && customMessage.isNotEmpty) {
      return customMessage;
    }
    return switch (status) {
      NfcDisplayStatus.waitingForTap =>
        '\u0642\u0631\u0651\u0628 \u0627\u0644\u0628\u0637\u0627\u0642\u0629 \u0623\u0648 \u0627\u0644\u062C\u0648\u0627\u0644',
      NfcDisplayStatus.reading =>
        '\u062C\u0627\u0631\u064A \u0642\u0631\u0627\u0621\u0629 \u0627\u0644\u0628\u0637\u0627\u0642\u0629...',
      NfcDisplayStatus.processing =>
        '\u062C\u0627\u0631\u064A \u0627\u0644\u0645\u0639\u0627\u0644\u062C\u0629...',
      NfcDisplayStatus.success =>
        '\u062A\u0645\u062A \u0627\u0644\u0642\u0631\u0627\u0621\u0629 \u0628\u0646\u062C\u0627\u062D',
      NfcDisplayStatus.failed =>
        '\u0641\u0634\u0644\u062A \u0627\u0644\u0639\u0645\u0644\u064A\u0629',
      NfcDisplayStatus.cancelled =>
        '\u062A\u0645 \u0625\u0644\u063A\u0627\u0621 \u0627\u0644\u0639\u0645\u0644\u064A\u0629',
      NfcDisplayStatus.timeout =>
        '\u0627\u0646\u062A\u0647\u062A \u0627\u0644\u0645\u0647\u0644\u0629',
    };
  }

  // ==========================================================================
  // 5. نجاح الدفع (SUCCESS)
  // ==========================================================================

  Widget _buildSuccessView(CustomerDisplayState state) {
    return Container(
      key: const ValueKey('success'),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topCenter,
          end: AlignmentDirectional.bottomCenter,
          colors: [
            const Color(0xFF0F172A),
            AlhaiColors.success.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ايقونة النجاح مع تأثير تكبير
            AlhaiScaleIn(
              duration: AlhaiDurations.extraSlow,
              curve: AlhaiMotion.scaleUp,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AlhaiColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xl),

            // رسالة النجاح
            Text(
              state.resultMessage ??
                  '\u062A\u0645\u062A \u0627\u0644\u0639\u0645\u0644\u064A\u0629 \u0628\u0646\u062C\u0627\u062D',
              style: AlhaiTypography.headlineLarge.copyWith(
                color: AlhaiColors.success,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // شكرا لك
            Text(
              '\u0634\u0643\u0631\u0627\u064B \u0644\u0643',
              style: AlhaiTypography.headlineMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AlhaiSpacing.xl),

            // المبلغ
            if (state.total > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.xl,
                  vertical: AlhaiSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AlhaiColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AlhaiRadius.lg),
                ),
                child: Text(
                  _formatPrice(state.total),
                  style: AlhaiTypography.displayLarge.copyWith(
                    color: AlhaiColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 6. فشل الدفع (FAILURE)
  // ==========================================================================

  Widget _buildFailureView(CustomerDisplayState state) {
    return Container(
      key: const ValueKey('failure'),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topCenter,
          end: AlignmentDirectional.bottomCenter,
          colors: [
            const Color(0xFF0F172A),
            AlhaiColors.error.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ايقونة الخطأ
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AlhaiColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AlhaiColors.error,
                size: 64,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xl),

            // رسالة الخطأ
            Text(
              state.resultMessage ??
                  '\u0641\u0634\u0644\u062A \u0627\u0644\u0639\u0645\u0644\u064A\u0629',
              style: AlhaiTypography.headlineLarge.copyWith(
                color: AlhaiColors.error,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AlhaiSpacing.md),

            // رسالة مساعدة
            Text(
              '\u064A\u0631\u062C\u0649 \u0627\u0644\u0645\u062D\u0627\u0648\u0644\u0629 \u0645\u0631\u0629 \u0623\u062E\u0631\u0649',
              style: AlhaiTypography.headlineMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
