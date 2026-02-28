import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('AlhaiAvatar', () {
    testWidgets('renders with default icon fallback', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiAvatar(),
      ));

      expect(find.byType(AlhaiAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders with initials', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiAvatar.initials(initials: 'AB'),
      ));

      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('truncates initials to 2 characters', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiAvatar.initials(initials: 'ABC'),
      ));

      expect(find.text('AB'), findsOneWidget);
      expect(find.text('ABC'), findsNothing);
    });

    testWidgets('renders with custom icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        AlhaiAvatar.icon(icon: Icons.star),
      ));

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows online dot when showOnlineDot is true', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiAvatar(showOnlineDot: true),
      ));

      // Should render a Stack with dot overlay
      expect(find.byType(Stack), findsAtLeast(1));
    });

    testWidgets('shows badge when provided', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const AlhaiAvatar(
          badge: AlhaiBadge(count: 3),
        ),
      ));

      expect(find.text('3'), findsOneWidget);
    });

    group('sizes', () {
      testWidgets('xs size renders with correct diameter', (tester) async {
        await tester.pumpWidget(createTestWidget(
          const AlhaiAvatar(size: AlhaiAvatarSize.xs),
        ));

        final sizedBox = tester.widget<SizedBox>(
          find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == AlhaiSpacing.avatarXs,
          ),
        );
        expect(sizedBox, isNotNull);
      });

      testWidgets('xl size renders with correct diameter', (tester) async {
        await tester.pumpWidget(createTestWidget(
          const AlhaiAvatar(size: AlhaiAvatarSize.xl),
        ));

        final sizedBox = tester.widget<SizedBox>(
          find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == AlhaiSpacing.avatarXl,
          ),
        );
        expect(sizedBox, isNotNull);
      });
    });

    group('shapes', () {
      testWidgets('circle shape renders', (tester) async {
        await tester.pumpWidget(createTestWidget(
          const AlhaiAvatar(shape: AlhaiAvatarShape.circle),
        ));

        expect(find.byType(AlhaiAvatar), findsOneWidget);
      });

      testWidgets('rounded shape renders', (tester) async {
        await tester.pumpWidget(createTestWidget(
          const AlhaiAvatar(shape: AlhaiAvatarShape.rounded),
        ));

        expect(find.byType(AlhaiAvatar), findsOneWidget);
      });
    });

    group('all sizes', () {
      testWidgets('renders small size', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'SM',
            size: AlhaiAvatarSize.sm,
          ),
        ));

        expect(find.text('SM'), findsOneWidget);
      });

      testWidgets('renders medium size', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'MD',
            size: AlhaiAvatarSize.md,
          ),
        ));

        expect(find.text('MD'), findsOneWidget);
      });

      testWidgets('renders large size', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'LG',
            size: AlhaiAvatarSize.lg,
          ),
        ));

        expect(find.text('LG'), findsOneWidget);
      });
    });

    group('custom colors', () {
      testWidgets('applies custom background color', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'BG',
            backgroundColorOverride: Colors.red,
          ),
        ));

        expect(find.text('BG'), findsOneWidget);
      });

      testWidgets('applies custom foreground color', (tester) async {
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'FG',
            foregroundColorOverride: Colors.white,
          ),
        ));

        expect(find.text('FG'), findsOneWidget);
      });
    });
  });
}
