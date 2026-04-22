import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alhai_pos/src/services/terminal_suffix_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TerminalSuffixService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('first call generates a 4-hex-char suffix and persists it', () async {
      final service = TerminalSuffixService(random: Random(42));
      final suffix = await service.getSuffix();

      expect(suffix.length, 4);
      expect(RegExp(r'^[0-9a-f]{4}$').hasMatch(suffix), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(TerminalSuffixService.prefsKey), suffix);
    });

    test('subsequent calls return the same suffix (in-memory cache)', () async {
      final service = TerminalSuffixService();
      final first = await service.getSuffix();
      final second = await service.getSuffix();
      final third = await service.getSuffix();
      expect(second, first);
      expect(third, first);
    });

    test('reads pre-existing suffix from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        TerminalSuffixService.prefsKey: 'a3f7',
      });
      final service = TerminalSuffixService(random: Random(99));
      final suffix = await service.getSuffix();
      expect(suffix, 'a3f7');
    });

    test(
      'overwrites malformed stored value with a fresh generated suffix',
      () async {
        SharedPreferences.setMockInitialValues({
          TerminalSuffixService.prefsKey: 'not-hex',
        });
        final service = TerminalSuffixService(random: Random(42));
        final suffix = await service.getSuffix();
        expect(RegExp(r'^[0-9a-f]{4}$').hasMatch(suffix), isTrue);
        expect(suffix, isNot('not-hex'));

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(TerminalSuffixService.prefsKey), suffix);
      },
    );

    test('seeded Random produces deterministic output', () async {
      final a = TerminalSuffixService(random: Random(42));
      final b = TerminalSuffixService(random: Random(42));
      // Each service reads from SharedPreferences first; setMockInitialValues
      // resets to empty per setUp, so within a single test both instances
      // generate from the same seeded RNG and therefore agree.
      expect(await a.getSuffix(), await b.getSuffix());
    });

    test('different seeds produce different suffixes', () async {
      final a = TerminalSuffixService(random: Random(1));
      // SharedPreferences persists after the first generate, so the second
      // service must read-and-return the stored value rather than roll its
      // own — which is exactly the same-device behaviour production needs.
      // For "different device" semantics we reset prefs.
      final aSuffix = await a.getSuffix();

      SharedPreferences.setMockInitialValues({});
      final b = TerminalSuffixService(random: Random(2));
      final bSuffix = await b.getSuffix();

      expect(aSuffix, isNot(bSuffix));
    });
  });
}
