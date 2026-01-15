import 'package:flutter/material.dart';

/// Test helper to wrap widget with MaterialApp
Widget createTestWidget(Widget child) {
  return MaterialApp(
    theme: ThemeData.light(useMaterial3: true),
    home: Scaffold(body: Center(child: child)),
  );
}
