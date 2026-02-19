/// نقاط التجاوب للتطبيق
/// 
/// تُستخدم لتحديد التخطيط المناسب حسب حجم الشاشة
library;

/// تعريف نقاط التجاوب بالبكسل
class Breakpoints {
  Breakpoints._();
  
  /// الهاتف المحمول: 0 - 599px
  static const double mobile = 600;
  
  /// التابلت: 600 - 1199px
  static const double tablet = 1200;
  
  /// سطح المكتب: 1200px وأكثر
  static const double desktop = 1200;
  
  /// الهاتف المحمول الصغير
  static const double mobileSmall = 360;
  
  /// الهاتف المحمول الكبير
  static const double mobileLarge = 480;
}

/// عدد الأعمدة حسب نوع الجهاز
class GridColumns {
  GridColumns._();
  
  /// أعمدة المنتجات على الهاتف
  static const int mobileProducts = 2;
  
  /// أعمدة المنتجات على التابلت
  static const int tabletProducts = 3;
  
  /// أعمدة المنتجات على سطح المكتب
  static const int desktopProducts = 4;
  
  /// أعمدة المنتجات على الشاشات الكبيرة
  static const int largeDesktopProducts = 6;
}

/// نوع الجهاز
enum DeviceType {
  /// هاتف محمول
  mobile,
  
  /// تابلت
  tablet,
  
  /// سطح المكتب
  desktop,
}

/// امتداد للحصول على خصائص نوع الجهاز
extension DeviceTypeExtension on DeviceType {
  /// هل هو هاتف؟
  bool get isMobile => this == DeviceType.mobile;
  
  /// هل هو تابلت؟
  bool get isTablet => this == DeviceType.tablet;
  
  /// هل هو سطح مكتب؟
  bool get isDesktop => this == DeviceType.desktop;
  
  /// هل يجب عرض السلة في BottomSheet؟
  bool get showCartInBottomSheet => isMobile;
  
  /// هل يجب عرض السلة بجانب المنتجات؟
  bool get showCartSideBySide => isTablet || isDesktop;
  
  /// عدد أعمدة المنتجات
  int get productGridColumns {
    switch (this) {
      case DeviceType.mobile:
        return GridColumns.mobileProducts;
      case DeviceType.tablet:
        return GridColumns.tabletProducts;
      case DeviceType.desktop:
        return GridColumns.desktopProducts;
    }
  }
}

/// دالة للحصول على نوع الجهاز من عرض الشاشة
DeviceType getDeviceType(double width) {
  if (width < Breakpoints.mobile) {
    return DeviceType.mobile;
  } else if (width < Breakpoints.tablet) {
    return DeviceType.tablet;
  } else {
    return DeviceType.desktop;
  }
}

/// دالة للحصول على عدد أعمدة المنتجات من عرض الشاشة
int getProductGridColumns(double width) {
  if (width < Breakpoints.mobile) {
    return 2;
  } else if (width < Breakpoints.tablet) {
    return 3;
  } else if (width < 1600) {
    return 4;
  } else {
    return 6;
  }
}
