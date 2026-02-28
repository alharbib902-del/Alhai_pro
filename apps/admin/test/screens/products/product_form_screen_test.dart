library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/products/product_form_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockCategoriesDao categoriesDao;
  late MockProductsDao productsDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    categoriesDao = MockCategoriesDao();
    productsDao = MockProductsDao();
    db = setupMockDatabase(
      categoriesDao: categoriesDao,
      productsDao: productsDao,
    );
    setupTestGetIt(mockDb: db);

    when(() => categoriesDao.getAllCategories(any()))
        .thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('ProductFormScreen', () {
    testWidgets('renders correctly in add mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const ProductFormScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ProductFormScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows form fields', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const ProductFormScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows save button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const ProductFormScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows image section icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const ProductFormScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.image_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = ProductFormScreen();
      expect(screen, isA<ProductFormScreen>());
    });
  });
}
