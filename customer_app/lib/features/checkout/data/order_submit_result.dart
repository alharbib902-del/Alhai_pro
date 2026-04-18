import 'package:alhai_core/alhai_core.dart';

/// Outcome of a checkout submission.
///
/// Either the order was accepted by the server ([OrderSubmitCreated]) or the
/// request failed due to transient network trouble and has been placed on
/// the offline queue ([OrderSubmitQueued]) for retry when connectivity
/// returns.
sealed class OrderSubmitResult {
  const OrderSubmitResult();
}

class OrderSubmitCreated extends OrderSubmitResult {
  final Order order;
  const OrderSubmitCreated(this.order);
}

class OrderSubmitQueued extends OrderSubmitResult {
  /// Client-generated queue id for diagnostic surfaces.
  final String pendingId;
  const OrderSubmitQueued(this.pendingId);
}
