/// Gradient Background Widget - خلفية متدرجة
///
/// خلفية أخضر متدرج لشاشات التسجيل
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// أنواع التدرج
enum GradientType {
  /// تدرج عمودي (من الأعلى للأسفل)
  vertical,

  /// تدرج أفقي (من اليمين لليسار)
  horizontal,

  /// تدرج قطري
  diagonal,

  /// تدرج شعاعي
  radial,
}

/// خلفية متدرجة أساسية
class GradientBackground extends StatelessWidget {
  final Widget child;
  final GradientType type;
  final List<Color>? colors;
  final double opacity;

  const GradientBackground({
    super.key,
    required this.child,
    this.type = GradientType.vertical,
    this.colors,
    this.opacity = 1.0,
  });

  /// التدرج الأخضر الأساسي
  factory GradientBackground.primary({
    Key? key,
    required Widget child,
    GradientType type = GradientType.vertical,
  }) {
    return GradientBackground(
      key: key,
      type: type,
      colors: const [
        Color(0xFF059669), // Emerald 600
        Color(0xFF10B981), // Emerald 500
        Color(0xFF34D399), // Emerald 400
      ],
      child: child,
    );
  }

  /// التدرج الداكن
  factory GradientBackground.dark({
    Key? key,
    required Widget child,
    GradientType type = GradientType.vertical,
  }) {
    return GradientBackground(
      key: key,
      type: type,
      colors: const [
        Color(0xFF064E3B), // Emerald 900
        Color(0xFF065F46), // Emerald 800
        Color(0xFF047857), // Emerald 700
      ],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ??
        [
          AppColors.primaryDark,
          AppColors.primary,
          AppColors.primaryLight,
        ];

    return Container(
      decoration: BoxDecoration(
        gradient: _buildGradient(gradientColors),
      ),
      child: Opacity(
        opacity: opacity,
        child: child,
      ),
    );
  }

  Gradient _buildGradient(List<Color> colors) {
    switch (type) {
      case GradientType.vertical:
        return LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case GradientType.horizontal:
        return LinearGradient(
          colors: colors,
          begin: AlignmentDirectional.centerEnd,
          end: AlignmentDirectional.centerStart,
        );
      case GradientType.diagonal:
        return LinearGradient(
          colors: colors,
          begin: AlignmentDirectional.topEnd,
          end: AlignmentDirectional.bottomStart,
        );
      case GradientType.radial:
        return RadialGradient(
          colors: colors,
          center: Alignment.center,
          radius: 1.0,
        );
    }
  }
}

/// خلفية تسجيل الدخول مع أنماط
class LoginBackground extends StatelessWidget {
  final Widget child;
  final bool showPatterns;
  final bool isDark;
  final double? height;

  const LoginBackground({
    super.key,
    required this.child,
    this.showPatterns = true,
    this.isDark = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = isDark
        ? const [
            Color(0xFF064E3B),
            Color(0xFF065F46),
            Color(0xFF047857),
          ]
        : const [
            Color(0xFF059669),
            Color(0xFF10B981),
            Color(0xFF34D399),
          ];

    Widget content = Stack(
      children: [
        // الخلفية المتدرجة
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // الأنماط الزخرفية
        if (showPatterns) ...[
          // دوائر شفافة
          PositionedDirectional(
            top: -100,
            end: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -50,
            start: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          PositionedDirectional(
            top: 200,
            start: 50,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 300,
            end: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          // خطوط مائلة
          Positioned.fill(
            child: CustomPaint(
              painter: _DiagonalLinesPainter(
                color: Colors.white.withValues(alpha: 0.02),
              ),
            ),
          ),
        ],
        // المحتوى
        child,
      ],
    );

    if (height != null) {
      return SizedBox(
        height: height,
        child: content,
      );
    }

    return content;
  }
}

class _DiagonalLinesPainter extends CustomPainter {
  final Color color;

  _DiagonalLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    for (var i = 0.0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(0, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DiagonalLinesPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// خلفية Split للشاشات (نصف أخضر، نصف أبيض)
class SplitBackground extends StatelessWidget {
  final Widget leftChild;
  final Widget rightChild;
  final double leftFlex;
  final double rightFlex;
  final bool showPatterns;

  const SplitBackground({
    super.key,
    required this.leftChild,
    required this.rightChild,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.showPatterns = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (!isWide) {
          // على الموبايل - عرض عمودي
          return Column(
            children: [
              // الجزء الأخضر (أعلى)
              Expanded(
                flex: 2,
                child: LoginBackground(
                  showPatterns: showPatterns,
                  child: leftChild,
                ),
              ),
              // الجزء الأبيض (أسفل)
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.white,
                  child: rightChild,
                ),
              ),
            ],
          );
        }

        // على الويب/تابلت - عرض أفقي
        return Row(
          children: [
            // الجزء الأخضر (يسار)
            Expanded(
              flex: leftFlex.toInt(),
              child: LoginBackground(
                showPatterns: showPatterns,
                child: leftChild,
              ),
            ),
            // الجزء الأبيض (يمين)
            Expanded(
              flex: rightFlex.toInt(),
              child: Container(
                color: Colors.white,
                child: rightChild,
              ),
            ),
          ],
        );
      },
    );
  }
}
