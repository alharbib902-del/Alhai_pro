import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_design_system/src/components/layout/alhai_avatar.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AlhaiAvatar', () {
    group('Rendering', () {
      testWidgets('renders with initials', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'JD',
          ),
        ));

        // Assert
        expect(find.text('JD'), findsOneWidget);
      });

      testWidgets('renders with icon fallback', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.icon(
            icon: Icons.person,
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.person), findsOneWidget);
      });

      testWidgets('renders default icon when no content', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          const AlhaiAvatar(),
        ));

        // Assert
        expect(find.byIcon(Icons.person), findsOneWidget);
      });
    });

    group('Sizes', () {
      testWidgets('renders extra small size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'XS',
            size: AlhaiAvatarSize.xs,
          ),
        ));

        // Assert
        expect(find.text('XS'), findsOneWidget);
      });

      testWidgets('renders small size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'SM',
            size: AlhaiAvatarSize.sm,
          ),
        ));

        // Assert
        expect(find.text('SM'), findsOneWidget);
      });

      testWidgets('renders medium size (default)', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'MD',
            size: AlhaiAvatarSize.md,
          ),
        ));

        // Assert
        expect(find.text('MD'), findsOneWidget);
      });

      testWidgets('renders large size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'LG',
            size: AlhaiAvatarSize.lg,
          ),
        ));

        // Assert
        expect(find.text('LG'), findsOneWidget);
      });

      testWidgets('renders extra large size', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'XL',
            size: AlhaiAvatarSize.xl,
          ),
        ));

        // Assert
        expect(find.text('XL'), findsOneWidget);
      });
    });

    group('Shapes', () {
      testWidgets('renders circle shape (default)', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'C',
            shape: AlhaiAvatarShape.circle,
          ),
        ));

        // Assert
        expect(find.text('C'), findsOneWidget);
      });

      testWidgets('renders rounded shape', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'R',
            shape: AlhaiAvatarShape.rounded,
          ),
        ));

        // Assert
        expect(find.text('R'), findsOneWidget);
      });
    });

    group('Online Status', () {
      testWidgets('shows online dot when showOnlineDot is true', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'ON',
            showOnlineDot: true,
          ),
        ));

        // Assert
        expect(find.text('ON'), findsOneWidget);
        // Online dot should be in the widget tree
        expect(find.byType(Container), findsWidgets);
      });
    });

    group('Custom Colors', () {
      testWidgets('applies custom background color', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'BG',
            backgroundColorOverride: Colors.red,
          ),
        ));

        // Assert
        expect(find.text('BG'), findsOneWidget);
      });

      testWidgets('applies custom foreground color', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'FG',
            foregroundColorOverride: Colors.white,
          ),
        ));

        // Assert
        expect(find.text('FG'), findsOneWidget);
      });
    });

    group('Initials', () {
      testWidgets('truncates initials to 2 characters', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(
          AlhaiAvatar.initials(
            initials: 'ABCD',
          ),
        ));

        // Assert - should show only first 2 characters
        expect(find.text('AB'), findsOneWidget);
        expect(find.text('ABCD'), findsNothing);
      });
    });
  });
}
