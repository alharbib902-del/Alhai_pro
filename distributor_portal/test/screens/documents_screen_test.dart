import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'package:distributor_portal/data/distributor_datasource.dart';
import 'package:distributor_portal/data/models.dart';
import 'package:distributor_portal/providers/distributor_datasource_provider.dart';
import 'package:distributor_portal/screens/documents/distributor_documents_screen.dart';

// ─── Fake Datasource ─────────────────────────────────────────────

class _FakeDistributorDatasource extends DistributorDatasource {
  final List<DistributorDocument> fakeDocuments;

  _FakeDistributorDatasource({this.fakeDocuments = const []});

  @override
  Future<List<DistributorDocument>> getDocuments() async => fakeDocuments;

  @override
  Future<String?> getOrgId() async => 'test-org';

  @override
  Future<OrgSettings?> getOrgSettings() async {
    return const OrgSettings(id: 'test-org', companyName: 'Test Co');
  }
}

// ─── Test Helpers ────────────────────────────────────────────────

Widget _buildTestWidget({List<DistributorDocument> documents = const []}) {
  return ProviderScope(
    overrides: [
      distributorDatasourceProvider.overrideWithValue(
        _FakeDistributorDatasource(fakeDocuments: documents),
      ),
    ],
    child: MaterialApp(
      title: 'Test',
      theme: AlhaiTheme.light,
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const DistributorDocumentsScreen(),
    ),
  );
}

final _sampleDoc = DistributorDocument.fromJson({
  'id': 'doc-001',
  'org_id': 'org-1',
  'document_type': 'commercial_registration',
  'file_url': 'org-1/commercial_registration/1713200000000_cr.pdf',
  'file_name': 'cr.pdf',
  'file_size': 2400000,
  'mime_type': 'application/pdf',
  'status': 'under_review',
  'reviewed_by': null,
  'reviewed_at': null,
  'rejection_reason': null,
  'uploaded_at': '2026-04-16T10:00:00.000Z',
  'updated_at': null,
  'expiry_date': '2027-03-15',
});

final _approvedDoc = DistributorDocument.fromJson({
  'id': 'doc-002',
  'org_id': 'org-1',
  'document_type': 'vat_certificate',
  'file_url': 'org-1/vat_certificate/1713200000000_vat.pdf',
  'file_name': 'vat.pdf',
  'file_size': 1100000,
  'mime_type': 'application/pdf',
  'status': 'approved',
  'reviewed_by': 'admin-1',
  'reviewed_at': '2026-04-17T12:00:00.000Z',
  'rejection_reason': null,
  'uploaded_at': '2026-04-15T10:00:00.000Z',
  'updated_at': null,
  'expiry_date': null,
});

final _rejectedDoc = DistributorDocument.fromJson({
  'id': 'doc-003',
  'org_id': 'org-1',
  'document_type': 'ceo_national_id',
  'file_url': 'org-1/ceo_national_id/1713200000000_id.jpg',
  'file_name': 'id.jpg',
  'file_size': 800000,
  'mime_type': 'image/jpeg',
  'status': 'rejected',
  'reviewed_by': 'admin-1',
  'reviewed_at': '2026-04-17T14:00:00.000Z',
  'rejection_reason': 'الصورة غير واضحة',
  'uploaded_at': '2026-04-14T10:00:00.000Z',
  'updated_at': null,
  'expiry_date': null,
});

// ─── Tests ──────────────────────────────────────────────────────

void main() {
  group('DistributorDocumentsScreen', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('shows empty state when no documents', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('لا توجد وثائق مرفوعة'), findsOneWidget);
      expect(
        find.text('ارفع السجل التجاري وشهادة الضريبة للتحقق من حسابك'),
        findsOneWidget,
      );
    });

    testWidgets('shows header and upload button', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('الوثائق والشهادات'), findsOneWidget);
      expect(find.text('رفع وثيقة جديدة'), findsOneWidget);
    });

    testWidgets('shows missing required documents warning', (tester) async {
      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // Both CR and VAT are required but missing
      expect(find.text('وثائق مطلوبة'), findsOneWidget);
      expect(find.text('• السجل التجاري'), findsOneWidget);
      expect(find.text('• شهادة ضريبة القيمة المضافة'), findsOneWidget);
    });

    testWidgets('shows document list with correct info', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(documents: [_sampleDoc, _approvedDoc]),
      );
      await tester.pumpAndSettle();

      // Document type names
      expect(find.text('السجل التجاري'), findsWidgets);
      expect(find.text('شهادة ضريبة القيمة المضافة'), findsWidgets);

      // Filenames
      expect(find.textContaining('cr.pdf'), findsOneWidget);
      expect(find.textContaining('vat.pdf'), findsOneWidget);
    });

    testWidgets('shows status badges', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(documents: [_sampleDoc, _approvedDoc, _rejectedDoc]),
      );
      await tester.pumpAndSettle();

      expect(find.text('قيد المراجعة'), findsOneWidget);
      expect(find.text('موافق عليه'), findsOneWidget);
      expect(find.text('مرفوض'), findsOneWidget);
    });

    testWidgets('shows rejection reason for rejected docs', (tester) async {
      await tester.pumpWidget(_buildTestWidget(documents: [_rejectedDoc]));
      await tester.pumpAndSettle();

      expect(find.textContaining('الصورة غير واضحة'), findsOneWidget);
    });

    testWidgets('delete button shown for non-approved docs', (tester) async {
      await tester.pumpWidget(
        _buildTestWidget(documents: [_sampleDoc, _approvedDoc]),
      );
      await tester.pumpAndSettle();

      // Under-review doc should have delete icon
      // Approved doc should NOT have delete icon
      // We check that there is at least one delete button but fewer than
      // the total number of documents
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsOneWidget); // Only the under_review doc
    });

    testWidgets('shows expiry badge when expiry date is set', (tester) async {
      await tester.pumpWidget(_buildTestWidget(documents: [_sampleDoc]));
      await tester.pumpAndSettle();

      expect(find.textContaining('2027-03-15'), findsOneWidget);
    });

    testWidgets('no missing docs warning when all required present', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestWidget(documents: [_sampleDoc, _approvedDoc]),
      );
      await tester.pumpAndSettle();

      // Both CR and VAT are present → no "missing" warning
      expect(find.text('وثائق مطلوبة'), findsNothing);
    });
  });
}
