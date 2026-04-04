/// Typed model for a platform user in the super admin context.
class SAUser {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? role;
  final String? createdAt;
  final String? lastSignInAt;
  final bool? isActive;

  /// Additional fields returned by getUser(*) select.
  final String? storeId;

  const SAUser({
    required this.id,
    this.name,
    this.phone,
    this.email,
    this.role,
    this.createdAt,
    this.lastSignInAt,
    this.isActive,
    this.storeId,
  });

  factory SAUser.fromJson(Map<String, dynamic> json) {
    return SAUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      createdAt: json['created_at'] as String?,
      lastSignInAt: json['last_sign_in_at'] as String?,
      isActive: json['is_active'] as bool?,
      storeId: json['store_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'created_at': createdAt,
        'last_sign_in_at': lastSignInAt,
        'is_active': isActive,
        'store_id': storeId,
      };

  /// Check if user is currently online (last sign-in within 5 minutes).
  bool get isOnline {
    if (lastSignInAt == null) return false;
    final dt = DateTime.tryParse(lastSignInAt!);
    if (dt == null) return false;
    return DateTime.now().difference(dt).inMinutes < 5;
  }

  /// Format "last active" as a human-readable relative time.
  String get lastActiveFormatted {
    if (lastSignInAt == null) return 'Never';
    final dt = DateTime.tryParse(lastSignInAt!);
    if (dt == null) return 'Unknown';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 5) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
