# Flutter & Dart
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Google services (Firebase, Maps, FCM, etc.)
-keep class com.google.** { *; }

# Supabase / GoTrue
-keep class io.supabase.** { *; }

# flutter_background_service — required for the foreground-service
# location tracker. Reflection-based lookup at runtime.
-keep class id.flutter.flutter_background_service.** { *; }

# Keep annotations
-keepattributes *Annotation*
