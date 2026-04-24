# Audio feedback assets

These three MP3 files are **0-byte placeholders** used by `SoundService`
(`lib/core/services/sound_service.dart`). The service tolerates missing or
invalid audio files — when `AudioPlayer.setAsset` fails (as it does on
empty bytes) the service stays un-initialised and every `play*` call
becomes a no-op, so the app continues to work normally.

## Files

| File | Used when | Suggested length |
|---|---|---|
| `beep.mp3` | Barcode scan success | ~80 ms short tick |
| `success.mp3` | Sale / payment completed | ~300 ms upbeat chime |
| `error.mp3` | Product not found / sale save failed | ~400 ms low buzz |

## Replacing before production

1. Record or license short audio clips (44.1 kHz MP3, mono, 96 kbps is fine).
2. Overwrite the three files in-place — keep the exact filenames so no
   code changes are needed.
3. Re-run `flutter pub get` is **not** required; `flutter clean` then
   `flutter run` picks up asset changes on a full rebuild.

`just_audio` is loaded on all platforms (Android/iOS/desktop/web). On
desktop/web some codecs may require additional system libs; the service
gracefully falls back to silent mode rather than crashing.
