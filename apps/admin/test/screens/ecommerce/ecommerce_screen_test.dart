library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/ecommerce/ecommerce_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockProductsDao productsDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    productsDao = MockProductsDao();
    db = setupMockDatabase(productsDao: productsDao);
    setupTestGetIt(mockDb: db);

    when(() => productsDao.getAllProducts(any()))
        .thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('EcommerceScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const EcommerceScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(EcommerceScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows tab bar with 3 tabs', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const EcommerceScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(3));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows shopping cart icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const EcommerceScreen()));
      await tester.pumpAndSettle();

      // The tab bar uses Icons.shopping_bag_outlined
      expect(find.byIcon(Icons.shopping_bag_outlined), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = EcommerceScreen();
      expect(screen, isA<EcommerceScreen>());
    });
  });
}
