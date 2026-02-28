import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/repositories/promotions_repository.dart';

/// PromotionsRepository is an abstract interface with no helper classes.
/// This test verifies the interface contract exists and documents the API.
/// No implementation to test yet - concrete tests will be added when impl is created.
void main() {
  group('PromotionsRepository contract', () {
    test('should define promotions repository interface', () {
      // Verify the abstract class compiles and interface is well-defined.
      expect(PromotionsRepository, isNotNull);
    });
  });
}
