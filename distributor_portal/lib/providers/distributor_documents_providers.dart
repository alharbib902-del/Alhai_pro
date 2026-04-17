/// Providers for distributor document management.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import 'distributor_datasource_provider.dart';

/// List of all documents for the current distributor org.
final distributorDocumentsProvider =
    FutureProvider.autoDispose<List<DistributorDocument>>((ref) async {
      final ds = ref.watch(distributorDatasourceProvider);
      return ds.getDocuments();
    });

/// Signed URL for viewing a document (1-hour expiry).
final documentSignedUrlProvider = FutureProvider.autoDispose
    .family<String, String>((ref, storagePath) async {
      final ds = ref.read(distributorDatasourceProvider);
      return ds.getDocumentSignedUrl(storagePath);
    });
