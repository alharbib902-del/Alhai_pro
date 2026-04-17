/// Dialog for uploading a distributor legal document.
library;

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';

/// Shows a dialog for selecting and uploading a legal document.
///
/// Returns the uploaded [DistributorDocument] on success, or null on cancel.
Future<DistributorDocument?> showUploadDocumentDialog(
  BuildContext context, {

  /// Document types that already have an active (under_review or approved) doc.
  List<DocumentType> disabledTypes = const [],
}) {
  return showDialog<DistributorDocument>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _UploadDocumentDialog(disabledTypes: disabledTypes),
  );
}

class _UploadDocumentDialog extends ConsumerStatefulWidget {
  final List<DocumentType> disabledTypes;

  const _UploadDocumentDialog({required this.disabledTypes});

  @override
  ConsumerState<_UploadDocumentDialog> createState() =>
      _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends ConsumerState<_UploadDocumentDialog> {
  static const int _maxFileSize = 10 * 1024 * 1024; // 10 MB
  static const List<String> _allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  DocumentType? _selectedType;
  Uint8List? _fileBytes;
  String? _fileName;
  String? _mimeType;
  DateTime? _expiryDate;
  String? _fileError;
  bool _isUploading = false;

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        setState(() => _fileError = 'تعذّر قراءة الملف');
        return;
      }

      if (bytes.length > _maxFileSize) {
        setState(() => _fileError = 'حجم الملف يجب أن يكون أقل من 10 ميجابايت');
        return;
      }

      final ext = file.extension?.toLowerCase() ?? '';
      if (!_allowedExtensions.contains(ext)) {
        setState(() => _fileError = 'نوع الملف غير مدعوم (PDF, JPG, PNG فقط)');
        return;
      }

      setState(() {
        _fileBytes = bytes;
        _fileName = file.name;
        _mimeType = _getMimeType(ext);
        _fileError = null;
      });
    } catch (e) {
      setState(() => _fileError = 'خطأ في اختيار الملف');
    }
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
      helpText: 'تاريخ انتهاء الوثيقة',
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _upload() async {
    if (_selectedType == null || _fileBytes == null || _fileName == null)
      return;

    setState(() => _isUploading = true);
    try {
      final ds = ref.read(distributorDatasourceProvider);
      final doc = await ds.uploadDocument(
        type: _selectedType!,
        fileBytes: _fileBytes!,
        fileName: _fileName!,
        mimeType: _mimeType ?? 'application/octet-stream',
        expiryDate: _expiryDate,
      );
      ref.invalidate(distributorDocumentsProvider);
      if (mounted) Navigator.of(context).pop(doc);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is Exception ? e.toString() : 'فشل رفع الوثيقة'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get _canSubmit =>
      _selectedType != null && _fileBytes != null && !_isUploading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Text('رفع وثيقة جديدة'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Document type dropdown
              DropdownButtonFormField<DocumentType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'نوع الوثيقة *',
                  border: OutlineInputBorder(),
                ),
                items: DocumentType.values.map((type) {
                  final isDisabled = widget.disabledTypes.contains(type);
                  return DropdownMenuItem(
                    value: isDisabled ? null : type,
                    enabled: !isDisabled,
                    child: Text(
                      '${type.arabicName}${isDisabled ? ' (موجودة)' : ''}${type.isRequired ? '' : ' (اختياري)'}',
                      style: TextStyle(
                        color: isDisabled
                            ? AppColors.getTextSecondary(isDark)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedType = v),
              ),

              const SizedBox(height: AlhaiSpacing.md),

              // File picker
              OutlinedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                icon: const Icon(Icons.upload_file),
                label: Text(_fileName ?? 'اختر ملف (PDF, JPG, PNG)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                ),
              ),

              if (_fileBytes != null && _fileName != null) ...[
                const SizedBox(height: AlhaiSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _mimeType == 'application/pdf'
                            ? Icons.picture_as_pdf
                            : Icons.image,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: AlhaiSpacing.sm),
                      Expanded(
                        child: Text(
                          '$_fileName (${_formatFileSize(_fileBytes!.length)})',
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _isUploading
                            ? null
                            : () {
                                setState(() {
                                  _fileBytes = null;
                                  _fileName = null;
                                  _mimeType = null;
                                });
                              },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],

              if (_fileError != null) ...[
                const SizedBox(height: AlhaiSpacing.xs),
                Text(
                  _fileError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ],

              const SizedBox(height: AlhaiSpacing.md),

              // Expiry date (optional)
              InkWell(
                onTap: _isUploading ? null : _pickExpiryDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الانتهاء (اختياري)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, size: 20),
                  ),
                  child: Text(
                    _expiryDate != null
                        ? '${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}'
                        : '',
                    style: TextStyle(
                      color: _expiryDate != null
                          ? null
                          : AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ),
              ),

              if (_isUploading) ...[
                const SizedBox(height: AlhaiSpacing.md),
                const LinearProgressIndicator(),
                const SizedBox(height: AlhaiSpacing.xs),
                Text(
                  'جارٍ رفع الوثيقة...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton.icon(
          onPressed: _canSubmit ? _upload : null,
          icon: const Icon(Icons.upload, size: 18),
          label: const Text('رفع'),
        ),
      ],
    );
  }
}
