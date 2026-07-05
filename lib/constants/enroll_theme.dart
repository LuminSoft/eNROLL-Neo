import 'package:enroll_neo_plugin/constants/enroll_colors.dart';
import 'package:enroll_neo_plugin/constants/enroll_icons.dart';
import 'package:enroll_neo_plugin/constants/enroll_typography.dart';

/// Unified theme configuration for the eNROLL Neo SDK.
///
/// Platform support:
/// - `colors`: Android **and** iOS.
/// - `icons`: Android only (iOS support planned).
/// - `typography`: Android (iOS support planned).
///
/// Groups color, icon and typography customization under a single concept,
/// aligned with the native SDK's `AppTheme` structure.
///
/// If both [EnrollNeoPlugin.enrollTheme] and [EnrollNeoPlugin.enrollColors] are
/// provided, `enrollTheme` takes priority and `enrollColors` is ignored.
///
/// Example:
/// ```dart
/// EnrollTheme(
///   colors: EnrollColors(
///     primary: Color(0xFF1D56B8),
///     secondary: Color(0xFF5791DB),
///   ),
///   icons: EnrollIcons(
///     logo: EnrollLogoConfig(
///       mode: EnrollLogoMode.custom,
///       assetName: 'my_logo',
///       showSponsoredBy: false,
///     ),
///     location: EnrollLocationIcons(
///       tutorial: EnrollStepIcon(assetName: 'my_location'),
///     ),
///   ),
/// )
/// ```
class EnrollTheme {
  /// Color customization for the SDK UI.
  final EnrollColors? colors;

  /// Icon customization for logo and step illustrations.
  final EnrollIcons? icons;

  /// Typography customization (font family, sizes, dynamic type and
  /// JSON-file based localization overrides).
  final EnrollTypography? typography;

  /// Creates an [EnrollTheme] with optional color, icon and typography
  /// customization.
  const EnrollTheme({
    this.colors,
    this.icons,
    this.typography,
  });

  /// Converts the theme to a JSON map for serialization to the native bridge.
  ///
  /// Native bridges read `theme.typography` from this payload.
  Map<String, dynamic> toJson() =>
      {
        if (colors != null) 'colors': colors!.toJson(),
        if (icons != null) 'icons': icons!.toJson(),
        if (typography != null) 'typography': typography!.toJson(),
      };
}
