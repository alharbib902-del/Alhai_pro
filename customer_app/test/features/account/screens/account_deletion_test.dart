import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import 'package:customer_app/features/profile/screens/profile_screen.dart';

void main() {
  Widget buildTestWidget() {
    return ProviderScope(
      child: MaterialApp(
        title: 'Test',
        theme: AlhaiTheme.light,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const ProfileScreen(),
      ),
    );
  }

  group('Account Deletion (H5)', () {
    testWidgets('delete account button is visible in profile', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Scroll to find the delete button
      await tester.scrollUntilVisible(
        find.text('حذف الحساب'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('حذف الحساب'), findsOneWidget);
    });

    testWidgets('tapping delete account shows confirmation dialog',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Scroll to find the delete button
      await tester.scrollUntilVisible(
        find.text('حذف الحساب'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      // Tap delete account
      await tester.tap(find.text('حذف الحساب'));
      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('حذف الحساب'), findsWidgets); // title + button
      expect(
        find.textContaining('هل أنت متأكد من حذف حسابك'),
        findsOneWidget,
      );
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('حذف نهائياً'), findsOneWidget);
    });
  });
}
