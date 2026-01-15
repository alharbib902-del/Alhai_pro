import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Global GetIt instance
final getIt = GetIt.instance;

/// Initialize all dependencies
/// Call this in main() before runApp()
@InjectableInit()
Future<void> configureDependencies({String? environment}) async {
  await getIt.init(environment: environment);
}
