import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  late ExportService exportService;
  setUp(() {
    exportService = ExportService();
  });

  group('ExportService', () {
    test('should be created', () {
      expect(exportService, isNotNull);
    });

    group('exportToJson', () {
      test('should export data as formatted JSON', () async {
        final data = [
          {'name': 'A', 'price': 10},
          {'name': 'B', 'price': 20},
        ];
        final json = await exportService.exportToJson(data);
        final decoded = jsonDecode(json) as List;
        expect(decoded, hasLength(2));
        expect(decoded[0]['name'], equals('A'));
      });

      test('should handle empty data', () async {
        final json = await exportService.exportToJson([]);
        final decoded = jsonDecode(json) as List;
        expect(decoded, isEmpty);
      });
    });

    group('exportToHtmlTable', () {
      test('should generate HTML table', () async {
        final html = await exportService.exportToHtmlTable([
          {'Name': 'Coffee', 'Price': '15.00'},
        ]);
        expect(html, contains('<!DOCTYPE html>'));
        expect(html, contains('<table>'));
        expect(html, contains('Coffee'));
      });

      test('should include title when provided', () async {
        final html = await exportService.exportToHtmlTable([
          {'Key': 'Value'},
        ], title: 'Test Report');
        expect(html, contains('Test Report'));
      });

      test('should return message for empty data', () async {
        final html = await exportService.exportToHtmlTable([]);
        expect(html, contains('لا توجد بيانات'));
      });
    });
  });
}
