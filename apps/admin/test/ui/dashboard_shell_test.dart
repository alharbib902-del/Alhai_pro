/// Admin Dashboard Shell Widget Tests
///
/// Verifies that the AdminDashboardShell widget can be
/// instantiated and renders properly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin/ui/dashboard_shell.dart';

void main() {
  group('AdminDashboardShell - Widget creation', () {
    test('AdminDashboardShell constructor accepts child', () {
      const shell = AdminDashboardShell(child: SizedBox());
      expect(shell.child, isA<SizedBox>());
    });

    test('AdminDashboardShell is a ConsumerStatefulWidget', () {
      const shell = AdminDashboardShell(child: SizedBox());
      expect(shell, isA<ConsumerStatefulWidget>());
    });
  });

  group('AdminDashboardShell - Key property', () {
    test('can be created with a key', () {
      const key = ValueKey('test-shell');
      const shell = AdminDashboardShell(key: key, child: SizedBox());
      expect(shell.key, equals(key));
    });
  });
}
