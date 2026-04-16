/// Providers for distributor onboarding (signup, status, email verification).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/distributor_datasource.dart';
import '../data/models.dart';
import 'distributor_datasource_provider.dart';

// ─── Account status ─────────────────────────────────────────────

/// Current distributor account status (for routing/UI).
final distributorAccountStatusProvider =
    FutureProvider.autoDispose<DistributorAccountStatus?>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getCurrentDistributorStatus();
});

// ─── Signup notifier ────────────────────────────────────────────

/// State for signup form submission.
class SignupState {
  final bool isLoading;
  final String? error;
  final DistributorSignupResult? result;

  const SignupState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  SignupState copyWith({
    bool? isLoading,
    String? error,
    DistributorSignupResult? result,
  }) {
    return SignupState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

class SignupNotifier extends Notifier<SignupState> {
  @override
  SignupState build() => const SignupState();

  Future<void> signUp(SignupParams params) async {
    state = const SignupState(isLoading: true);

    try {
      final ds = ref.read(distributorDatasourceProvider);
      final result = await ds.signUpDistributor(params);
      state = SignupState(result: result);
    } on DatasourceError catch (e) {
      state = SignupState(error: e.message);
    } catch (e) {
      state = const SignupState(error: 'حدث خطأ غير متوقع');
    }
  }
}

final signupProvider = NotifierProvider<SignupNotifier, SignupState>(
  SignupNotifier.new,
);
