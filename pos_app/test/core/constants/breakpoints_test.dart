import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/constants/breakpoints.dart';

// ===========================================
// Breakpoints Tests
// ===========================================

void main() {
  group('Breakpoints', () {
    test('القيم الثابتة صحيحة', () {
      expect(Breakpoints.mobile, 600);
      expect(Breakpoints.tablet, 1200);
      expect(Breakpoints.desktop, 1200);
      expect(Breakpoints.mobileSmall, 360);
      expect(Breakpoints.mobileLarge, 480);
    });
  });

  group('GridColumns', () {
    test('القيم الثابتة صحيحة', () {
      expect(GridColumns.mobileProducts, 2);
      expect(GridColumns.tabletProducts, 3);
      expect(GridColumns.desktopProducts, 4);
      expect(GridColumns.largeDesktopProducts, 6);
    });
  });

  group('DeviceType enum', () {
    test('يحتوي على جميع الأنواع', () {
      expect(DeviceType.values.length, 3);
      expect(DeviceType.values, contains(DeviceType.mobile));
      expect(DeviceType.values, contains(DeviceType.tablet));
      expect(DeviceType.values, contains(DeviceType.desktop));
    });
  });

  group('DeviceTypeExtension', () {
    group('isMobile', () {
      test('يُرجع true للموبايل فقط', () {
        expect(DeviceType.mobile.isMobile, isTrue);
        expect(DeviceType.tablet.isMobile, isFalse);
        expect(DeviceType.desktop.isMobile, isFalse);
      });
    });

    group('isTablet', () {
      test('يُرجع true للتابلت فقط', () {
        expect(DeviceType.mobile.isTablet, isFalse);
        expect(DeviceType.tablet.isTablet, isTrue);
        expect(DeviceType.desktop.isTablet, isFalse);
      });
    });

    group('isDesktop', () {
      test('يُرجع true للديسكتوب فقط', () {
        expect(DeviceType.mobile.isDesktop, isFalse);
        expect(DeviceType.tablet.isDesktop, isFalse);
        expect(DeviceType.desktop.isDesktop, isTrue);
      });
    });

    group('showCartInBottomSheet', () {
      test('يُرجع true للموبايل فقط', () {
        expect(DeviceType.mobile.showCartInBottomSheet, isTrue);
        expect(DeviceType.tablet.showCartInBottomSheet, isFalse);
        expect(DeviceType.desktop.showCartInBottomSheet, isFalse);
      });
    });

    group('showCartSideBySide', () {
      test('يُرجع true للتابلت والديسكتوب', () {
        expect(DeviceType.mobile.showCartSideBySide, isFalse);
        expect(DeviceType.tablet.showCartSideBySide, isTrue);
        expect(DeviceType.desktop.showCartSideBySide, isTrue);
      });
    });

    group('productGridColumns', () {
      test('يُرجع عدد الأعمدة الصحيح لكل نوع', () {
        expect(DeviceType.mobile.productGridColumns, GridColumns.mobileProducts);
        expect(DeviceType.tablet.productGridColumns, GridColumns.tabletProducts);
        expect(DeviceType.desktop.productGridColumns, GridColumns.desktopProducts);
      });

      test('قيم محددة', () {
        expect(DeviceType.mobile.productGridColumns, 2);
        expect(DeviceType.tablet.productGridColumns, 3);
        expect(DeviceType.desktop.productGridColumns, 4);
      });
    });
  });

  group('getDeviceType', () {
    test('يُرجع mobile لعرض أقل من 600', () {
      expect(getDeviceType(0), DeviceType.mobile);
      expect(getDeviceType(300), DeviceType.mobile);
      expect(getDeviceType(599), DeviceType.mobile);
    });

    test('يُرجع tablet لعرض بين 600 و 1199', () {
      expect(getDeviceType(600), DeviceType.tablet);
      expect(getDeviceType(800), DeviceType.tablet);
      expect(getDeviceType(1199), DeviceType.tablet);
    });

    test('يُرجع desktop لعرض 1200 وأكثر', () {
      expect(getDeviceType(1200), DeviceType.desktop);
      expect(getDeviceType(1500), DeviceType.desktop);
      expect(getDeviceType(1920), DeviceType.desktop);
    });

    test('الحدود الدقيقة', () {
      expect(getDeviceType(599.9), DeviceType.mobile);
      expect(getDeviceType(600.0), DeviceType.tablet);
      expect(getDeviceType(1199.9), DeviceType.tablet);
      expect(getDeviceType(1200.0), DeviceType.desktop);
    });
  });

  group('getProductGridColumns', () {
    test('يُرجع 2 للشاشات الصغيرة جداً', () {
      expect(getProductGridColumns(300), 2);
      expect(getProductGridColumns(359), 2);
    });

    test('يُرجع 2 للموبايل العادي', () {
      expect(getProductGridColumns(360), 2);
      expect(getProductGridColumns(500), 2);
      expect(getProductGridColumns(599), 2);
    });

    test('يُرجع 3 للتابلت', () {
      expect(getProductGridColumns(600), 3);
      expect(getProductGridColumns(800), 3);
      expect(getProductGridColumns(1199), 3);
    });

    test('يُرجع 4 للديسكتوب العادي', () {
      expect(getProductGridColumns(1200), 4);
      expect(getProductGridColumns(1400), 4);
      expect(getProductGridColumns(1599), 4);
    });

    test('يُرجع 6 للشاشات الكبيرة جداً', () {
      expect(getProductGridColumns(1600), 6);
      expect(getProductGridColumns(1920), 6);
      expect(getProductGridColumns(2560), 6);
    });

    test('الحدود الدقيقة', () {
      expect(getProductGridColumns(359.9), 2);
      expect(getProductGridColumns(599.9), 2);
      expect(getProductGridColumns(1199.9), 3);
      expect(getProductGridColumns(1599.9), 4);
    });
  });
}
