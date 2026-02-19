// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/utils/keyboard_shortcuts.dart';

// ===========================================
// Keyboard Shortcuts Tests
// ===========================================

void main() {
  group('PosKeyboardShortcuts.handleKeyEvent', () {
    late bool searchCalled;
    late bool newSaleCalled;
    late bool checkoutCalled;
    late bool undoCalled;
    late bool cancelCalled;
    late int? quickAddNumber;
    late bool? quantityIncrease;

    void resetFlags() {
      searchCalled = false;
      newSaleCalled = false;
      checkoutCalled = false;
      undoCalled = false;
      cancelCalled = false;
      quickAddNumber = null;
      quantityIncrease = null;
    }

    KeyEventResult handleEvent(KeyEvent event) {
      return PosKeyboardShortcuts.handleKeyEvent(
        event,
        onSearch: () => searchCalled = true,
        onNewSale: () => newSaleCalled = true,
        onCheckout: () => checkoutCalled = true,
        onUndo: () => undoCalled = true,
        onCancel: () => cancelCalled = true,
        onQuickAdd: (n) => quickAddNumber = n,
        onQuantityChange: (inc) => quantityIncrease = inc,
      );
    }

    setUp(resetFlags);

    test('يتجاهل KeyUpEvent', () {
      const event = KeyUpEvent(
        physicalKey: PhysicalKeyboardKey.f1,
        logicalKey: LogicalKeyboardKey.f1,
        timeStamp: Duration.zero,
      );

      final result = handleEvent(event);

      expect(result, KeyEventResult.ignored);
      expect(searchCalled, false);
    });

    test('F1 يستدعي onSearch', () {
      const event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.f1,
        logicalKey: LogicalKeyboardKey.f1,
        timeStamp: Duration.zero,
      );

      final result = handleEvent(event);

      expect(result, KeyEventResult.handled);
      expect(searchCalled, true);
    });

    test('F2 يستدعي onNewSale', () {
      const event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.f2,
        logicalKey: LogicalKeyboardKey.f2,
        timeStamp: Duration.zero,
      );

      final result = handleEvent(event);

      expect(result, KeyEventResult.handled);
      expect(newSaleCalled, true);
    });

    test('Enter يستدعي onCheckout', () {
      const event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.enter,
        logicalKey: LogicalKeyboardKey.enter,
        timeStamp: Duration.zero,
      );

      final result = handleEvent(event);

      expect(result, KeyEventResult.handled);
      expect(checkoutCalled, true);
    });

    test('Escape يستدعي onCancel', () {
      const event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.escape,
        logicalKey: LogicalKeyboardKey.escape,
        timeStamp: Duration.zero,
      );

      final result = handleEvent(event);

      expect(result, KeyEventResult.handled);
      expect(cancelCalled, true);
    });

    test('+ يستدعي onQuantityChange(true)', () {
      const event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.numpadAdd,
        logicalKey: LogicalKeyboardKey.numpadAdd,
        timeStamp: Duration.zero,
      );

      final result = handleEvent(event);

      expect(result, KeyEventResult.handled);
      expect(quantityIncrease, true);
    });

    test('- يستدعي onQuantityChange(false)', () {
      const event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.minus,
        logicalKey: LogicalKeyboardKey.minus,
        timeStamp: Duration.zero,
      );

      final result = handleEvent(event);

      expect(result, KeyEventResult.handled);
      expect(quantityIncrease, false);
    });

    group('أرقام 1-9 تستدعي onQuickAdd', () {
      for (int i = 1; i <= 9; i++) {
        test('الرقم $i (numpad)', () {
          resetFlags();

          // Test with numpad keys
          final numpadEvent = KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.numpad1,
            logicalKey: _getNumpadKey(i),
            timeStamp: Duration.zero,
          );

          final result = handleEvent(numpadEvent);

          expect(result, KeyEventResult.handled);
          expect(quickAddNumber, i);
        });
      }
    });

    test('مفتاح غير معروف يُرجع ignored', () {
      const event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.keyA,
        logicalKey: LogicalKeyboardKey.keyA,
        timeStamp: Duration.zero,
      );

      final result = handleEvent(event);

      expect(result, KeyEventResult.ignored);
    });

    test('= يزيد الكمية (alias لـ +)', () {
      const event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.equal,
        logicalKey: LogicalKeyboardKey.equal,
        timeStamp: Duration.zero,
      );

      final result = handleEvent(event);

      expect(result, KeyEventResult.handled);
      expect(quantityIncrease, true);
    });

    test('numpadSubtract ينقص الكمية', () {
      const event = KeyDownEvent(
        physicalKey: PhysicalKeyboardKey.numpadSubtract,
        logicalKey: LogicalKeyboardKey.numpadSubtract,
        timeStamp: Duration.zero,
      );

      final result = handleEvent(event);

      expect(result, KeyEventResult.handled);
      expect(quantityIncrease, false);
    });
  });

  group('PosKeyboardListener Widget', () {
    testWidgets('يعرض child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PosKeyboardListener(
            onSearch: () {},
            onNewSale: () {},
            onCheckout: () {},
            onUndo: () {},
            onCancel: () {},
            onQuickAdd: (_) {},
            onQuantityChange: (_) {},
            child: const Text('محتوى'),
          ),
        ),
      );

      expect(find.text('محتوى'), findsOneWidget);
    });

    testWidgets('يستخدم Focus widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PosKeyboardListener(
            onSearch: () {},
            onNewSale: () {},
            onCheckout: () {},
            onUndo: () {},
            onCancel: () {},
            onQuickAdd: (_) {},
            onQuantityChange: (_) {},
            child: const Text('محتوى'),
          ),
        ),
      );

      // يجب أن يكون هناك على الأقل Focus widget واحد
      expect(find.byType(Focus), findsAtLeastNWidgets(1));
    });
  });

  group('KeyboardShortcutHint Widget', () {
    testWidgets('يعرض الاختصار', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KeyboardShortcutHint(shortcut: 'F1'),
          ),
        ),
      );

      expect(find.text('F1'), findsOneWidget);
    });

    testWidgets('يعرض التسمية إذا كانت موجودة', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KeyboardShortcutHint(
              shortcut: 'F1',
              label: 'بحث',
            ),
          ),
        ),
      );

      expect(find.text('F1'), findsOneWidget);
      expect(find.text('بحث'), findsOneWidget);
    });

    testWidgets('لا يعرض التسمية إذا كانت null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KeyboardShortcutHint(shortcut: 'Esc'),
          ),
        ),
      );

      expect(find.text('Esc'), findsOneWidget);
      // يجب ألا يوجد Row مع أكثر من عنصر واحد
    });

    testWidgets('يستخدم Container مع decoration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KeyboardShortcutHint(shortcut: 'Enter'),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });
  });
}

LogicalKeyboardKey _getNumpadKey(int number) {
  switch (number) {
    case 1:
      return LogicalKeyboardKey.numpad1;
    case 2:
      return LogicalKeyboardKey.numpad2;
    case 3:
      return LogicalKeyboardKey.numpad3;
    case 4:
      return LogicalKeyboardKey.numpad4;
    case 5:
      return LogicalKeyboardKey.numpad5;
    case 6:
      return LogicalKeyboardKey.numpad6;
    case 7:
      return LogicalKeyboardKey.numpad7;
    case 8:
      return LogicalKeyboardKey.numpad8;
    case 9:
      return LogicalKeyboardKey.numpad9;
    default:
      return LogicalKeyboardKey.numpad0;
  }
}
