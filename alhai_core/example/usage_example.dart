// ignore_for_file: avoid_print
/// Usage Example for alhai_core
/// =============================
/// This is a demonstration file showing how to use alhai_core.
/// This is NOT a UI file - it's meant to illustrate the API usage patterns.
///
/// Before running:
/// 1. flutter pub get
/// 2. dart run build_runner build --delete-conflicting-outputs
/// 3. flutter analyze

import 'package:flutter/widgets.dart';
import 'package:alhai_core/alhai_core.dart';

Future<void> main() async {
  // Required for SharedPreferences initialization
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================
  // 1. Configure App BEFORE DI
  // ============================================
  AppConfig.configure(baseUrl: 'https://api.alhai.app');

  // ============================================
  // 2. Initialize Dependencies
  // ============================================
  await configureDependencies();

  // ============================================
  // 3. Get Repositories from GetIt
  // ============================================
  final authRepo = getIt<AuthRepository>();
  final ordersRepo = getIt<OrdersRepository>();

  // ============================================
  // 4. Example: Authentication Flow
  // ============================================
  await exampleAuthFlow(authRepo);

  // ============================================
  // 5. Example: Create Order Flow
  // ============================================
  await exampleCreateOrder(ordersRepo);
}

/// Example: OTP Authentication Flow
Future<void> exampleAuthFlow(AuthRepository authRepo) async {
  const phone = '+966500000000';
  const otp = '1234';

  try {
    // Step 1: Send OTP
    print('Sending OTP to $phone...');
    await authRepo.sendOtp(phone);
    print('OTP sent successfully!');

    // Step 2: Verify OTP (user enters OTP)
    print('Verifying OTP...');
    final authResult = await authRepo.verifyOtp(phone, otp);

    print('Login successful!');
    print('User: ${authResult.user.name}');
    print('Role: ${authResult.user.role}');
    print('Token expires: ${authResult.tokens.expiresAt}');

    // Step 3: Check authentication status later
    final isLoggedIn = await authRepo.isAuthenticated();
    print('Is authenticated: $isLoggedIn');

    // Step 4: Get current user
    final user = await authRepo.getCurrentUser();
    print('Current user: ${user?.name}');

    // Step 5: Logout
    await authRepo.logout();
    print('Logged out successfully!');
  } on AuthException catch (e) {
    print('Auth error: ${e.message} (code: ${e.code})');
  } on ValidationException catch (e) {
    print('Validation error: ${e.message}');
    e.fieldErrors?.forEach((field, errors) {
      print('  $field: ${errors.join(', ')}');
    });
  } on NetworkException catch (e) {
    print('Network error: ${e.message}');
  } on AppException catch (e) {
    print('Error: ${e.message}');
  }
}

/// Example: Create Order Flow
Future<void> exampleCreateOrder(OrdersRepository ordersRepo) async {
  try {
    // Create order parameters
    final params = CreateOrderParams(
      clientOrderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
      storeId: 'store_123',
      items: [
        const OrderItem(
          productId: 'prod_001',
          name: 'Coffee',
          unitPrice: 15.0,
          qty: 2,
          lineTotal: 30.0,
        ),
        const OrderItem(
          productId: 'prod_002',
          name: 'Sandwich',
          unitPrice: 25.0,
          qty: 1,
          lineTotal: 25.0,
        ),
      ],
      deliveryAddress: '123 Main St, Riyadh',
      paymentMethod: PaymentMethod.cash,
    );

    print('Creating order...');
    final order = await ordersRepo.createOrder(params);

    print('Order created!');
    print('Order ID: ${order.id}');
    print('Status: ${order.status}');
    print('Total: ${order.total} SAR');
    print('Items: ${order.items.length}');

    // Get order status
    final fetchedOrder = await ordersRepo.getOrder(order.id);
    print('Fetched order status: ${fetchedOrder.status}');

    // List orders
    final orders = await ordersRepo.getOrders(
      status: OrderStatus.created,
      page: 1,
      limit: 10,
    );
    print('Found ${orders.items.length} orders with status: created');

    // Update order status
    final updatedOrder = await ordersRepo.updateStatus(
      order.id,
      OrderStatus.confirmed,
    );
    print('Order status updated to: ${updatedOrder.status}');

    // Cancel order (if needed)
    // await ordersRepo.cancelOrder(order.id, reason: 'Customer request');

  } on ValidationException catch (e) {
    print('Validation error: ${e.message}');
  } on NotFoundException catch (e) {
    print('Not found: ${e.message}');
  } on ServerException catch (e) {
    print('Server error: ${e.message} (status: ${e.statusCode})');
  } on AppException catch (e) {
    print('Error: ${e.message}');
  }
}
