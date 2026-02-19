import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/theme/app_colors.dart';

// ===========================================
// App Colors Tests
// ===========================================

void main() {
  group('AppColors - Primary Colors', () {
    test('الألوان الأساسية معرفة', () {
      expect(AppColors.primary, isA<Color>());
      expect(AppColors.primaryLight, isA<Color>());
      expect(AppColors.primaryDark, isA<Color>());
      expect(AppColors.primarySurface, isA<Color>());
      expect(AppColors.primaryBorder, isA<Color>());
    });

    test('اللون الأساسي هو الأخضر الزمردي', () {
      expect(AppColors.primary, const Color(0xFF10B981));
    });
  });

  group('AppColors - Secondary Colors', () {
    test('الألوان الثانوية معرفة', () {
      expect(AppColors.secondary, isA<Color>());
      expect(AppColors.secondaryLight, isA<Color>());
      expect(AppColors.secondaryDark, isA<Color>());
      expect(AppColors.secondarySurface, isA<Color>());
    });

    test('اللون الثانوي هو البرتقالي', () {
      expect(AppColors.secondary, const Color(0xFFF97316));
    });
  });

  group('AppColors - Semantic Colors', () {
    test('ألوان المعاني معرفة', () {
      expect(AppColors.success, isA<Color>());
      expect(AppColors.warning, isA<Color>());
      expect(AppColors.error, isA<Color>());
      expect(AppColors.info, isA<Color>());
    });

    test('القيم صحيحة', () {
      expect(AppColors.success, const Color(0xFF22C55E));
      expect(AppColors.warning, const Color(0xFFF59E0B));
      expect(AppColors.error, const Color(0xFFEF4444));
      expect(AppColors.info, const Color(0xFF3B82F6));
    });
  });

  group('AppColors - Money Colors', () {
    test('ألوان المال معرفة', () {
      expect(AppColors.cash, isA<Color>());
      expect(AppColors.card, isA<Color>());
      expect(AppColors.debt, isA<Color>());
      expect(AppColors.credit, isA<Color>());
    });
  });

  group('AppColors - Stock Colors', () {
    test('ألوان المخزون معرفة', () {
      expect(AppColors.stockAvailable, isA<Color>());
      expect(AppColors.stockLow, isA<Color>());
      expect(AppColors.stockOut, isA<Color>());
    });

    test('القيم صحيحة', () {
      expect(AppColors.stockAvailable, const Color(0xFF22C55E)); // أخضر
      expect(AppColors.stockLow, const Color(0xFFF59E0B)); // أصفر
      expect(AppColors.stockOut, const Color(0xFFEF4444)); // أحمر
    });
  });

  group('AppColors - Category Colors', () {
    test('ألوان التصنيفات معرفة', () {
      expect(AppColors.categoryFruits, isA<Color>());
      expect(AppColors.categoryVegetables, isA<Color>());
      expect(AppColors.categoryDairy, isA<Color>());
      expect(AppColors.categoryMeat, isA<Color>());
      expect(AppColors.categoryBakery, isA<Color>());
      expect(AppColors.categoryDrinks, isA<Color>());
      expect(AppColors.categorySnacks, isA<Color>());
      expect(AppColors.categoryCleaning, isA<Color>());
    });
  });

  group('AppColors.getStockColor', () {
    test('يُرجع stockOut عندما الكمية = 0', () {
      expect(AppColors.getStockColor(0, 10), AppColors.stockOut);
    });

    test('يُرجع stockOut عندما الكمية سالبة', () {
      expect(AppColors.getStockColor(-5, 10), AppColors.stockOut);
    });

    test('يُرجع stockLow عندما الكمية <= الحد الأدنى', () {
      expect(AppColors.getStockColor(5, 10), AppColors.stockLow);
      expect(AppColors.getStockColor(10, 10), AppColors.stockLow);
    });

    test('يُرجع stockAvailable عندما الكمية > الحد الأدنى', () {
      expect(AppColors.getStockColor(11, 10), AppColors.stockAvailable);
      expect(AppColors.getStockColor(100, 10), AppColors.stockAvailable);
    });

    test('الحدود الدقيقة', () {
      expect(AppColors.getStockColor(1, 1), AppColors.stockLow);
      expect(AppColors.getStockColor(2, 1), AppColors.stockAvailable);
    });
  });

  group('AppColors.getBalanceColor', () {
    test('يُرجع debt عندما الرصيد موجب', () {
      expect(AppColors.getBalanceColor(100), AppColors.debt);
      expect(AppColors.getBalanceColor(0.01), AppColors.debt);
    });

    test('يُرجع credit عندما الرصيد سالب', () {
      expect(AppColors.getBalanceColor(-100), AppColors.credit);
      expect(AppColors.getBalanceColor(-0.01), AppColors.credit);
    });

    test('يُرجع textMuted عندما الرصيد = 0', () {
      expect(AppColors.getBalanceColor(0), AppColors.textMuted);
    });
  });

  group('AppColors.getPaymentMethodColor', () {
    test('يُرجع cash للنقد بالإنجليزية', () {
      expect(AppColors.getPaymentMethodColor('cash'), AppColors.cash);
      expect(AppColors.getPaymentMethodColor('CASH'), AppColors.cash);
      expect(AppColors.getPaymentMethodColor('Cash'), AppColors.cash);
    });

    test('يُرجع cash للنقد بالعربية', () {
      expect(AppColors.getPaymentMethodColor('نقد'), AppColors.cash);
    });

    test('يُرجع card للبطاقة بالإنجليزية', () {
      expect(AppColors.getPaymentMethodColor('card'), AppColors.card);
      expect(AppColors.getPaymentMethodColor('CARD'), AppColors.card);
    });

    test('يُرجع card للبطاقة بالعربية', () {
      expect(AppColors.getPaymentMethodColor('بطاقة'), AppColors.card);
    });

    test('يُرجع debt للآجل', () {
      expect(AppColors.getPaymentMethodColor('credit'), AppColors.debt);
      expect(AppColors.getPaymentMethodColor('آجل'), AppColors.debt);
    });

    test('يُرجع primary للطرق غير المعروفة', () {
      expect(AppColors.getPaymentMethodColor('unknown'), AppColors.primary);
      expect(AppColors.getPaymentMethodColor(''), AppColors.primary);
    });
  });

  group('AppColors.getCategoryColor', () {
    test('يُرجع ألوان التصنيفات بالإنجليزية', () {
      expect(AppColors.getCategoryColor('fruits'), AppColors.categoryFruits);
      expect(AppColors.getCategoryColor('vegetables'), AppColors.categoryVegetables);
      expect(AppColors.getCategoryColor('dairy'), AppColors.categoryDairy);
      expect(AppColors.getCategoryColor('meat'), AppColors.categoryMeat);
      expect(AppColors.getCategoryColor('bakery'), AppColors.categoryBakery);
      expect(AppColors.getCategoryColor('drinks'), AppColors.categoryDrinks);
      expect(AppColors.getCategoryColor('snacks'), AppColors.categorySnacks);
      expect(AppColors.getCategoryColor('cleaning'), AppColors.categoryCleaning);
    });

    test('يُرجع ألوان التصنيفات بالعربية', () {
      expect(AppColors.getCategoryColor('فواكه'), AppColors.categoryFruits);
      expect(AppColors.getCategoryColor('خضروات'), AppColors.categoryVegetables);
      expect(AppColors.getCategoryColor('ألبان'), AppColors.categoryDairy);
      expect(AppColors.getCategoryColor('لحوم'), AppColors.categoryMeat);
      expect(AppColors.getCategoryColor('مخبوزات'), AppColors.categoryBakery);
      expect(AppColors.getCategoryColor('مشروبات'), AppColors.categoryDrinks);
      expect(AppColors.getCategoryColor('سناكس'), AppColors.categorySnacks);
      expect(AppColors.getCategoryColor('تنظيف'), AppColors.categoryCleaning);
    });

    test('يتعامل مع حالة الأحرف', () {
      expect(AppColors.getCategoryColor('FRUITS'), AppColors.categoryFruits);
      expect(AppColors.getCategoryColor('Vegetables'), AppColors.categoryVegetables);
    });

    test('يُرجع primary للتصنيفات غير المعروفة', () {
      expect(AppColors.getCategoryColor('unknown'), AppColors.primary);
      expect(AppColors.getCategoryColor(''), AppColors.primary);
      expect(AppColors.getCategoryColor('أخرى'), AppColors.primary);
    });
  });

  group('AppColors - Gradients', () {
    test('التدرجات معرفة', () {
      expect(AppColors.primaryGradient, isA<LinearGradient>());
      expect(AppColors.secondaryGradient, isA<LinearGradient>());
      expect(AppColors.successGradient, isA<LinearGradient>());
      expect(AppColors.cardGradient, isA<LinearGradient>());
    });

    test('التدرج الأساسي يحتوي على ألوان صحيحة', () {
      expect(AppColors.primaryGradient.colors.length, 2);
      expect(AppColors.primaryGradient.begin, Alignment.topLeft);
      expect(AppColors.primaryGradient.end, Alignment.bottomRight);
    });
  });

  group('AppColors - Neutral Colors', () {
    test('الألوان المحايدة معرفة', () {
      expect(AppColors.white, const Color(0xFFFFFFFF));
      expect(AppColors.black, const Color(0xFF000000));
      expect(AppColors.grey50, isA<Color>());
      expect(AppColors.grey100, isA<Color>());
      expect(AppColors.grey500, isA<Color>());
      expect(AppColors.grey900, isA<Color>());
    });
  });

  group('AppColors - Background & Surface', () {
    test('ألوان الخلفية معرفة', () {
      expect(AppColors.background, isA<Color>());
      expect(AppColors.surface, isA<Color>());
      expect(AppColors.surfaceVariant, isA<Color>());
      expect(AppColors.border, isA<Color>());
      expect(AppColors.divider, isA<Color>());
    });

    test('ألوان الوضع الداكن معرفة', () {
      expect(AppColors.backgroundDark, isA<Color>());
      expect(AppColors.surfaceDark, isA<Color>());
      expect(AppColors.surfaceVariantDark, isA<Color>());
      expect(AppColors.borderDark, isA<Color>());
    });
  });

  group('AppColors - Text Colors', () {
    test('ألوان النص معرفة', () {
      expect(AppColors.textPrimary, isA<Color>());
      expect(AppColors.textSecondary, isA<Color>());
      expect(AppColors.textMuted, isA<Color>());
      expect(AppColors.textOnPrimary, isA<Color>());
    });

    test('ألوان النص للوضع الداكن معرفة', () {
      expect(AppColors.textPrimaryDark, isA<Color>());
      expect(AppColors.textSecondaryDark, isA<Color>());
      expect(AppColors.textMutedDark, isA<Color>());
    });
  });
}
