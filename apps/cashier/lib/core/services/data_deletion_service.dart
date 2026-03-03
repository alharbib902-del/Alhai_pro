/// DataDeletionService - GDPR-style customer data management
///
/// Provides: delete, anonymize, and export customer data.
/// Used from privacy policy and customer management screens.
library;

import 'dart:convert';

import 'package:alhai_database/alhai_database.dart';
import 'package:drift/drift.dart';

import 'sentry_service.dart';

/// Service for customer data deletion, anonymization, and export.
class DataDeletionService {
  final AppDatabase _db;

  DataDeletionService(this._db);

  // ===========================================================================
  // DELETE CUSTOMER DATA
  // ===========================================================================

  /// Permanently delete all data associated with a customer.
  ///
  /// Removes: customer record, addresses, accounts, notifications.
  /// Sales/orders are anonymized (customer name set to "عميل محذوف")
  /// rather than deleted, to preserve financial records.
  Future<DeletionReport> deleteCustomerData(String customerId) async {
    try {
      int deletedRecords = 0;

      await _db.transaction(() async {
        // 1. Anonymize sales (keep for accounting, remove customer link)
        final salesAnonymized = await _db.customUpdate(
          "UPDATE sales SET customer_id = NULL, customer_name = 'عميل محذوف' WHERE customer_id = ?",
          variables: [Variable.withString(customerId)],
          updates: {_db.salesTable},
        );

        // 2. Anonymize orders
        final ordersAnonymized = await _db.customUpdate(
          "UPDATE orders SET customer_id = NULL, customer_name = 'عميل محذوف' WHERE customer_id = ?",
          variables: [Variable.withString(customerId)],
          updates: {_db.ordersTable},
        );

        // 3. Anonymize returns
        await _db.customUpdate(
          "UPDATE returns SET customer_id = NULL WHERE customer_id = ?",
          variables: [Variable.withString(customerId)],
          updates: {_db.returnsTable},
        );

        // 4. Delete accounts/ledger entries
        final accountsDeleted = await _db.customUpdate(
          'DELETE FROM accounts WHERE customer_id = ?',
          variables: [Variable.withString(customerId)],
          updates: {_db.accountsTable},
        );

        // 5. Delete transactions linked to customer accounts
        await _db.customUpdate(
          "DELETE FROM transactions WHERE reference_id = ? AND type = 'customer_payment'",
          variables: [Variable.withString(customerId)],
          updates: {_db.transactionsTable},
        );

        // 6. Delete customer addresses
        final addressesDeleted = await _db.customUpdate(
          'DELETE FROM customer_addresses WHERE customer_id = ?',
          variables: [Variable.withString(customerId)],
          updates: {_db.customerAddressesTable},
        );

        // 7. Delete notifications for customer
        await _db.customUpdate(
          'DELETE FROM notifications WHERE reference_id = ?',
          variables: [Variable.withString(customerId)],
          updates: {_db.notificationsTable},
        );

        // 8. Delete loyalty points
        await _db.customUpdate(
          'DELETE FROM loyalty_points WHERE customer_id = ?',
          variables: [Variable.withString(customerId)],
          updates: {_db.loyaltyPointsTable},
        );

        // 9. Delete loyalty transactions
        await _db.customUpdate(
          'DELETE FROM loyalty_transactions WHERE customer_id = ?',
          variables: [Variable.withString(customerId)],
          updates: {_db.loyaltyTransactionsTable},
        );

        // 10. Delete the customer record
        final customerDeleted = await _db.customUpdate(
          'DELETE FROM customers WHERE id = ?',
          variables: [Variable.withString(customerId)],
          updates: {_db.customersTable},
        );

        deletedRecords = accountsDeleted +
            addressesDeleted +
            customerDeleted +
            salesAnonymized +
            ordersAnonymized;
      });

      addBreadcrumb(
        message: 'Customer data deleted: $customerId ($deletedRecords affected)',
        category: 'privacy',
      );

      return DeletionReport(
        success: true,
        deletedRecords: deletedRecords,
        customerId: customerId,
      );
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Delete customer data');
      return DeletionReport(
        success: false,
        error: '$e',
        customerId: customerId,
      );
    }
  }

  // ===========================================================================
  // ANONYMIZE (soft — keeps records, removes PII)
  // ===========================================================================

  /// Anonymize a customer: replace name/phone/email with generic values.
  ///
  /// Keeps the customer record for accounting references but removes
  /// all personally identifiable information.
  Future<DeletionReport> anonymizeCustomerData(String customerId) async {
    try {
      int affected = 0;

      await _db.transaction(() async {
        // 1. Anonymize the customer record
        affected += await _db.customUpdate(
          '''UPDATE customers SET
              name = 'عميل محذوف',
              phone = NULL,
              email = NULL,
              address = NULL,
              city = NULL,
              tax_number = NULL,
              notes = NULL,
              is_active = 0,
              updated_at = ?
            WHERE id = ?''',
          variables: [
            Variable.withDateTime(DateTime.now()),
            Variable.withString(customerId),
          ],
          updates: {_db.customersTable},
        );

        // 2. Delete addresses
        affected += await _db.customUpdate(
          'DELETE FROM customer_addresses WHERE customer_id = ?',
          variables: [Variable.withString(customerId)],
          updates: {_db.customerAddressesTable},
        );

        // 3. Anonymize in sales
        affected += await _db.customUpdate(
          "UPDATE sales SET customer_name = 'عميل محذوف' WHERE customer_id = ?",
          variables: [Variable.withString(customerId)],
          updates: {_db.salesTable},
        );

        // 4. Anonymize in orders
        affected += await _db.customUpdate(
          "UPDATE orders SET customer_name = 'عميل محذوف' WHERE customer_id = ?",
          variables: [Variable.withString(customerId)],
          updates: {_db.ordersTable},
        );
      });

      addBreadcrumb(
        message: 'Customer anonymized: $customerId ($affected affected)',
        category: 'privacy',
      );

      return DeletionReport(
        success: true,
        deletedRecords: affected,
        customerId: customerId,
      );
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Anonymize customer');
      return DeletionReport(
        success: false,
        error: '$e',
        customerId: customerId,
      );
    }
  }

  // ===========================================================================
  // EXPORT CUSTOMER DATA
  // ===========================================================================

  /// Export all data related to a customer as a JSON string.
  ///
  /// Includes: customer info, addresses, sales, orders, returns,
  /// account/ledger, loyalty, notifications.
  Future<String> exportCustomerData(String customerId) async {
    try {
      final data = <String, dynamic>{};

      // Customer record
      final customers = await _db.customSelect(
        'SELECT * FROM customers WHERE id = ?',
        variables: [Variable.withString(customerId)],
      ).get();
      data['customer'] = customers.map((r) => r.data).toList();

      // Addresses
      final addresses = await _db.customSelect(
        'SELECT * FROM customer_addresses WHERE customer_id = ?',
        variables: [Variable.withString(customerId)],
      ).get();
      data['addresses'] = addresses.map((r) => r.data).toList();

      // Sales
      final sales = await _db.customSelect(
        'SELECT * FROM sales WHERE customer_id = ?',
        variables: [Variable.withString(customerId)],
      ).get();
      data['sales'] = sales.map((r) => r.data).toList();

      // Sale items
      if (sales.isNotEmpty) {
        final saleIds = sales.map((s) => "'${s.data['id']}'").join(',');
        final saleItems = await _db.customSelect(
          'SELECT * FROM sale_items WHERE sale_id IN ($saleIds)',
        ).get();
        data['sale_items'] = saleItems.map((r) => r.data).toList();
      }

      // Orders
      final orders = await _db.customSelect(
        'SELECT * FROM orders WHERE customer_id = ?',
        variables: [Variable.withString(customerId)],
      ).get();
      data['orders'] = orders.map((r) => r.data).toList();

      // Returns
      final returns = await _db.customSelect(
        'SELECT * FROM returns WHERE customer_id = ?',
        variables: [Variable.withString(customerId)],
      ).get();
      data['returns'] = returns.map((r) => r.data).toList();

      // Account
      final accounts = await _db.customSelect(
        'SELECT * FROM accounts WHERE customer_id = ?',
        variables: [Variable.withString(customerId)],
      ).get();
      data['accounts'] = accounts.map((r) => r.data).toList();

      // Loyalty
      final loyalty = await _db.customSelect(
        'SELECT * FROM loyalty_points WHERE customer_id = ?',
        variables: [Variable.withString(customerId)],
      ).get();
      data['loyalty_points'] = loyalty.map((r) => r.data).toList();

      final loyaltyTx = await _db.customSelect(
        'SELECT * FROM loyalty_transactions WHERE customer_id = ?',
        variables: [Variable.withString(customerId)],
      ).get();
      data['loyalty_transactions'] = loyaltyTx.map((r) => r.data).toList();

      final export = {
        'exportedAt': DateTime.now().toIso8601String(),
        'customerId': customerId,
        'data': data,
      };

      addBreadcrumb(
        message: 'Customer data exported: $customerId',
        category: 'privacy',
      );

      return const JsonEncoder.withIndent('  ').convert(export);
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'Export customer data');
      rethrow;
    }
  }
}

/// Report of a deletion/anonymization operation
class DeletionReport {
  final bool success;
  final String? error;
  final int deletedRecords;
  final String customerId;

  const DeletionReport({
    required this.success,
    this.error,
    this.deletedRecords = 0,
    this.customerId = '',
  });
}
