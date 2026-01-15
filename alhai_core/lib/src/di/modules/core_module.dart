import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Core module for basic dependencies
@module
abstract class CoreModule {
  /// SharedPreferences - needs async initialization
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// FlutterSecureStorage - singleton
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
