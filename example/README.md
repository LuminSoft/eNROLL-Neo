# enroll_neo_plugin_example

Demonstrates how to use the enroll_plugin plugin.



## Custom typography & localization

The example wires `EnrollTypography` through `EnrollTheme` (see
`lib/main.dart`). The example also includes full Android-native English and
Arabic localization override files so integrators can see every editable key:

```text
android/app/src/main/assets/enroll_localizations_en.json
android/app/src/main/assets/enroll_localizations_ar.json
```

Keep the keys unchanged and edit the values you want to override.

The files use this shape:

```json
{
  "localizationOverrides": {
    "en": {
      "skip": "Skip",
      "continue_to_next": "Continue"
    }
  }
}
```

For Arabic, use `ar` instead of `en`.

Android loads the JSON files from `android/app/src/main/assets` by file name.
The example references them from `EnrollLocalizationOverrides` without the
`.json` extension:

```dart
typography: const EnrollTypography(
  localizationOverrides: EnrollLocalizationOverrides(
    englishFileName: 'enroll_localizations_en',
    arabicFileName: 'enroll_localizations_ar',
  ),
),
```

Some protected native keys, such as vendor capture instructions, NFC keys,
sample keys, and `app_name`, are included for reference but are not applied as
Android overrides.

To make the demo render with a real custom font and override the SDK's
localized strings on iOS, the host app must:

1. Drop a `.ttf`/`.otf` file (e.g. `Farah.ttf`) into `ios/Runner/Fonts/`
   (create the folder if needed).
2. In Xcode, add the font file to the **Runner** target's **Build
   Phases → Copy Bundle Resources**.
3. Add a `UIAppFonts` array entry to `ios/Runner/Info.plist` that lists
   the font filename, e.g.:

   ```xml
   <key>UIAppFonts</key>
   <array>
       <string>Farah.ttf</string>
   </array>
   ```

4. Add `enroll_localizations_en.json` and `enroll_localizations_ar.json`
   (already provided under `ios/Runner/`) to **Copy Bundle Resources** so
   `Bundle.main` can resolve them at runtime.

The iOS reference files are:

```text
ios/Runner/enroll_localizations_en.json
ios/Runner/enroll_localizations_ar.json
```

They are intentionally left as iOS-side references; the iOS native
implementation owner should update their contents when needed.

Each JSON file may use a flat `{ "key": "value" }` map or the nested
`{ "localizationOverrides": { "en": { ... }, "ar": { ... } } }` shape.

On Android, add custom font resources under `android/app/src/main/res/font`.
