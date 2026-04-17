import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/widgets/responsive/responsive_builder.dart';
import 'package:alhai_shared_ui/src/core/constants/breakpoints.dart';
import '../../helpers/shared_ui_test_helpers.dart';

void main() {
  group('ResponsiveBuilder', () {
    testWidgets('provides device type and screen width', (tester) async {
      DeviceType? capturedType;
      double? capturedWidth;

      await tester.pumpWidget(
        createSimpleTestWidget(
          ResponsiveBuilder(
            builder: (context, deviceType, width) {
              capturedType = deviceType;
              capturedWidth = width;
              return Text('Device: ${deviceType.name}');
            },
          ),
        ),
      );

      expect(capturedType, isNotNull);
      expect(capturedWidth, isNotNull);
      expect(capturedWidth, greaterThan(0));
    });
  });

  group('ResponsiveLayout', () {
    testWidgets('shows mobile content on small screens', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createSimpleTestWidget(
          const ResponsiveLayout(
            mobile: Text('Mobile'),
            desktop: Text('Desktop'),
          ),
        ),
      );
      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('shows desktop content on large screens', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createSimpleTestWidget(
          const ResponsiveLayout(
            mobile: Text('Mobile'),
            desktop: Text('Desktop'),
          ),
        ),
      );
      expect(find.text('Desktop'), findsOneWidget);
      expect(find.text('Mobile'), findsNothing);
    });

    testWidgets('shows tablet content on tablet screens', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createSimpleTestWidget(
          const ResponsiveLayout(
            mobile: Text('Mobile'),
            tablet: Text('Tablet'),
            desktop: Text('Desktop'),
          ),
        ),
      );
      expect(find.text('Tablet'), findsOneWidget);
    });

    testWidgets('falls back to desktop when no tablet provided', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createSimpleTestWidget(
          const ResponsiveLayout(
            mobile: Text('Mobile'),
            desktop: Text('Desktop'),
          ),
        ),
      );
      expect(find.text('Desktop'), findsOneWidget);
    });
  });

  group('ScreenSizeBuilder', () {
    testWidgets('provides width and height', (tester) async {
      double? capturedWidth;
      double? capturedHeight;

      await tester.pumpWidget(
        createSimpleTestWidget(
          ScreenSizeBuilder(
            builder: (context, width, height) {
              capturedWidth = width;
              capturedHeight = height;
              return Text('$width x $height');
            },
          ),
        ),
      );

      expect(capturedWidth, isNotNull);
      expect(capturedHeight, isNotNull);
      expect(capturedWidth, greaterThan(0));
      expect(capturedHeight, greaterThan(0));
    });
  });

  group('ResponsiveGridView', () {
    testWidgets('renders grid items', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          ResponsiveGridView(
            itemCount: 4,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      );
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('adjusts columns based on width', (tester) async {
      await tester.pumpWidget(
        createSimpleTestWidget(
          ResponsiveGridView(
            itemCount: 6,
            minItemWidth: 100,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      );
      expect(find.byType(ResponsiveGridView), findsOneWidget);
    });
  });
}
