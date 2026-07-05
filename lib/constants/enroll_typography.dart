/// Typography customization for the eNROLL Neo SDK.
///
/// Configure a custom font family, dynamic type behavior, font size presets
/// and optional JSON-file based localization overrides loaded from the host
/// app by file name.
///
/// On iOS, [fontFamily] is the PostScript/family name registered in
/// `Info.plist`. On Android, [fontFamily] is the font resource name in
/// `res/font` without the extension.
library;

/// Logical text styles used by the SDK. Provided here purely as a reference
/// for consumers; not serialized over the method channel.
enum EnrollTextStyle {
  title,
  subTitle,
  body,
  button,
  input,
}

/// Predefined font-size presets supported by the native SDKs.
///
/// The native iOS `EnrollFontSizes` is now initialized with one of three
/// presets instead of individual per-style sizes. Mirror that here.
///
/// Note: `default` is a reserved word in Dart, so the enum value is named
/// [EnrollFontSizes.defaultSize] but serialized as the string `"default"`.
enum EnrollFontSizes {
  defaultSize,
  medium,
  large;

  /// Wire format expected by the native bridges.
  String toJson() {
    switch (this) {
      case EnrollFontSizes.defaultSize:
        return 'default';
      case EnrollFontSizes.medium:
        return 'medium';
      case EnrollFontSizes.large:
        return 'large';
    }
  }
}

/// Localization overrides loaded from JSON files bundled with the host app.
///
/// On iOS the files are resolved from `Bundle.main` by name. On Android they
/// are resolved from the app assets by name. No extension is required;
/// `.json` is assumed when not provided. The JSON may be a flat
/// `{ "key": "value" }` map, or the nested
/// `{ "localizationOverrides": { "en": { ... }, "ar": { ... } } }` shape.
class EnrollLocalizationOverrides {
  /// File name (without `.json`) for English overrides.
  final String? englishFileName;

  /// File name (without `.json`) for Arabic overrides.
  final String? arabicFileName;

  const EnrollLocalizationOverrides({
    this.englishFileName,
    this.arabicFileName,
  });

  Map<String, dynamic> toJson() => {
        if (englishFileName != null) 'englishFileName': englishFileName,
        if (arabicFileName != null) 'arabicFileName': arabicFileName,
      };
}

/// Typography configuration: font family, dynamic type, sizes and
/// (optional) localization overrides.
class EnrollTypography {
  /// Custom font identifier. iOS expects the registered PostScript/family
  /// name. Android expects a `res/font` resource name without extension.
  /// When `null`, the native SDK default font is used.
  final String? fontFamily;

  /// Whether the SDK should scale fonts using the platform font scale.
  /// Defaults to `true`.
  final bool dynamicTypeEnabled;

  /// Font-size preset. Defaults to [EnrollFontSizes.defaultSize].
  final EnrollFontSizes sizes;

  /// Optional JSON-file based localization overrides.
  final EnrollLocalizationOverrides? localizationOverrides;

  const EnrollTypography({
    this.fontFamily,
    this.dynamicTypeEnabled = true,
    this.sizes = EnrollFontSizes.defaultSize,
    this.localizationOverrides,
  });

  Map<String, dynamic> toJson() => {
        if (fontFamily != null) 'fontFamily': fontFamily,
        'dynamicTypeEnabled': dynamicTypeEnabled,
        'sizes': sizes.toJson(),
        if (localizationOverrides != null)
          'localizationOverrides': localizationOverrides!.toJson(),
      };
}
