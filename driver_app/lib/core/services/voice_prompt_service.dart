import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service for voice prompts during driving mode.
///
/// Uses flutter_tts to speak delivery status changes in Arabic.
/// All methods are safe to call even if TTS is unavailable — failures
/// are silently swallowed to avoid disrupting the delivery flow.
class VoicePromptService {
  VoicePromptService._();
  static final VoicePromptService instance = VoicePromptService._();

  FlutterTts? _tts;
  bool _initialized = false;

  /// Lazily initializes TTS engine.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      _tts = FlutterTts();
      await _tts!.setLanguage('ar-SA');
      await _tts!.setSpeechRate(0.5);
      await _tts!.setVolume(1.0);
      _initialized = true;
    } catch (e) {
      if (kDebugMode) debugPrint('VoicePrompt: init failed — $e');
      _tts = null;
    }
  }

  /// Speak the given [text]. Silent no-op if TTS is unavailable.
  Future<void> speak(String text) async {
    try {
      await _ensureInitialized();
      await _tts?.speak(text);
    } catch (e) {
      if (kDebugMode) debugPrint('VoicePrompt: speak failed — $e');
    }
  }

  /// Stop any ongoing speech.
  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }

  /// Speak a delivery status change prompt.
  Future<void> announceStatus(String status) async {
    final prompt = _statusPrompts[status];
    if (prompt != null) {
      await speak(prompt);
    }
  }

  static const _statusPrompts = <String, String>{
    'accepted': 'تم قبول الطلب',
    'heading_to_pickup': 'بدأت التوجه للمتجر',
    'arrived_at_pickup': 'وصلت إلى نقطة الاستلام',
    'picked_up': 'تم استلام الطلب',
    'heading_to_customer': 'بدأت التوصيل للعميل',
    'arrived_at_customer': 'وصلت إلى العميل',
    'delivered': 'تم تسليم الطلب بنجاح',
  };
}
