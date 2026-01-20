import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

/// Placeholder home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('POS App')),
      body: const Center(
        child: Text('Welcome to POS App'),
      ),
    );
  }
}

/// App Router Configuration
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
