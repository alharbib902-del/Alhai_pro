import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks if the current screen has unsaved changes.
/// Used by the dashboard shell to guard sidebar navigation.
final unsavedChangesProvider = StateProvider<bool>((ref) => false);
