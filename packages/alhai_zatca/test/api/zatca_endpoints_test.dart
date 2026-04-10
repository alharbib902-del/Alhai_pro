import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/api/zatca_endpoints.dart';

void main() {
  group('ZatcaEndpoints', () {
    // ── Base URLs ─────────────────────────────────────────

    group('base URLs', () {
      test('sandbox base URL is correct', () {
        expect(
          ZatcaEndpoints.sandboxBase,
          'https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal',
        );
      });

      test('simulation base URL is correct', () {
        expect(
          ZatcaEndpoints.simulationBase,
          'https://gw-fatoora.zatca.gov.sa/e-invoicing/simulation',
        );
      });

      test('production base URL is correct', () {
        expect(
          ZatcaEndpoints.productionBase,
          'https://gw-fatoora.zatca.gov.sa/e-invoicing/core',
        );
      });

      test('all base URLs are https', () {
        expect(ZatcaEndpoints.sandboxBase.startsWith('https://'), isTrue);
        expect(ZatcaEndpoints.simulationBase.startsWith('https://'), isTrue);
        expect(ZatcaEndpoints.productionBase.startsWith('https://'), isTrue);
      });

      test('all base URLs point to zatca.gov.sa', () {
        expect(ZatcaEndpoints.sandboxBase.contains('zatca.gov.sa'), isTrue);
        expect(ZatcaEndpoints.simulationBase.contains('zatca.gov.sa'), isTrue);
        expect(ZatcaEndpoints.productionBase.contains('zatca.gov.sa'), isTrue);
      });

      test('base URLs are distinct across environments', () {
        expect(ZatcaEndpoints.sandboxBase, isNot(ZatcaEndpoints.productionBase));
        expect(ZatcaEndpoints.simulationBase,
            isNot(ZatcaEndpoints.productionBase));
        expect(
            ZatcaEndpoints.sandboxBase, isNot(ZatcaEndpoints.simulationBase));
      });
    });

    // ── Endpoint Paths ────────────────────────────────────

    group('endpoint paths', () {
      test('compliance CSID endpoint', () {
        expect(ZatcaEndpoints.complianceCsid, '/compliance');
      });

      test('compliance check endpoint', () {
        expect(ZatcaEndpoints.complianceCheck, '/compliance/invoices');
      });

      test('production CSID endpoint', () {
        expect(ZatcaEndpoints.productionCsid, '/production/csids');
      });

      test('renew production CSID endpoint', () {
        expect(ZatcaEndpoints.renewProductionCsid, '/production/csids');
      });

      test('reporting endpoint', () {
        expect(ZatcaEndpoints.reporting, '/invoices/reporting/single');
      });

      test('clearance endpoint', () {
        expect(ZatcaEndpoints.clearance, '/invoices/clearance/single');
      });

      test('all endpoint paths begin with slash', () {
        expect(ZatcaEndpoints.complianceCsid.startsWith('/'), isTrue);
        expect(ZatcaEndpoints.complianceCheck.startsWith('/'), isTrue);
        expect(ZatcaEndpoints.productionCsid.startsWith('/'), isTrue);
        expect(ZatcaEndpoints.reporting.startsWith('/'), isTrue);
        expect(ZatcaEndpoints.clearance.startsWith('/'), isTrue);
      });
    });

    // ── URL Builder ───────────────────────────────────────

    group('url()', () {
      test('combines base URL and endpoint path correctly', () {
        final url = ZatcaEndpoints.url(
          ZatcaEndpoints.sandboxBase,
          ZatcaEndpoints.reporting,
        );
        expect(
          url,
          'https://gw-fatoora.zatca.gov.sa/e-invoicing/developer-portal/invoices/reporting/single',
        );
      });

      test('does not add extra slashes', () {
        final url = ZatcaEndpoints.url('https://example.com', '/test');
        expect(url, 'https://example.com/test');
        expect(url.contains('//test'), isFalse);
      });

      test('builds production clearance URL', () {
        final url = ZatcaEndpoints.url(
          ZatcaEndpoints.productionBase,
          ZatcaEndpoints.clearance,
        );
        expect(
          url,
          'https://gw-fatoora.zatca.gov.sa/e-invoicing/core/invoices/clearance/single',
        );
      });
    });

    // ── fullUrl() ─────────────────────────────────────────

    group('fullUrl()', () {
      test('builds full URL from sandbox environment', () {
        final url = ZatcaEndpoints.fullUrl(
          ZatcaEnvironment.sandbox,
          ZatcaEndpoints.reporting,
        );
        expect(url.startsWith(ZatcaEndpoints.sandboxBase), isTrue);
        expect(url.endsWith(ZatcaEndpoints.reporting), isTrue);
      });

      test('builds full URL from production environment', () {
        final url = ZatcaEndpoints.fullUrl(
          ZatcaEnvironment.production,
          ZatcaEndpoints.clearance,
        );
        expect(url.startsWith(ZatcaEndpoints.productionBase), isTrue);
        expect(url.endsWith(ZatcaEndpoints.clearance), isTrue);
      });

      test('builds full URL from simulation environment', () {
        final url = ZatcaEndpoints.fullUrl(
          ZatcaEnvironment.simulation,
          ZatcaEndpoints.complianceCheck,
        );
        expect(url.startsWith(ZatcaEndpoints.simulationBase), isTrue);
        expect(url.endsWith(ZatcaEndpoints.complianceCheck), isTrue);
      });
    });
  });

  // ── ZatcaEnvironment enum ───────────────────────────────

  group('ZatcaEnvironment', () {
    test('sandbox baseUrl maps to sandboxBase', () {
      expect(ZatcaEnvironment.sandbox.baseUrl, ZatcaEndpoints.sandboxBase);
    });

    test('simulation baseUrl maps to simulationBase', () {
      expect(
          ZatcaEnvironment.simulation.baseUrl, ZatcaEndpoints.simulationBase);
    });

    test('production baseUrl maps to productionBase', () {
      expect(
          ZatcaEnvironment.production.baseUrl, ZatcaEndpoints.productionBase);
    });

    test('sandbox isSandbox returns true', () {
      expect(ZatcaEnvironment.sandbox.isSandbox, isTrue);
    });

    test('simulation isSandbox returns true', () {
      expect(ZatcaEnvironment.simulation.isSandbox, isTrue);
    });

    test('production isSandbox returns false', () {
      expect(ZatcaEnvironment.production.isSandbox, isFalse);
    });

    test('enum contains exactly three environments', () {
      expect(ZatcaEnvironment.values.length, 3);
      expect(ZatcaEnvironment.values, contains(ZatcaEnvironment.sandbox));
      expect(ZatcaEnvironment.values, contains(ZatcaEnvironment.simulation));
      expect(ZatcaEnvironment.values, contains(ZatcaEnvironment.production));
    });
  });
}
