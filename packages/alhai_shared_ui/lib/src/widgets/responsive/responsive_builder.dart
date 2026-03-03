import 'package:flutter/material.dart';
import '../../core/constants/breakpoints.dart';

/// Widget لبناء واجهات متجاوبة
/// 
/// يوفر نوع الجهاز وعرض الشاشة للـ builder
class ResponsiveBuilder extends StatelessWidget {
  /// البناء الرئيسي الذي يستقبل نوع الجهاز
  final Widget Function(BuildContext context, DeviceType deviceType, double screenWidth) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final deviceType = getDeviceType(width);
        return builder(context, deviceType, width);
      },
    );
  }
}

/// Widget لعرض محتوى مختلف حسب نوع الجهاز
class ResponsiveLayout extends StatelessWidget {
  /// المحتوى على الهاتف
  final Widget mobile;
  
  /// المحتوى على التابلت (اختياري، يستخدم desktop إذا لم يُحدد)
  final Widget? tablet;
  
  /// المحتوى على سطح المكتب
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, _) {
        switch (deviceType) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet ?? desktop;
          case DeviceType.desktop:
            return desktop;
        }
      },
    );
  }
}

/// Widget لعرض محتوى مختلف حسب عرض الشاشة
class ScreenSizeBuilder extends StatelessWidget {
  /// البناء الذي يستقبل عرض الشاشة
  final Widget Function(BuildContext context, double width, double height) builder;

  const ScreenSizeBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, constraints.maxWidth, constraints.maxHeight);
      },
    );
  }
}

/// امتدادات للـ BuildContext للوصول السريع لمعلومات الشاشة
///
/// ملاحظة: الخصائص الأساسية (screenWidth, screenHeight, isMobile, isTablet, isDesktop)
/// موجودة في [AlhaiContextExtensions] من alhai_design_system.
/// هذا الامتداد يضيف خصائص خاصة بنقطة البيع فقط.
extension ResponsiveExtension on BuildContext {
  /// نوع الجهاز
  DeviceType get deviceType => getDeviceType(MediaQuery.sizeOf(this).width);

  /// عدد أعمدة المنتجات المناسب
  int get productGridColumns => getProductGridColumns(MediaQuery.sizeOf(this).width);

  /// هل يجب عرض السلة في BottomSheet؟
  bool get showCartInBottomSheet => deviceType.showCartInBottomSheet;
}

/// GridView متجاوب يحدد عدد الأعمدة تلقائياً
class ResponsiveGridView extends StatelessWidget {
  /// عناصر الـ Grid
  final int itemCount;
  
  /// بناء كل عنصر
  final Widget Function(BuildContext context, int index) itemBuilder;
  
  /// التباعد بين العناصر
  final double spacing;
  
  /// نسبة العرض للارتفاع
  final double childAspectRatio;
  
  /// حد أدنى لعرض العنصر
  final double minItemWidth;
  
  /// الحشوة
  final EdgeInsetsGeometry padding;

  const ResponsiveGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 8,
    this.childAspectRatio = 0.85,
    this.minItemWidth = 140,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - padding.horizontal;
        final columns = (width / minItemWidth).floor().clamp(2, 6);
        
        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
