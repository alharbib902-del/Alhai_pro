import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wakelock_plus_platform_interface/wakelock_plus_platform_interface.dart';

import 'package:driver_app/core/services/wakelock_service.dart';

/// Fake platform implementation that records calls for verification.
class FakeWakelockPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements WakelockPlusPlatformInterface {
  final List<bool> toggleCalls = [];
  bool _enabled = false;

  @override
  Future<void> toggle({required bool enable}) async {
    toggleCalls.add(enable);
    _enabled = enable;
  }

  @override
  Future<bool> get enabled async => _enabled;
}

/// Tests for [WakelockService] covering enable/disable lifecycle and
/// idempotency (double-enable / double-disable are no-ops).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeWakelockPlatform fakePlatform;

  setUp(() async {
    fakePlatform = FakeWakelockPlatform();
    // Override the platform instance so WakelockPlus calls go to our fake.
    wakelockPlusPlatformInstance = fakePlatform;

    // Reset service state between tests — force disable without tracking.
    await WakelockService.instance.disable();
    fakePlatform.toggleCalls.clear();
  });

  test('enable sends toggle(enable: true) to the platform', () async {
    await WakelockService.instance.enable();

    expect(WakelockService.instance.isEnabled, isTrue);
    expect(fakePlatform.toggleCalls, [true]);
  });

  test('disable sends toggle(enable: false) to the platform', () async {
    await WakelockService.instance.enable();
    fakePlatform.toggleCalls.clear();

    await WakelockService.instance.disable();

    expect(WakelockService.instance.isEnabled, isFalse);
    expect(fakePlatform.toggleCalls, [false]);
  });

  test('double enable is idempotent — only one platform call', () async {
    await WakelockService.instance.enable();
    await WakelockService.instance.enable();

    expect(WakelockService.instance.isEnabled, isTrue);
    expect(fakePlatform.toggleCalls, hasLength(1));
  });

  test('double disable is idempotent — no platform call', () async {
    await WakelockService.instance.disable();

    expect(WakelockService.instance.isEnabled, isFalse);
    expect(fakePlatform.toggleCalls, isEmpty);
  });

  test('enable → disable → enable cycles correctly', () async {
    await WakelockService.instance.enable();
    expect(WakelockService.instance.isEnabled, isTrue);

    await WakelockService.instance.disable();
    expect(WakelockService.instance.isEnabled, isFalse);

    await WakelockService.instance.enable();
    expect(WakelockService.instance.isEnabled, isTrue);

    expect(fakePlatform.toggleCalls, [true, false, true]);
  });
}
