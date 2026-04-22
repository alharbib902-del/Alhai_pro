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

    when(
      () => categoriesDao.getAllCategories(any()),
    ).thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('ProductFormScreen', () {
    testWidgets('renders correctly in add mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ProductFormScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ProductFormScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows form fields', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ProductFormScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(TextFormField), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows save button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ProductFormScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.add_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows image section icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const ProductFormScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.image_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = ProductFormScreen();
      expect(screen, isA<ProductFormScreen>());
    });

    // C-4 Stage B regression: price + costPrice columns are int cents, but the
    // form seed used to read them as SAR (toStringAsFixed on raw cents). Opening
    // a product and saving without edit caused 100× corruption on every round
    // trip because the save handler multiplies typed SAR by 100.
    testWidgets('edit mode seeds price/costPrice fields in SAR (cents / 100)',
        (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final product = createTestProduct(
        id: 'prod-roundtrip',
        price: 1234,
        costPrice: 789,
      );
      when(
        () => productsDao.getProductById('prod-roundtrip'),
      ).thenAnswer((_) async => product);

      await tester.pumpWidget(
        createTestWidget(
          const ProductFormScreen(productId: 'prod-roundtrip'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('12.34'), findsOneWidget);
      expect(find.text('7.89'), findsOneWidget);
      expect(find.text('1234.00'), findsNothing);
      expect(find.text('789.00'), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('edit mode leaves costPrice field empty when null', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      final product = createTestProduct(
        id: 'prod-no-cost',
        price: 2000,
        costPrice: null,
      );
      when(
        () => productsDao.getProductById('prod-no-cost'),
      ).thenAnswer((_) async => product);

      await tester.pumpWidget(
        createTestWidget(
          const ProductFormScreen(productId: 'prod-no-cost'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('20.00'), findsOneWidget);
      expect(find.text('0.00'), findsNothing);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
