/// BackupFileIO — Save As / Open file helpers for backup files.
///
/// Wave 5 (P0-08/09): the legacy backup screen pushed the encoded JSON
/// through the system clipboard. That meant any other app on the device
/// could read PII (phone numbers, balances, ZATCA chain) from the
/// clipboard until the user manually wiped it. These helpers replace
/// the clipboard path with proper file I/O via the OS picker.
///
/// On Android `share_plus` opens the system Share sheet which surfaces
/// "Save to Files / Drive / nearby" — internally it goes through
/// FileProvider so the Files app's SAF picker is one tap away. On iOS
/// the Share sheet exposes the Files app + iCloud + AirDrop. On
/// desktop / web `file_picker` falls back to platform conventions.
///
/// `loadEncryptedBackup` lets the cashier pick any saved backup file —
/// no need to keep it in clipboard or in a fixed app-private folder.
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupFileIO {
  const BackupFileIO();

  /// Save [base64Envelope] as `alhai_backup_{ts}.albk` and surface the
  /// system Share sheet so the cashier can route it to Files / Drive
  /// / iCloud / AirDrop.
  ///
  /// Returns the on-disk path of the temp file (same path that was
  /// shared). Caller can show "saved to <path>" or just confirm via the
  /// Share sheet's own UI.
  ///
  /// `.albk` (Alhai Backup) marker keeps the file recognisable in
  /// Files apps. Apps that don't know the extension still treat it as
  /// opaque binary, which is the right thing for an encrypted blob.
  Future<String> shareEncryptedBackup({
    required String base64Envelope,
    required DateTime createdAt,
    String? subject,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final ts =
        '${createdAt.year}${_pad(createdAt.month)}${_pad(createdAt.day)}_'
        '${_pad(createdAt.hour)}${_pad(createdAt.minute)}${_pad(createdAt.second)}';
    final fileName = 'alhai_backup_$ts.albk';
    final file = File(p.join(tempDir.path, fileName));
    await file.writeAsString(base64Envelope, flush: true);

    if (kDebugMode) {
      debugPrint('[BackupFileIO] Wrote temp backup ${file.lengthSync()}B → ${file.path}');
    }

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/octet-stream')],
      subject: subject,
      text: subject,
    );

    return file.path;
  }

  /// Open the OS file picker so the cashier can choose a `.albk` (or
  /// any) backup file, then return its base64 contents ready to feed
  /// into `BackupCrypto.decryptToString`.
  ///
  /// Returns null if the user cancels the picker. Throws if the picked
  /// file can't be read.
  Future<String?> pickEncryptedBackup() async {
    final result = await FilePicker.platform.pickFiles(
      // We can't lock to .albk because file_picker on iOS doesn't
      // expose UTI extensions for unknown types — falling back to "any"
      // lets the cashier point at backups they renamed or stored as
      // .txt / .json. The decrypt call rejects garbage anyway.
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.first;

    // On web, `path` is null and we have to use `bytes`. On native,
    // either path or bytes works — bytes saves us a re-read.
    if (picked.bytes != null) {
      return String.fromCharCodes(picked.bytes!).trim();
    }
    if (picked.path != null) {
      return File(picked.path!).readAsString();
    }
    return null;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
