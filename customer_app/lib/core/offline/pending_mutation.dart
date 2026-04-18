import 'dart:convert';

/// A mutation that failed to execute because of a transient network error
/// and has been queued for a later retry attempt.
///
/// The [type] is an opaque string used by [OfflineQueueService] to dispatch
/// the mutation to the correct handler (e.g. `order.submit`). The [payload]
/// is the fully serialized request body — it must be JSON-encodable.
class PendingMutation {
  final String id;
  final String type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  const PendingMutation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  PendingMutation copyWith({int? retryCount, String? lastError}) {
    return PendingMutation(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'payload': payload,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'retryCount': retryCount,
    if (lastError != null) 'lastError': lastError,
  };

  factory PendingMutation.fromJson(Map<String, dynamic> json) {
    return PendingMutation(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: Map<String, dynamic>.from(
        json['payload'] as Map<dynamic, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      lastError: json['lastError'] as String?,
    );
  }

  String encode() => jsonEncode(toJson());

  factory PendingMutation.decode(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return PendingMutation.fromJson(decoded);
  }
}
