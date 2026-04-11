import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiListTile', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const AlhaiListTile(title: Text('Tile Title'))),
      );

      expect(find.text('Tile Title'), findsOneWidget);
    });

    testWidgets('renders subtitle', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiListTile(title: Text('Title'), subtitle: Text('Subtitle')),
        ),
      );

      expect(find.text('Subtitle'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiListTile(
            title: Text('Title'),
            leading: Icon(Icons.person),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiListTile(
            title: Text('Title'),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiListTile(
            title: const Text('Tappable'),
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Tappable'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('calls onLongPress when long pressed', (tester) async {
      var longPressed = false;
      await tester.pumpWidget(
        createTestWidget(
          AlhaiListTile(
            title: const Text('Long Press'),
            onLongPress: () => longPressed = true,
          ),
        ),
      );

      await tester.longPress(find.text('Long Press'));
      await tester.pump();

      expect(longPressed, isTrue);
    });

    testWidgets('applies reduced opacity when disabled', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const AlhaiListTile(title: Text('Disabled'), disabled: true),
        ),
      );

      final opacityFinder = find.byWidgetPredicate(
        (w) => w is Opacity && w.opacity < 1.0,
      );
      expect(opacityFinder, findsOneWidget);
    });

    testWidgets('standard factory renders', (tester) async {
      await tester.pumpWidget(
        createTestWidget(AlhaiListTile.standard(title: const Text('Standard'))),
      );

      expect(find.text('Standard'), findsOneWidget);
    });

    test('AlhaiListTileVariant has expected values', () {
      expect(AlhaiListTileVariant.values.length, 2);
      expect(
        AlhaiListTileVariant.values,
        contains(AlhaiListTileVariant.standard),
      );
      expect(
        AlhaiListTileVariant.values,
        contains(AlhaiListTileVariant.compact),
      );
    });
  });
}
