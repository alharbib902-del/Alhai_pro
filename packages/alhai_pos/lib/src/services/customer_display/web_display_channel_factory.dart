/// Conditional import factory for web display channel
///
/// Uses Dart conditional imports to select:
/// - [web_display_channel.dart] on web (real BroadcastChannel)
/// - [web_display_channel_stub.dart] on native (InMemoryDisplayChannel)
///
/// Usage:
/// ```dart
/// import 'web_display_channel_factory.dart' as channel_factory;
/// final channel = channel_factory.createWebDisplayChannel();
/// ```
library;

export 'web_display_channel_stub.dart'
    if (dart.library.html) 'web_display_channel.dart';
