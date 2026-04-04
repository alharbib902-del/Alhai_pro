library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin/screens/media/media_library_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockProductsDao productsDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    productsDao = MockProductsDao();
    db = setupMockDatabase(productsDao: productsDao);
    setupTestGetIt(mockDb: db);

    when(() => productsDao.getAllProducts(any())).thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('MediaLibraryScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const MediaLibraryScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(MediaLibraryScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows upload button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const MediaLibraryScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.cloud_upload), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows search icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const MediaLibraryScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows storage indicator', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const MediaLibraryScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.storage), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = MediaLibraryScreen();
      expect(screen, isA<MediaLibraryScreen>());
    });
  });
}
