import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/models/signup_params.dart';

void main() {
  // ─── SignupParams construction ──────────────────────────────────

  group('SignupParams', () {
    test('stores all required fields', () {
      const params = SignupParams(
        email: 'test@example.com',
        password: 'pass1234',
        companyName: 'شركة الاختبار',
        phoneNumber: '+966512345678',
        commercialRegister: '1234567890',
        vatNumber: '312345678901234',
        city: 'الرياض',
        address: 'شارع الملك فهد، حي العليا',
        acceptedTerms: true,
      );

      expect(params.email, 'test@example.com');
      expect(params.password, 'pass1234');
      expect(params.companyName, 'شركة الاختبار');
      expect(params.phoneNumber, '+966512345678');
      expect(params.commercialRegister, '1234567890');
      expect(params.vatNumber, '312345678901234');
      expect(params.city, 'الرياض');
      expect(params.address, 'شارع الملك فهد، حي العليا');
      expect(params.acceptedTerms, isTrue);
      expect(params.companyNameEn, isNull);
    });

    test('stores optional companyNameEn', () {
      const params = SignupParams(
        email: 'test@example.com',
        password: 'pass1234',
        companyName: 'شركة الاختبار',
        companyNameEn: 'Test Company',
        phoneNumber: '+966512345678',
        commercialRegister: '1234567890',
        vatNumber: '312345678901234',
        city: 'الرياض',
        address: 'شارع الملك فهد',
        acceptedTerms: true,
      );

      expect(params.companyNameEn, 'Test Company');
    });

    test('terms can be false', () {
      const params = SignupParams(
        email: 'test@example.com',
        password: 'pass1234',
        companyName: 'شركة',
        phoneNumber: '0512345678',
        commercialRegister: '1234567890',
        vatNumber: '312345678901234',
        city: 'جدة',
        address: 'العنوان التفصيلي',
        acceptedTerms: false,
      );

      expect(params.acceptedTerms, isFalse);
    });
  });

  // ─── DistributorSignupResult ────────────────────────────────────

  group('DistributorSignupResult', () {
    test('stores all fields', () {
      const result = DistributorSignupResult(
        distributorId: 'uuid-123',
        email: 'test@example.com',
        requiresEmailVerification: true,
      );

      expect(result.distributorId, 'uuid-123');
      expect(result.email, 'test@example.com');
      expect(result.requiresEmailVerification, isTrue);
    });

    test('can have requiresEmailVerification = false', () {
      const result = DistributorSignupResult(
        distributorId: 'uuid-456',
        email: 'admin@example.com',
        requiresEmailVerification: false,
      );

      expect(result.requiresEmailVerification, isFalse);
    });
  });
}
