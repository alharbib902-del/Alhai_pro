import 'package:alhai_zatca/src/chaining/chain_store.dart';
import 'package:alhai_zatca/src/signing/invoice_hasher.dart';

/// Manages invoice hash chaining (PIH - Previous Invoice Hash)
///
/// ZATCA Phase 2 requires each invoice to include the hash of the
/// previous invoice (KSA-13). This service manages the chain.
///
/// The very first invoice uses a well-known seed hash:
/// Base64(SHA-256("0")) where "0" is the literal string.
///
/// This matches the ZATCA SDK sample: the seed value is computed at
/// initialization time via [InvoiceHasher.hashString] to stay consistent
/// with the hashing implementation used throughout the signing pipeline.
class InvoiceChainService {
  /// The seed hash for the very first invoice in a chain.
  ///
  /// Computed as Base64(SHA-256("0")) -- the raw hash bytes base64-encoded,
  /// consistent with how [InvoiceHasher.hashString] produces hashes.
  ///
  /// SHA-256("0") = 5feceb66ffc86f38d952786c6d696c79c2dbc239dd4e91b46729d73a27fb57e9
  /// Base64 of those 32 bytes = "X+zrZv/IbzjZUnhsbWlsecLbwjndTpG0ZynXOif7V+k="
  static final String seedHash = InvoiceHasher.hashString('0');

  final ChainStore _store;
  final InvoiceHasher _hasher;

  InvoiceChainService({
    required ChainStore store,
    InvoiceHasher? hasher,
  })  : _store = store,
        _hasher = hasher ?? InvoiceHasher();

  /// Get the previous invoice hash for use in a new invoice
  ///
  /// Returns the seed hash if no previous invoice exists.
  Future<String> getPreviousHash({required String storeId}) async {
    final lastHash = await _store.getLastHash(storeId: storeId);
    return lastHash ?? seedHash;
  }

  /// Update the chain with the hash of a newly created invoice
  ///
  /// Call this after successfully generating and signing an invoice.
  Future<void> updateLastHash({
    required String storeId,
    required String invoiceHash,
  }) async {
    await _store.saveLastHash(storeId: storeId, hash: invoiceHash);
  }

  /// Compute and store the hash of a signed invoice XML
  Future<String> computeAndStore({
    required String storeId,
    required String signedInvoiceXml,
  }) async {
    final hash = _hasher.computeHash(signedInvoiceXml);
    await updateLastHash(storeId: storeId, invoiceHash: hash);
    return hash;
  }

  /// Reset the chain for a store (e.g., after re-onboarding)
  Future<void> resetChain({required String storeId}) async {
    await _store.deleteLastHash(storeId: storeId);
  }
}
