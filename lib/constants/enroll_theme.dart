import 'package:enroll_neo_plugin/constants/enroll_colors.dart';
import 'package:enroll_neo_plugin/constants/enroll_icons.dart';

/// Unified theme configuration for the eNROLL Neo SDK.
///
/// > **Under Development — Android only.**
/// > `EnrollTheme` is currently supported on **Android only**.
/// > iOS support is planned for a future release.
/// > For cross-platform color customization, use the `enrollColors` parameter on
/// > [EnrollNeoPlugin] directly instead.
///
/// Groups color and icon customization under a single concept,
/// aligned with the Android SDK's `AppTheme` structure.
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

  /// Creates an [EnrollTheme] with optional color and icon customization.
  const EnrollTheme({
    this.colors,
    this.icons,
  });

  /// Converts the theme to a JSON map for serialization to the native bridge.
  Map<String, dynamic> toJson() =>
      {
        if (colors != null) 'colors': colors!.toJson(),
        if (icons != null) 'icons': icons!.toJson(),
      };
}
