import 'package:flutter/material.dart';

enum DeviceType { phone, tablet, desktop }

class Responsive {
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return DeviceType.desktop;
    if (width >= 600) return DeviceType.tablet;
    return DeviceType.phone;
  }

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) != DeviceType.phone;

  static bool isPhone(BuildContext context) =>
      getDeviceType(context) == DeviceType.phone;

  static double getValue(
    BuildContext context, {
    required double phone,
    double? tablet,
    double? desktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.phone:
        return phone;
    }
  }

  static int getGridColumns(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.desktop:
        return 3;
      case DeviceType.tablet:
        return 2;
      case DeviceType.phone:
        return 1;
    }
  }
}
