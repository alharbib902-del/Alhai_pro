import 'dart:convert';

import 'package:alhai_database/alhai_database.dart';

/// Types of sync conflicts that can occur between local and server data
enum ConflictType {
  /// Both local and server modified the same record (409 or updated_at mismatch)
  versionConflict,

  /// One side deleted, other side updated (404 on update or delete of modified record)
  deleteUpdate,

  /// INSERT failed because record already exists (PostgreSQL 23505)
  duplicateKey,

  /// Network timeout — not a real conflict, just needs retry
  networkTimeout,

  /// Column/table doesn't exist on server (schema mismatch, 42P01)
  schemaMismatch,
}

/// Strategy to resolve a conflict
enum ResolutionStrategy {
  /// Take server version (default for admin-controlled data)
  serverWins,

  /// Take local version (default for POS-originated data)
  localWins,

  /// Compare updated_at timestamps, latest wins
  lastWriteWins,

  /// Merge non-conflicting fields (e.g. stock deltas)
  merge,

  /// Require manual user intervention
  manual,
}

/// Represents a detected sync conflict with both versions of the data
class SyncConflict {
  /// Unique ID of the sync queue item
  final String syncQueueId;

  /// Table where the conflict occurred
  final String tableName;

  /// ID of the conflicting record
  final String recordId;

  /// Type of conflict detected
  final ConflictType type;

  /// The operation that was attempted (CREATE, UPDATE, DELETE)
  final String operation;

  /// Local version of the data (from sync queue payload)
  final Map<String, dynamic>? localData;

  /// Server version of the data (fetched after conflict detected)
  final Map<String, dynamic>? serverData;

  /// Raw error message from the failed operation
  final String errorMessage;

  /// Timestamp when the conflict was detected
  final DateTime detectedAt;

  SyncConflict({
    required this.syncQueueId,
    required this.tableName,
    required this.recordId,
    required this.type,
    required this.operation,
    this.localData,
    this.serverData,
    required this.errorMessage,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now().toUtc();

  /// Serialize conflict details to JSON string for storage in sync_queue.last_error
  String toJsonString() {
    return jsonEncode({
      'conflict_type': type.name,
      'resolution_strategy': null, // filled after resolution
      'operation': operation,
      'table': tableName,
      'record_id': recordId,
      'local_data': localData,
      'server_data': serverData,
      'error': errorMessage,
      'detected_at': detectedAt.toIso8601String(),
    });
  }

  /// Parse conflict details from JSON string stored in sync_queue.last_error
  static SyncConflict? fromJsonString(
    String json, {
    required String syncQueueId,
  }) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final typeStr = map['conflict_type'] as String?;
      if (typeStr == null) return null;

      return SyncConflict(
        syncQueueId: syncQueueId,
        tableName: map['table'] as String? ?? '',
        recordId: map['record_id'] as String? ?? '',
        type: ConflictType.values.firstWhere(
          (t) => t.name == typeStr,
          orElse: () => ConflictType.versionConflict,
        ),
        operation: map['operation'] as String? ?? 'UPDATE',
        localData: map['local_data'] as Map<String, dynamic>?,
        serverData: map['server_data'] as Map<String, dynamic>?,
        errorMessage: map['error'] as String? ?? '',
        detectedAt: DateTime.tryParse(map['detected_at'] as String? ?? ''),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Result of a conflict resolution attempt
class ResolutionResult {
  /// Whether the conflict was resolved
  final bool resolved;

  /// The strategy that was applied
  final ResolutionStrategy strategy;

  /// The winning data to persist (null if manual intervention required)
  final Map<String, dynamic>? resolvedData;

  /// Human-readable description of what happened
  final String description;

  const ResolutionResult({
    required this.resolved,
    required this.strategy,
    this.resolvedData,
    required this.description,
  });
}

/// Resolves sync conflicts based on table-specific rules
///
/// Resolution rules per table:
/// - `sales`, `sale_items`: LOCAL WINS (POS is source of truth)
/// - `products` (price/name): SERVER WINS (admin controls)
/// - `products` (stock_qty): MERGE (add deltas)
/// - `customers`: LAST WRITE WINS (compare updated_at)
/// - `settings`, `categories`: SERVER WINS
/// - `shifts`: LOCAL WINS (POS creates shifts)
/// - `orders`: LAST WRITE WINS with status priority
class ConflictResolver {
  const ConflictResolver();

  /// Auto-resolve a conflict based on table-specific rules
  Future<ResolutionResult> resolve(SyncConflict conflict) async {
    // Network timeouts are never real conflicts - always retry
    if (conflict.type == ConflictType.networkTimeout) {
      return const ResolutionResult(
        resolved: false,
        strategy: ResolutionStrategy.manual,
        description: 'Network timeout - will retry automatically',
      );
    }

    // Schema mismatches cannot be auto-resolved
    if (conflict.type == ConflictType.schemaMismatch) {
      return const ResolutionResult(
        resolved: false,
        strategy: ResolutionStrategy.manual,
        description: 'Schema mismatch - table or column missing on server',
      );
    }

    // Duplicate key: auto-resolve by converting to upsert
    if (conflict.type == ConflictType.duplicateKey) {
      return _resolveDuplicateKey(conflict);
    }

    // Get the strategy for this table and conflict type
    final strategy = getStrategy(conflict.tableName, conflict.type);

    switch (strategy) {
      case ResolutionStrategy.serverWins:
        return _resolveServerWins(conflict);
      case ResolutionStrategy.localWins:
        return _resolveLocalWins(conflict);
      case ResolutionStrategy.lastWriteWins:
        return _resolveLastWriteWins(conflict);
      case ResolutionStrategy.merge:
        return _resolveMerge(conflict);
      case ResolutionStrategy.manual:
        return ResolutionResult(
          resolved: false,
          strategy: ResolutionStrategy.manual,
          description:
              'Manual resolution required for ${conflict.tableName}/${conflict.recordId}',
        );
    }
  }

  /// Determine the appropriate resolution strategy for a table + conflict type
  ResolutionStrategy getStrategy(String tableName, ConflictType type) {
    // Delete-Update conflicts need special handling
    if (type == ConflictType.deleteUpdate) {
      return _getDeleteUpdateStrategy(tableName);
    }

    // Version conflicts use table-specific rules
    switch (tableName) {
      // POS-originated data: local always wins
      case 'sales':
      case 'sale_items':
      case 'shifts':
      case 'cash_movements':
      case 'audit_log':
      case 'daily_summaries':
      case 'inventory_movements':
        return ResolutionStrategy.localWins;

      // Admin-controlled data: server always wins
      case 'products':
        return _getProductStrategy(type);
      case 'categories':
      case 'settings':
      case 'discounts':
      case 'coupons':
      case 'promotions':
      case 'roles':
      case 'stores':
      case 'expense_categories':
      case 'org_products':
      case 'loyalty_rewards':
      case 'drivers':
      case 'whatsapp_templates':
      // Financial records — server is authoritative
      case 'invoices':
      case 'invoice_items':
        return ResolutionStrategy.serverWins;

      // Bidirectional data: last write wins
      case 'customers':
      case 'customer_addresses':
      case 'suppliers':
      case 'notifications':
      case 'loyalty_points':
      case 'accounts':
      case 'product_expiry':
      case 'stock_takes':
      case 'stock_transfers':
        return ResolutionStrategy.lastWriteWins;

      // Orders: last write wins with status priority (handled in resolve)
      case 'orders':
      case 'order_items':
      case 'order_status_history':
        return ResolutionStrategy.lastWriteWins;

      // Transaction data: local wins (POS creates these)
      case 'expenses':
      case 'returns':
      case 'return_items':
      case 'purchases':
      case 'purchase_items':
      case 'loyalty_transactions':
      case 'transactions':
        return ResolutionStrategy.localWins;

      default:
        // Unknown table: default to last write wins
        return ResolutionStrategy.lastWriteWins;
    }
  }

  /// Products have mixed strategies: price/name = server, stock = merge
  ResolutionStrategy _getProductStrategy(ConflictType type) {
    // For version conflicts on products, server wins for most fields
    // Stock quantity is handled separately by StockDeltaSync
    return ResolutionStrategy.serverWins;
  }

  /// Delete-Update conflict strategy per table
  ResolutionStrategy _getDeleteUpdateStrategy(String tableName) {
    switch (tableName) {
      // If server deleted a sale that POS created, something is wrong - manual
      case 'sales':
      case 'sale_items':
      case 'shifts':
        return ResolutionStrategy.manual;

      // If server deleted a product, server wins (admin removed it)
      case 'products':
      case 'categories':
      case 'settings':
        return ResolutionStrategy.serverWins;

      // For most other tables, server wins on delete
      default:
        return ResolutionStrategy.serverWins;
    }
  }

  /// Resolve: duplicate key -> convert INSERT to UPSERT
  ResolutionResult _resolveDuplicateKey(SyncConflict conflict) {
    // The local data should be upserted instead of inserted
    return ResolutionResult(
      resolved: true,
      strategy: ResolutionStrategy.localWins,
      resolvedData: conflict.localData,
      description:
          'Duplicate key for ${conflict.tableName}/${conflict.recordId} - '
          'converted INSERT to UPSERT',
    );
  }

  /// Resolve: server version wins
  ResolutionResult _resolveServerWins(SyncConflict conflict) {
    if (conflict.serverData == null) {
      return ResolutionResult(
        resolved: false,
        strategy: ResolutionStrategy.serverWins,
        description:
            'Server wins but no server data available for '
            '${conflict.tableName}/${conflict.recordId}',
      );
    }

    return ResolutionResult(
      resolved: true,
      strategy: ResolutionStrategy.serverWins,
      resolvedData: conflict.serverData,
      description:
          'Server version accepted for ${conflict.tableName}/${conflict.recordId}',
    );
  }

  /// Resolve: local version wins
  ResolutionResult _resolveLocalWins(SyncConflict conflict) {
    if (conflict.localData == null) {
      return ResolutionResult(
        resolved: false,
        strategy: ResolutionStrategy.localWins,
        description:
            'Local wins but no local data available for '
            '${conflict.tableName}/${conflict.recordId}',
      );
    }

    return ResolutionResult(
      resolved: true,
      strategy: ResolutionStrategy.localWins,
      resolvedData: conflict.localData,
      description:
          'Local version accepted for ${conflict.tableName}/${conflict.recordId}',
    );
  }

  /// Resolve: compare updated_at timestamps
  ResolutionResult _resolveLastWriteWins(SyncConflict conflict) {
    final localData = conflict.localData;
    final serverData = conflict.serverData;

    if (localData == null || serverData == null) {
      // If we only have one side, that side wins
      final winner = localData ?? serverData;
      if (winner == null) {
        return ResolutionResult(
          resolved: false,
          strategy: ResolutionStrategy.lastWriteWins,
          description:
              'Last write wins but no data available for '
              '${conflict.tableName}/${conflict.recordId}',
        );
      }
      return ResolutionResult(
        resolved: true,
        strategy: ResolutionStrategy.lastWriteWins,
        resolvedData: winner,
        description:
            'Only one version available for ${conflict.tableName}/${conflict.recordId}',
      );
    }

    // Compare updated_at (or created_at as fallback)
    final localTime = _parseTimestamp(
      localData['updated_at'] ?? localData['created_at'],
    );
    final serverTime = _parseTimestamp(
      serverData['updated_at'] ?? serverData['created_at'],
    );

    if (localTime == null && serverTime == null) {
      // No timestamps: default to server wins
      return ResolutionResult(
        resolved: true,
        strategy: ResolutionStrategy.serverWins,
        resolvedData: serverData,
        description:
            'No timestamps available, defaulting to server for '
            '${conflict.tableName}/${conflict.recordId}',
      );
    }

    // Special handling for orders: status priority
    if (conflict.tableName == 'orders') {
      return _resolveOrderConflict(
        conflict,
        localData,
        serverData,
        localTime,
        serverTime,
      );
    }

    final localWins =
        localTime != null &&
        (serverTime == null || localTime.isAfter(serverTime));

    return ResolutionResult(
      resolved: true,
      strategy: ResolutionStrategy.lastWriteWins,
      resolvedData: localWins ? localData : serverData,
      description:
          '${localWins ? "Local" : "Server"} version wins by timestamp for '
          '${conflict.tableName}/${conflict.recordId}',
    );
  }

  /// Special resolution for orders: status priority matters
  /// completed > preparing > created
  ResolutionResult _resolveOrderConflict(
    SyncConflict conflict,
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
    DateTime? localTime,
    DateTime? serverTime,
  ) {
    final localStatus = localData['status'] as String? ?? '';
    final serverStatus = serverData['status'] as String? ?? '';

    final localPriority = _orderStatusPriority(localStatus);
    final serverPriority = _orderStatusPriority(serverStatus);

    // Higher status priority wins regardless of timestamp
    if (localPriority != serverPriority) {
      final statusWinnerIsLocal = localPriority > serverPriority;
      return ResolutionResult(
        resolved: true,
        strategy: ResolutionStrategy.lastWriteWins,
        resolvedData: statusWinnerIsLocal ? localData : serverData,
        description:
            '${statusWinnerIsLocal ? "Local" : "Server"} order status '
            '"${statusWinnerIsLocal ? localStatus : serverStatus}" has higher priority '
            'for ${conflict.tableName}/${conflict.recordId}',
      );
    }

    // Same status priority: fall back to timestamp comparison
    final localWins =
        localTime != null &&
        (serverTime == null || localTime.isAfter(serverTime));

    return ResolutionResult(
      resolved: true,
      strategy: ResolutionStrategy.lastWriteWins,
      resolvedData: localWins ? localData : serverData,
      description:
          '${localWins ? "Local" : "Server"} version wins by timestamp '
          '(same status priority) for '
          '${conflict.tableName}/${conflict.recordId}',
    );
  }

  /// Resolve: merge non-conflicting fields
  ///
  /// Used primarily for products where stock_qty should use delta-based merging
  /// and other fields use server values.
  ResolutionResult _resolveMerge(SyncConflict conflict) {
    final localData = conflict.localData;
    final serverData = conflict.serverData;

    if (localData == null || serverData == null) {
      // Can't merge without both sides
      return ResolutionResult(
        resolved: false,
        strategy: ResolutionStrategy.merge,
        description:
            'Cannot merge - missing ${localData == null ? "local" : "server"} data '
            'for ${conflict.tableName}/${conflict.recordId}',
      );
    }

    // Start with server data as base
    final merged = Map<String, dynamic>.from(serverData);

    // For products: keep server price/name but merge stock using delta
    if (conflict.tableName == 'products') {
      // Stock quantity fields use local delta approach
      // The actual delta merge happens in StockDeltaSync,
      // here we just preserve the local stock values temporarily
      final stockFields = {'stock_qty', 'stock_quantity', 'quantity'};
      for (final field in stockFields) {
        if (localData.containsKey(field)) {
          merged[field] = localData[field];
        }
      }
    } else {
      // Generic merge: for each field, if only one side changed it, take that change
      // If both changed the same field, take the server version
      for (final key in localData.keys) {
        if (!serverData.containsKey(key)) {
          // Field only in local data
          merged[key] = localData[key];
        }
      }
    }

    return ResolutionResult(
      resolved: true,
      strategy: ResolutionStrategy.merge,
      resolvedData: merged,
      description:
          'Merged local and server data for ${conflict.tableName}/${conflict.recordId}',
    );
  }

  /// Order status priority (higher number = more progressed = wins)
  int _orderStatusPriority(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return 5;
      case 'cancelled':
      case 'refunded':
        return 4;
      case 'delivering':
      case 'shipped':
        return 3;
      case 'ready':
      case 'preparing':
        return 2;
      case 'confirmed':
        return 1;
      case 'created':
      case 'pending':
      default:
        return 0;
    }
  }

  /// Parse a timestamp value that could be:
  /// - ISO 8601 string
  /// - Unix seconds (int)
  /// - null
  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Resolve a conflict by choosing local or server version
  ///
  /// For [ResolutionStrategy.serverWins], applies the server data locally
  /// by inserting/replacing the record in the target table.
  /// For [ResolutionStrategy.localWins], the local data is already correct
  /// so we just mark the conflict as resolved.
  Future<void> resolveConflict({
    required String conflictId,
    required ResolutionStrategy strategy,
    required AppDatabase db,
    required SyncQueueDao syncQueueDao,
  }) async {
    final conflict = await syncQueueDao.getById(conflictId);
    if (conflict == null) return;

    if (strategy == ResolutionStrategy.serverWins) {
      // Apply server data locally
      final serverData = jsonDecode(conflict.payload) as Map<String, dynamic>;
      final columns = serverData.keys.toList();
      final placeholders = columns.map((_) => '?').join(', ');
      final updates = columns
          .where((c) => c != 'id')
          .map((c) => '$c = excluded.$c')
          .join(', ');

      await db.customStatement(
        'INSERT INTO ${conflict.tableName_} (${columns.join(', ')}) '
        'VALUES ($placeholders) '
        'ON CONFLICT(id) DO UPDATE SET $updates',
        columns.map((c) => serverData[c]).toList(),
      );
    }
    // localWins = just mark as resolved (local data is already correct)

    await syncQueueDao.markAsResolved(conflictId);
  }
}
