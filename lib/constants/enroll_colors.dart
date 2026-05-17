import 'dart:ui';

import 'colors/dynamic_color.dart';

int? _colorChannel(Color? color, double Function(Color color) channel) {
  if (color == null) return null;
  return (channel(color) * 255.0).round().clamp(0, 255);
}

DynamicColor _dynamicColor(Color? color) {
  return DynamicColor(
    r: _colorChannel(color, (color) => color.r),
    g: _colorChannel(color, (color) => color.g),
    b: _colorChannel(color, (color) => color.b),
    opacity: color?.a,
  );
}

/// Represents the SDK colors
class EnrollColors {
  /// Represents the primary color
  DynamicColor? primary;

  /// Represents the secondary color
  DynamicColor? secondary;

  /// Represents the background color
  DynamicColor? appBackgroundColor;

  /// Represents the text color
  DynamicColor? textColor;

  /// Represents the error color
  DynamicColor? errorColor;

  /// Represents the success color
  DynamicColor? successColor;

  /// Represents the warning color
  DynamicColor? warningColor;

  /// Represents the white color
  DynamicColor? appWhite;

  /// Represents the black color
  DynamicColor? appBlack;

  /// Represents the class constructor
  EnrollColors({
    Color? primary,
    Color? secondary,
    Color? appBackgroundColor,
    Color? textColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? appWhite,
    Color? appBlack,
  }) {
    this.primary = _dynamicColor(primary);
    this.secondary = _dynamicColor(secondary);
    this.appBackgroundColor = _dynamicColor(appBackgroundColor);
    this.textColor = _dynamicColor(textColor);
    this.errorColor = _dynamicColor(errorColor);
    this.successColor = _dynamicColor(successColor);
    this.warningColor = _dynamicColor(warningColor);
    this.appWhite = _dynamicColor(appWhite);
    this.appBlack = _dynamicColor(appBlack);
  }

  /// Convert the colors map to json object
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (primary != null) {
      data['primary'] = primary!.toJson();
    }
    if (secondary != null) {
      data['secondary'] = secondary!.toJson();
    }
    if (appBackgroundColor != null) {
      data['appBackgroundColor'] = appBackgroundColor!.toJson();
    }
    if (textColor != null) {
      data['textColor'] = textColor!.toJson();
    }
    if (errorColor != null) {
      data['errorColor'] = errorColor!.toJson();
    }
    if (successColor != null) {
      data['successColor'] = successColor!.toJson();
    }
    if (warningColor != null) {
      data['warningColor'] = warningColor!.toJson();
    }
    if (appWhite != null) {
      data['appWhite'] = appWhite!.toJson();
    }
    if (appBlack != null) {
      data['appBlack'] = appBlack!.toJson();
    }
    return data;
  }
}
