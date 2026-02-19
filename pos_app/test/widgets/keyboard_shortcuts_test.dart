import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/utils/keyboard_shortcuts.dart';

void main() {
  group('PosKeyboardShortcuts Tests', () {
    testWidgets('F1 يستدعي onSearch', (tester) async {
      bool searchCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: PosKeyboardListener(
            onSearch: () => searchCalled = true,
            onNewSale: () {},
            onCheckout: () {},
            onUndo: () {},
            onCancel: () {},
            onQuickAdd: (n) {},
            onQuantityChange: (b) {},
            child: const SizedBox(),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.f1);
      await tester.pump();

      expect(searchCalled, isTrue);
    });

    testWidgets('F2 يستدعي onNewSale', (tester) async {
      bool newSaleCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: PosKeyboardListener(
            onSearch: () {},
            onNewSale: () => newSaleCalled = true,
            onCheckout: () {},
            onUndo: () {},
            onCancel: () {},
            onQuickAdd: (n) {},
            onQuantityChange: (b) {},
            child: const SizedBox(),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.f2);
      await tester.pump();

      expect(newSaleCalled, isTrue);
    });

    testWidgets('Escape يستدعي onCancel', (tester) async {
      bool cancelCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: PosKeyboardListener(
            onSearch: () {},
            onNewSale: () {},
            onCheckout: () {},
            onUndo: () {},
            onCancel: () => cancelCalled = true,
            onQuickAdd: (n) {},
            onQuantityChange: (b) {},
            child: const SizedBox(),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(cancelCalled, isTrue);
    });

    testWidgets('أرقام 1-9 تستدعي onQuickAdd', (tester) async {
      int? pressedNumber;
      
      await tester.pumpWidget(
        MaterialApp(
          home: PosKeyboardListener(
            onSearch: () {},
            onNewSale: () {},
            onCheckout: () {},
            onUndo: () {},
            onCancel: () {},
            onQuickAdd: (n) => pressedNumber = n,
            onQuantityChange: (b) {},
            child: const SizedBox(),
          ),
        ),
      );

      // اختبار رقم 5
      await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
      await tester.pump();

      expect(pressedNumber, 5);
    });

    testWidgets('Enter يستدعي onCheckout', (tester) async {
      bool checkoutCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: PosKeyboardListener(
            onSearch: () {},
            onNewSale: () {},
            onCheckout: () => checkoutCalled = true,
            onUndo: () {},
            onCancel: () {},
            onQuickAdd: (n) {},
            onQuantityChange: (b) {},
            child: const SizedBox(),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(checkoutCalled, isTrue);
    });
  });

  group('PosKeyboardShortcuts Static Tests', () {
    test('handleKeyEvent يتعامل مع F1 بشكل صحيح', () {
      bool searchCalled = false;
      
      final result = PosKeyboardShortcuts.handleKeyEvent(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.f1,
          physicalKey: PhysicalKeyboardKey.f1,
          timeStamp: Duration.zero,
        ),
        onSearch: () => searchCalled = true,
        onNewSale: () {},
        onCheckout: () {},
        onUndo: () {},
        onCancel: () {},
        onQuickAdd: (n) {},
        onQuantityChange: (b) {},
      );
      
      expect(searchCalled, isTrue);
      expect(result, KeyEventResult.handled);
    });

    test('handleKeyEvent يتجاهل المفاتيح غير المعروفة', () {
      final result = PosKeyboardShortcuts.handleKeyEvent(
        const KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyA,
          physicalKey: PhysicalKeyboardKey.keyA,
          timeStamp: Duration.zero,
        ),
        onSearch: () {},
        onNewSale: () {},
        onCheckout: () {},
        onUndo: () {},
        onCancel: () {},
        onQuickAdd: (n) {},
        onQuantityChange: (b) {},
      );
      
      expect(result, KeyEventResult.ignored);
    });
  });
}
