import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;
import 'package:alhai_l10n/alhai_l10n.dart';

import '../core/services/clock_validation_service.dart';

/// Banner that warns when the device clock is inaccurate.
///
/// ZATCA requires accurate timestamps on invoices. When the device clock
/// drifts more than 5 minutes from the server, this banner appears with
/// an Arabic warning: "ساعة الجهاز غير دقيقة - يرجى ضبط الوقت"
class ClockInvalidBanner extends StatefulWidget {
  const ClockInvalidBanner({super.key});

  @override
  State<ClockInvalidBanner> createState() => _ClockInvalidBannerState();
}

class _ClockInvalidBannerState extends State<ClockInvalidBanner> {
  late bool _isValid;
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    final service = ClockValidationService.instance;
    _isValid = service.isClockValid;

    _subscription = service.onClockValidityChanged.listen((valid) {
      if (mounted) {
        setState(() => _isValid = valid);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isValid) return const SizedBox.shrink();

    final offset = ClockValidationService.instance.clockOffset;
    final offsetMinutes = offset.inMinutes.abs();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.xs,
      ),
      color: colorScheme.error,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, color: colorScheme.onError, size: 18),
          const SizedBox(width: AlhaiSpacing.xs),
          Flexible(
            child: Text(
              AppLocalizations.of(context).deviceClockInaccurate(offsetMinutes),
              style: TextStyle(
                color: colorScheme.onError,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
