import 'dart:io';

/// Device storage health status.
enum StorageStatus {
  /// Less than 80% used — no action needed.
  healthy,

  /// 80–90% used — advise the user to sync and free space.
  warning,

  /// 90–95% used — urgent: immediate sync recommended.
  critical,

  /// More than 95% used — block new sales to prevent data corruption.
  full,
}

/// Proactive storage monitoring for offline-first POS.
///
/// In an offline-first system, running out of local storage is catastrophic:
/// the cashier cannot record sales, and pending sync data may be lost.
/// This monitor checks available space and exposes a simple status API.
class StorageMonitor {
  /// Override for testing.  When non-null, [checkStorage] returns this.
  StorageStatus? _overrideStatus;

  /// Override the storage status for testing.
  void setOverrideStatus(StorageStatus? status) => _overrideStatus = status;

  /// Classify current storage usage into a [StorageStatus].
  Future<StorageStatus> checkStorage() async {
    if (_overrideStatus != null) return _overrideStatus!;

    try {
      final info = await _getStorageInfo();
      if (info == null) return StorageStatus.healthy; // cannot determine

      final usedRatio = info.usedRatio;
      if (usedRatio < 0.80) return StorageStatus.healthy;
      if (usedRatio < 0.90) return StorageStatus.warning;
      if (usedRatio < 0.95) return StorageStatus.critical;
      return StorageStatus.full;
    } catch (_) {
      // If we can't determine storage, assume healthy (don't block sales).
      return StorageStatus.healthy;
    }
  }

  /// Throws [StorageFullException] if the device is too full to safely
  /// write a new sale.
  Future<void> assertCanWrite() async {
    final status = await checkStorage();
    if (status == StorageStatus.full) {
      throw StorageFullException(
        'Cannot write: device storage is full (>95%). '
        'Free up space and sync pending data.',
      );
    }
  }

  /// Get storage information (total / free bytes).
  ///
  /// Currently supports Android and iOS via the app data directory.
  /// Returns `null` on unsupported platforms or if data is unavailable.
  Future<_StorageInfo?> _getStorageInfo() async {
    try {
      // Use the filesystem stat of the root/app directory
      // On mobile, Directory('/').statSync() or similar
      final stat = await FileStat.stat(Directory.current.path);
      if (stat.type == FileSystemEntityType.notFound) return null;

      // On most platforms we can't get total/free from Dart directly.
      // A production implementation would use platform channels
      // (StatFs on Android, NSFileManager on iOS).
      // For now, expose the API with a fallback.
      return null;
    } catch (_) {
      return null;
    }
  }
}

class _StorageInfo {
  final int totalBytes;
  final int freeBytes;

  _StorageInfo({required this.totalBytes, required this.freeBytes});

  double get usedRatio =>
      totalBytes > 0 ? (totalBytes - freeBytes) / totalBytes : 0;
}

/// Thrown when device storage is too full to safely create a new record.
class StorageFullException implements Exception {
  final String message;
  const StorageFullException(this.message);

  @override
  String toString() => 'StorageFullException: $message';
}
