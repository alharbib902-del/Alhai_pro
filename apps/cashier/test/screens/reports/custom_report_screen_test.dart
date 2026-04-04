library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cashier/screens/reports/custom_report_screen.dart';

import '../../helpers/test_helpers.dart';
import '../../helpers/mock_database.dart';

void main() {
  late MockOrdersDao ordersDao;
  late MockProductsDao productsDao;
  late MockCustomersDao customersDao;

  setUpAll(() => registerCashierFallbackValues());

  setUp(() {
    ordersDao = MockOrdersDao();
    productsDao = MockProductsDao();
    customersDao = MockCustomersDao();

    // CustomReportScreen calls _db.ordersDao.getOrders(),
    // _db.productsDao.getAllProducts(), _db.customersDao.getAllCustomers()
    // when generating reports. On init it just renders the form.
    when(() => ordersDao.getOrders(any())).thenAnswer((_) async => []);
    when(() => productsDao.getAllProducts(any())).thenAnswer((_) async => []);
    when(() => customersDao.getAllCustomers(any())).thenAnswer((_) async => []);

    final db = setupMockDatabase(
      ordersDao: ordersDao,
      productsDao: productsDao,
      customersDao: customersDao,
    );
    setupTestGetIt(mockDb: db);
  });

  tearDown(() => tearDownTestGetIt());

  group('CustomReportScreen', () {
    testWidgets('renders the report builder form', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CustomReportScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomReportScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has report type dropdown', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CustomReportScreen()),
      );
      await tester.pumpAndSettle();

      // Report type selector uses custom InkWell chips (sales, inventory, customers, payments)
      expect(find.byType(InkWell), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders in dark mode', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(
          const CustomReportScreen(),
          theme: ThemeData.dark(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomReportScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('renders on mobile viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CustomReportScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomReportScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('has generate report button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
        createTestWidget(const CustomReportScreen()),
      );
      await tester.pumpAndSettle();

      // Should have an elevated button or similar to generate reports
      expect(find.byType(ElevatedButton), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
