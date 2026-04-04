import 'dart:convert';

import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

import '../data/proof_datasource.dart';
import '../../deliveries/providers/delivery_providers.dart';
import '../../../core/services/location_service.dart';

// Top-level function — runs in a separate isolate via compute().
// Must be top-level (not a closure) so Flutter can spawn it.
String _encodeToBase64(Uint8List bytes) => base64Encode(bytes);

class DeliveryProofScreen extends ConsumerStatefulWidget {
  final String deliveryId;

  const DeliveryProofScreen({super.key, required this.deliveryId});

  @override
  ConsumerState<DeliveryProofScreen> createState() =>
      _DeliveryProofScreenState();
}

class _DeliveryProofScreenState extends ConsumerState<DeliveryProofScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  late SignatureController _signatureController;
  bool _signatureControllerInitialized = false;

  Uint8List? _photoBytes;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_signatureControllerInitialized) {
      final cs = Theme.of(context).colorScheme;
      _signatureController = SignatureController(
        penStrokeWidth: 3,
        penColor: cs.onSurface,
      );
      _signatureControllerInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    if (_signatureControllerInitialized) _signatureController.dispose();
    super.dispose();
  }

  /// Shows a brief success dialog with an animated checkmark.
  /// Automatically dismisses after 2 seconds.
  Future<void> _showSuccessOverlay(BuildContext ctx) async {
    final navigator = Navigator.of(ctx);
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) => Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlhaiRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: child,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 72,
                    color: Theme.of(dialogCtx).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.md),
                Text(
                  'تم تسليم الطلب بنجاح!',
                  style: Theme.of(dialogCtx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (navigator.canPop()) navigator.pop();
  }

  Future<void> _capturePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1024,
      // Prevents EXIF metadata (GPS coordinates, device info) from being
      // included in the uploaded image, protecting driver location privacy.
      requestFullMetadata: false,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _photoBytes = bytes);
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      // Encode signature PNG to base64 off the main thread via compute().
      String? signatureDataUri;
      if (_signatureController.isNotEmpty) {
        final signatureBytes = await _signatureController.toPngBytes();
        if (signatureBytes != null) {
          final encoded = await compute(_encodeToBase64, signatureBytes);
          signatureDataUri = 'data:image/png;base64,$encoded';
        }
      }

      // Get current location
      final position = await LocationService.instance.getCurrentPosition();

      final ds = GetIt.instance<ProofDatasource>();
      await ds.submitProof(
        deliveryId: widget.deliveryId,
        photoBytes: _photoBytes,
        signatureData: signatureDataUri,
        recipientName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        lat: position?.latitude,
        lng: position?.longitude,
      );

      // Mark as delivered
      await ref.read(
        updateDeliveryStatusProvider(
          (id: widget.deliveryId, status: 'delivered', notes: null),
        ).future,
      );

      if (mounted) {
        HapticFeedback.heavyImpact();

        // Show animated success overlay before navigating away
        await _showSuccessOverlay(context);

        if (mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ. حاول مرة أخرى')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إثبات التسليم'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AlhaiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo capture
                  Text(
                    'صورة التسليم',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  GestureDetector(
                    onTap: _capturePhoto,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AlhaiRadius.md),
                        border:
                            Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: _photoBytes != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AlhaiRadius.md),
                              // cacheWidth/cacheHeight prevent decoding the full
                              // resolution image just to display a thumbnail.
                              // gaplessPlayback avoids a white flash when the
                              // bytes reference changes (e.g. retake photo).
                              child: Image.memory(
                                _photoBytes!,
                                fit: BoxFit.cover,
                                cacheWidth: 800,
                                gaplessPlayback: true,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 48,
                                  color: theme.colorScheme.outline,
                                ),
                                const SizedBox(height: AlhaiSpacing.xs),
                                Text(
                                  'اضغط لالتقاط صورة',
                                  style: TextStyle(
                                      color: theme.colorScheme.outline),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),

                  // Signature
                  Text(
                    'توقيع المستلم',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AlhaiRadius.md),
                      border:
                          Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AlhaiRadius.md),
                          child: Signature(
                            controller: _signatureController,
                            backgroundColor: theme.colorScheme.surface,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: IconButton(
                            icon: const Icon(Icons.refresh, size: 20),
                            tooltip: 'مسح التوقيع',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('مسح التوقيع'),
                                  content: const Text('هل تريد مسح التوقيع؟'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('إلغاء'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('مسح'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                _signatureController.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),

                  // Recipient name
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'اسم المستلم (اختياري)',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AlhaiRadius.input),
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  // Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      prefixIcon: const Icon(Icons.note_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AlhaiRadius.input),
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xl),

                  // Submit button
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                      _isLoading ? 'جاري التأكيد...' : 'تأكيد التسليم',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: AlhaiSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AlhaiRadius.button),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
