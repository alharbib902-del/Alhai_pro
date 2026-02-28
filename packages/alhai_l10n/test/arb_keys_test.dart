// L105: Automated ARB key matching tests
//
// Verifies that every ARB locale file contains the same set of keys as the
// base locale (app_ar.arb). Missing keys cause runtime fallbacks that are
// hard to catch manually.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reads an ARB file and returns its decoded JSON map.
Map<String, dynamic> _loadArb(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    fail('ARB file not found: $path');
  }
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

/// Returns non-metadata keys (those that do NOT start with '@' or '@@').
Set<String> _userKeys(Map<String, dynamic> arb) {
  return arb.keys.where((k) => !k.startsWith('@')).toSet();
}

void main() {
  // Resolve the l10n directory relative to this test file.
  // The test is at packages/alhai_l10n/test/arb_keys_test.dart
  // ARB files live at packages/alhai_l10n/lib/l10n/
  final l10nDir = Directory(
    '${Directory.current.path}/lib/l10n',
  );

  late Map<String, dynamic> baseArb;
  late Set<String> baseKeys;
  late List<FileSystemEntity> arbFiles;

  setUpAll(() {
    if (!l10nDir.existsSync()) {
      fail('l10n directory not found at ${l10nDir.path}');
    }

    arbFiles = l10nDir
        .listSync()
        .where((f) => f.path.endsWith('.arb'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    // Use app_ar.arb as the base (primary locale).
    final basePath = arbFiles
        .firstWhere(
          (f) => f.path.endsWith('app_ar.arb'),
          orElse: () => fail('app_ar.arb (base locale) not found'),
        )
        .path;

    baseArb = _loadArb(basePath);
    baseKeys = _userKeys(baseArb);
  });

  test('l10n directory contains at least 2 ARB files', () {
    expect(arbFiles.length, greaterThanOrEqualTo(2));
  });

  test('base ARB (app_ar.arb) has at least 10 keys', () {
    expect(baseKeys.length, greaterThanOrEqualTo(10));
  });

  // Dynamically generate a test for each non-base ARB file.
  for (final locale in ['en', 'ur', 'hi', 'bn', 'fil', 'id']) {
    test('app_$locale.arb contains all keys from app_ar.arb', () {
      final path = '${l10nDir.path}/app_$locale.arb';
      final arb = _loadArb(path);
      final keys = _userKeys(arb);

      final missingKeys = baseKeys.difference(keys);
      if (missingKeys.isNotEmpty) {
        fail(
          'app_$locale.arb is missing ${missingKeys.length} key(s):\n'
          '  ${missingKeys.take(20).join('\n  ')}'
          '${missingKeys.length > 20 ? '\n  ... and ${missingKeys.length - 20} more' : ''}',
        );
      }
    });

    test('app_$locale.arb has no extra keys missing from app_ar.arb', () {
      final path = '${l10nDir.path}/app_$locale.arb';
      final arb = _loadArb(path);
      final keys = _userKeys(arb);

      final extraKeys = keys.difference(baseKeys);
      if (extraKeys.isNotEmpty) {
        // Extra keys are a warning, not necessarily a failure, but we flag
        // them so the team can clean up orphaned translations.
        fail(
          'app_$locale.arb has ${extraKeys.length} extra key(s) not in app_ar.arb:\n'
          '  ${extraKeys.take(20).join('\n  ')}'
          '${extraKeys.length > 20 ? '\n  ... and ${extraKeys.length - 20} more' : ''}',
        );
      }
    });
  }
}
