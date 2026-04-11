/// Persistence layer for invoice hash chain
///
/// Stores the last invoice hash per store for PIH chaining.
/// Implementations can use local database, shared preferences, etc.
abstract class ChainStore {
  /// Get the last stored invoice hash for a store
  ///
  /// Returns null if no previous hash exists (first invoice).
  Future<String?> getLastHash({required String storeId});

  /// Save the latest invoice hash for a store
  Future<void> saveLastHash({required String storeId, required String hash});

  /// Delete the stored hash for a store (reset chain)
  Future<void> deleteLastHash({required String storeId});
}

/// In-memory implementation of [ChainStore] for testing
class InMemoryChainStore implements ChainStore {
  final Map<String, String> _hashes = {};

  @override
  Future<String?> getLastHash({required String storeId}) async {
    return _hashes[storeId];
  }

  @override
  Future<void> saveLastHash({
    required String storeId,
    required String hash,
  }) async {
    _hashes[storeId] = hash;
  }

  @override
  Future<void> deleteLastHash({required String storeId}) async {
    _hashes.remove(storeId);
  }
}
