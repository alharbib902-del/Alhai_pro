/// Phase 5 §5.1 — Golden test configuration.
///
/// Goldens are pixel-exact PNG snapshots. Text rendering, anti-aliasing and
/// shader output differ between operating systems, so a master generated on
/// Windows will fail diff on Linux and vice-versa. The project standardises
/// on Ubuntu (CI runner) as the canonical platform.
///
/// How to use:
/// - CI / Linux: goldens run normally. Regenerate with
///   `flutter test --update-goldens test/goldens/`.
/// - Windows / macOS (local dev): tests are skipped unless
///   `--dart-define=GOLDEN_FORCE=true` is passed. This prevents local runs
///   from failing on platform diffs and stops accidental `--update-goldens`
///   from poisoning the repo with non-canonical masters.
///
/// Screens covered (Phase 5.1):
/// - POS: empty cart (light + dark × ar + en × 3 sizes)
/// - Shift open (lg surface)
/// - Payment screen (cash ready state)
///
/// Layout matrix per screen:
/// - 2 themes × 2 locales × 3 surfaces (1920×1080 desktop, 1024×768 tablet,
///   375×812 mobile) = 12 goldens per screen. At 20 screens = 240 PNGs.
library;

import 'dart:io';
import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// Returns `true` if goldens should run on this host.
///
/// Defaults to Linux only to match CI. Override with
/// `--dart-define=GOLDEN_FORCE=true` to run locally anyway (diffs likely).
bool get shouldRunGoldens {
  const force = bool.fromEnvironment('GOLDEN_FORCE');
  if (force) return true;
  return Platform.isLinux;
}

/// Standard surface sizes for multi-size golden tests.
const Size kDesktopSize = Size(1920, 1080);
const Size kTabletSize = Size(1024, 768);
const Size kMobileSize = Size(375, 812);

/// Device descriptors for `multiScreenGolden`. Reused across screens so the
/// entire golden suite has a consistent layout matrix.
final List<Device> kGoldenDevices = <Device>[
  const Device(name: 'desktop', size: kDesktopSize),
  const Device(name: 'tablet', size: kTabletSize),
  const Device(name: 'mobile', size: kMobileSize),
];

/// Wrapper around [testGoldens] that skips on non-canonical platforms.
///
/// Prevents noisy local failures while keeping the suite honest on CI.
void goldenTest(String description, Future<void> Function(WidgetTester) body) {
  testGoldens(description, (tester) async {
    if (!shouldRunGoldens) {
      markTestSkipped('skipped: goldens only run on Linux (CI)');
      return;
    }
    await body(tester);
  });
}
