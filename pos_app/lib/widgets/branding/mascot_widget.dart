/// Mascot Widget - الروبوت الأخضر
///
/// يعرض روبوت Al-Hal POS الودود
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';

/// حجم الروبوت
enum MascotSize {
  small(120),
  medium(200),
  large(300),
  extraLarge(400);

  final double value;
  const MascotSize(this.value);
}

/// وضعية الروبوت
enum MascotPose {
  /// واقف مع لابتوب
  withLaptop,

  /// يلوح باليد
  waving,

  /// يشير للأمام
  pointing,

  /// فقط الرأس
  headOnly,
}

/// روابط صور الروبوت 3D
class MascotAssets {
  /// صورة روبوت الحل المحلية
  static const String localMascot = 'assets/images/mascot_robot.png';

  // صورة روبوت 3D أخضر مع tablet - المصدر الأصلي
  static const String mascot3DUrl =
      'https://storage.googleapis.com/uxpilot-auth.appspot.com/32a6d45308-80624197f3a9044f29f1.png';

  // صور بديلة
  static const String mascotAlt1 =
      'https://cdn3d.iconscout.com/3d/premium/thumb/cute-robot-3d-icon-download-in-png-blend-fbx-gltf-file-formats--ai-bot-chatbot-assistant-pack-science-technology-icons-5900873.png';

  static const String mascotAlt2 =
      'https://cdn3d.iconscout.com/3d/premium/thumb/robot-assistant-3d-icon-download-in-png-blend-fbx-gltf-file-formats--ai-bot-chatbot-pack-science-technology-icons-6218457.png';
}

/// ويدجت الروبوت - يدعم صور 3D من URL أو رسم CustomPaint أو صور محلية
class MascotWidget extends StatelessWidget {
  final MascotSize size;
  final MascotPose pose;
  final bool animate;
  final bool use3DImage;
  final bool useLocalAsset;
  final String? customImageUrl;

  const MascotWidget({
    super.key,
    this.size = MascotSize.medium,
    this.pose = MascotPose.withLaptop,
    this.animate = true,
    this.use3DImage = true,
    this.useLocalAsset = true,
    this.customImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: size.value,
      height: size.value,
      child: useLocalAsset
          ? _LocalMascot(
              size: size.value,
              assetPath: MascotAssets.localMascot,
              animate: animate,
            )
          : use3DImage
              ? _NetworkMascot(
                  size: size.value,
                  imageUrl: customImageUrl ?? MascotAssets.mascot3DUrl,
                  animate: animate,
                )
              : (animate
                  ? _AnimatedMascot(size: size.value, pose: pose)
                  : _StaticMascot(size: size.value, pose: pose)),
    );
  }
}

/// الروبوت من صورة محلية مع تحريك
class _LocalMascot extends StatefulWidget {
  final double size;
  final String assetPath;
  final bool animate;

  const _LocalMascot({
    required this.size,
    required this.assetPath,
    this.animate = true,
  });

  @override
  State<_LocalMascot> createState() => _LocalMascotState();
}

class _LocalMascotState extends State<_LocalMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 15,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.animate ? -_bounceAnimation.value : 0),
          child: child,
        );
      },
      child: Image.asset(
        widget.assetPath,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _StaticMascot(
          size: widget.size,
          pose: MascotPose.waving,
        ),
      ),
    );
  }
}

/// الروبوت من صورة URL مع تحريك
class _NetworkMascot extends StatefulWidget {
  final double size;
  final String imageUrl;
  final bool animate;

  const _NetworkMascot({
    required this.size,
    required this.imageUrl,
    this.animate = true,
  });

  @override
  State<_NetworkMascot> createState() => _NetworkMascotState();
}

class _NetworkMascotState extends State<_NetworkMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, widget.animate ? -_bounceAnimation.value : 0),
          child: child,
        );
      },
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _StaticMascot(
          size: widget.size,
          pose: MascotPose.waving,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(widget.size / 4),
      ),
      child: Center(
        child: SizedBox(
          width: widget.size * 0.3,
          height: widget.size * 0.3,
          child: const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}

class _AnimatedMascot extends StatefulWidget {
  final double size;
  final MascotPose pose;

  const _AnimatedMascot({required this.size, required this.pose});

  @override
  State<_AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<_AnimatedMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: child,
        );
      },
      child: _StaticMascot(size: widget.size, pose: widget.pose),
    );
  }
}

class _StaticMascot extends StatelessWidget {
  final double size;
  final MascotPose pose;

  const _StaticMascot({required this.size, required this.pose});

  @override
  Widget build(BuildContext context) {
    // الروبوت المرسوم بـ CustomPaint
    // يمكن استبداله بصورة حقيقية لاحقاً
    return CustomPaint(
      size: Size(size, size),
      painter: _MascotPainter(pose: pose),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final MascotPose pose;

  _MascotPainter({required this.pose});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final headRadius = size.width * 0.25;

    // ظل أرضي 3D
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.black.withValues(alpha: 0.2),
          Colors.black.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.88),
        width: size.width * 0.6,
        height: size.height * 0.1,
      ));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.88),
        width: size.width * 0.6,
        height: size.height * 0.1,
      ),
      shadowPaint,
    );

    // الجسم - تدرج 3D
    const bodyGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primaryLight,
        AppColors.primary,
        AppColors.primaryDark,
      ],
      stops: [0.0, 0.5, 1.0],
    );

    final bodyPaint = Paint()
      ..shader = bodyGradient.createShader(Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.15),
        width: size.width * 0.5,
        height: size.height * 0.4,
      ))
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..moveTo(center.dx - size.width * 0.2, center.dy)
      ..quadraticBezierTo(
        center.dx - size.width * 0.25,
        center.dy + size.height * 0.3,
        center.dx,
        center.dy + size.height * 0.35,
      )
      ..quadraticBezierTo(
        center.dx + size.width * 0.25,
        center.dy + size.height * 0.3,
        center.dx + size.width * 0.2,
        center.dy,
      )
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // انعكاس الجسم (3D effect)
    final bodyHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final highlightPath = Path()
      ..moveTo(center.dx - size.width * 0.15, center.dy + size.height * 0.05)
      ..quadraticBezierTo(
        center.dx - size.width * 0.1,
        center.dy + size.height * 0.15,
        center.dx - size.width * 0.05,
        center.dy + size.height * 0.2,
      )
      ..lineTo(center.dx - size.width * 0.12, center.dy + size.height * 0.15)
      ..close();
    canvas.drawPath(highlightPath, bodyHighlightPaint);

    // الرأس - تدرج 3D معدني
    const headGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF34D399), // أخضر فاتح
        AppColors.primary,
        AppColors.primaryDark,
      ],
    );

    final headBgPaint = Paint()
      ..shader = headGradient.createShader(Rect.fromCenter(
        center: Offset(center.dx, center.dy - headRadius * 0.3),
        width: headRadius * 2,
        height: headRadius * 1.8,
      ))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - headRadius * 0.3),
          width: headRadius * 2,
          height: headRadius * 1.8,
        ),
        Radius.circular(headRadius * 0.4),
      ),
      headBgPaint,
    );

    // انعكاس الرأس (3D metallic)
    final headHighlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(center.dx, center.dy - headRadius * 0.6),
        width: headRadius * 1.6,
        height: headRadius * 0.8,
      ))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - headRadius * 0.6),
          width: headRadius * 1.6,
          height: headRadius * 0.6,
        ),
        Radius.circular(headRadius * 0.3),
      ),
      headHighlightPaint,
    );

    // الرأس - شاشة الوجه (3D screen effect)
    const faceGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF2A2A4A),
        Color(0xFF1A1A2E),
        Color(0xFF151528),
      ],
    );

    final facePaint = Paint()
      ..shader = faceGradient.createShader(Rect.fromCenter(
        center: Offset(center.dx, center.dy - headRadius * 0.2),
        width: headRadius * 1.6,
        height: headRadius * 1.2,
      ))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - headRadius * 0.2),
          width: headRadius * 1.6,
          height: headRadius * 1.2,
        ),
        Radius.circular(headRadius * 0.25),
      ),
      facePaint,
    );

    // حدود الشاشة المضيئة
    final screenBorderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - headRadius * 0.2),
          width: headRadius * 1.6,
          height: headRadius * 1.2,
        ),
        Radius.circular(headRadius * 0.25),
      ),
      screenBorderPaint,
    );

    // العيون - مع توهج
    _drawGlowingEye(
      canvas,
      Offset(center.dx - headRadius * 0.35, center.dy - headRadius * 0.25),
      headRadius * 0.22,
    );
    _drawGlowingEye(
      canvas,
      Offset(center.dx + headRadius * 0.35, center.dy - headRadius * 0.25),
      headRadius * 0.22,
    );

    // الأنتينا - 3D
    const antennaGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        AppColors.primaryDark,
        AppColors.primary,
        AppColors.primaryLight,
      ],
    );

    final antennaPaint = Paint()
      ..shader = antennaGradient.createShader(Rect.fromLTWH(
        center.dx - 4,
        center.dy - headRadius * 1.6,
        8,
        headRadius * 0.5,
      ))
      ..style = PaintingStyle.fill;

    // قاعدة الأنتينا
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - headRadius * 1.3),
          width: 8,
          height: headRadius * 0.5,
        ),
        const Radius.circular(4),
      ),
      antennaPaint,
    );

    // كرة الأنتينا مع توهج
    _drawGlowingBall(
      canvas,
      Offset(center.dx, center.dy - headRadius * 1.6),
      headRadius * 0.12,
    );

    // الأيدي - 3D metallic
    const handGradient = RadialGradient(
      colors: [
        AppColors.primaryLight,
        AppColors.primary,
      ],
    );

    // يد يمنى
    _draw3DHand(
      canvas,
      Offset(center.dx - size.width * 0.35, center.dy + size.height * 0.1),
      headRadius * 0.3,
      handGradient,
    );

    // يد يسرى
    if (pose == MascotPose.withLaptop) {
      _draw3DHand(
        canvas,
        Offset(center.dx + size.width * 0.35, center.dy + size.height * 0.1),
        headRadius * 0.3,
        handGradient,
      );

      // اللابتوب 3D
      _draw3DLaptop(canvas, center, size);
    } else if (pose == MascotPose.waving) {
      // يد تلوح
      canvas.save();
      canvas.translate(
        center.dx + size.width * 0.35,
        center.dy - size.height * 0.1,
      );
      canvas.rotate(-0.5);
      _draw3DHand(canvas, Offset.zero, headRadius * 0.35, handGradient);
      canvas.restore();
    }

    // الأرجل - 3D
    const legGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primary,
        AppColors.primaryDark,
      ],
    );

    _draw3DFoot(
      canvas,
      Offset(center.dx - size.width * 0.1, center.dy + size.height * 0.4),
      Size(headRadius * 0.4, headRadius * 0.25),
      legGradient,
    );
    _draw3DFoot(
      canvas,
      Offset(center.dx + size.width * 0.1, center.dy + size.height * 0.4),
      Size(headRadius * 0.4, headRadius * 0.25),
      legGradient,
    );
  }

  void _drawGlowingEye(Canvas canvas, Offset center, double radius) {
    // توهج خارجي
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius * 1.5, glowPaint);

    // العين البيضاء
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius, eyePaint);

    // البؤبؤ
    const pupilGradient = RadialGradient(
      colors: [
        AppColors.primaryLight,
        AppColors.primary,
      ],
    );
    final pupilPaint = Paint()
      ..shader = pupilGradient.createShader(
        Rect.fromCircle(center: center, radius: radius * 0.5),
      );
    canvas.drawCircle(center, radius * 0.5, pupilPaint);

    // انعكاس
    final reflectPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.2, center.dy - radius * 0.2),
      radius * 0.15,
      reflectPaint,
    );
  }

  void _drawGlowingBall(Canvas canvas, Offset center, double radius) {
    // توهج
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius * 2, glowPaint);

    // الكرة
    const ballGradient = RadialGradient(
      center: Alignment(-0.3, -0.3),
      colors: [
        AppColors.primaryLight,
        AppColors.primary,
        AppColors.primaryDark,
      ],
    );
    final ballPaint = Paint()
      ..shader = ballGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, ballPaint);
  }

  void _draw3DHand(
      Canvas canvas, Offset center, double radius, Gradient gradient) {
    final handPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, handPaint);

    // انعكاس
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      radius * 0.4,
      highlightPaint,
    );
  }

  void _draw3DLaptop(Canvas canvas, Offset center, Size size) {
    // قاعدة اللابتوب
    final laptopGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.grey.shade200,
        Colors.grey.shade100,
        Colors.white,
      ],
    );

    final laptopPaint = Paint()
      ..shader = laptopGradient.createShader(Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.22),
        width: size.width * 0.4,
        height: size.height * 0.08,
      ));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.22),
          width: size.width * 0.4,
          height: size.height * 0.08,
        ),
        const Radius.circular(4),
      ),
      laptopPaint,
    );

    // شاشة اللابتوب
    final screenGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.info.withValues(alpha: 0.8),
        AppColors.info,
        const Color(0xFF2563EB),
      ],
    );

    final screenPaint = Paint()
      ..shader = screenGradient.createShader(Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.15),
        width: size.width * 0.35,
        height: size.height * 0.1,
      ));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.15),
          width: size.width * 0.35,
          height: size.height * 0.1,
        ),
        const Radius.circular(2),
      ),
      screenPaint,
    );

    // انعكاس الشاشة
    final screenReflectPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(center.dx - size.width * 0.05, center.dy + size.height * 0.13),
        width: size.width * 0.15,
        height: size.height * 0.04,
      ));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx - size.width * 0.05, center.dy + size.height * 0.13),
          width: size.width * 0.15,
          height: size.height * 0.04,
        ),
        const Radius.circular(2),
      ),
      screenReflectPaint,
    );
  }

  void _draw3DFoot(
      Canvas canvas, Offset center, Size footSize, Gradient gradient) {
    final footPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCenter(
        center: center,
        width: footSize.width,
        height: footSize.height,
      ));
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: footSize.width,
        height: footSize.height,
      ),
      footPaint,
    );

    // انعكاس
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - footSize.height * 0.15),
        width: footSize.width * 0.6,
        height: footSize.height * 0.4,
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(_MascotPainter oldDelegate) => pose != oldDelegate.pose;
}

/// Mascot مع رسالة
class MascotWithMessage extends StatelessWidget {
  final String message;
  final MascotSize size;
  final MascotPose pose;

  const MascotWithMessage({
    super.key,
    required this.message,
    this.size = MascotSize.medium,
    this.pose = MascotPose.waving,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // فقاعة الرسالة
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // الروبوت
        MascotWidget(size: size, pose: pose),
      ],
    );
  }
}




