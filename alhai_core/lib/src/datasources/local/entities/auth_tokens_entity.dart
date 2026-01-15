/// Entity for storing auth tokens locally
class AuthTokensEntity {
  final String accessToken;
  final String refreshToken;
  final String expiresAt; // ISO8601 string

  const AuthTokensEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// Checks if the access token is expired
  bool get isExpired {
    final expiry = DateTime.tryParse(expiresAt);
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Checks if token expires within the given duration
  bool expiresWithin(Duration duration) {
    final expiry = DateTime.tryParse(expiresAt);
    if (expiry == null) return true;
    return DateTime.now().add(duration).isAfter(expiry);
  }

  /// Converts to JSON for storage
  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt,
      };

  /// Creates from JSON storage
  factory AuthTokensEntity.fromJson(Map<String, dynamic> json) {
    return AuthTokensEntity(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: json['expires_at'] as String,
    );
  }

  /// Creates from DateTime (convenience)
  factory AuthTokensEntity.fromDateTime({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) {
    return AuthTokensEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt.toIso8601String(),
    );
  }
}
