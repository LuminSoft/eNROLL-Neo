
# eNROLL Neo

`eNROLL Neo` is a lightweight compliance solution that prevents identity fraud and phishing. Powered by AI, it reduces errors and speeds up identification, ensuring secure verification.

This is the **lightweight version** of the eNROLL SDK, optimized for faster integration and smaller app size.

---

# REQUIREMENTS

## Android

* Minimum Flutter version 3.3.4
* Android `minSdkVersion` 24
* Kotlin Version 2.1.0

## iOS

* iOS Deployment Target 15.5+

---

# 2. INSTALLATION

## 1- Install the package

Run this command with Flutter:

```bash
flutter pub add enroll_neo_plugin
```

This will add a line like this to your package's `pubspec.yaml`:

```yaml
dependencies:
  enroll_neo_plugin: ^latest_version
```

You can find the latest version here:

[https://pub.dev/packages/enroll_neo_plugin/versions](https://pub.dev/packages/enroll_neo_plugin/versions)

---

# 2.1. Android Setup

## Step 1: Update minSdkVersion

Upgrade `minSdkVersion` to **24** in `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 24
    }
}
```

## Step 2: Add Maven Repositories

Add JitPack repository to your project-level `android/build.gradle`:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```

If your project uses the newer Gradle structure, add it to `android/settings.gradle` instead:

```gradle
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```

## Step 3: (Optional) Add R8 Optimization

Add the following to `android/settings.gradle` for better code optimization:

```gradle
buildscript {
    repositories {
        mavenCentral()
        maven {
            url = uri("https://storage.googleapis.com/r8-releases/raw")
        }
    }
    dependencies {
        classpath("com.android.tools:r8:8.2.24")
    }
}
```

---

# 2.2. iOS Setup

## Step 1: Update Info.plist

Add the following permissions to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to capture your ID and face for verification</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location for security compliance</string>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Step 2: Add Pod Sources

Add these sources to your `ios/Podfile` (before `platform :ios`):

```ruby
source 'https://github.com/LuminSoft/eNROLL-Neo-Core-specs.git'
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/AndyQ/NFCPassportReader.git'
```

## Step 3: Update Deployment Target

Ensure iOS deployment target is at least `15.5` in your `ios/Podfile`:

```ruby
platform :ios, '15.5'
```

---

# 2.3. Final Setup Steps

## Step 1: Get Dependencies

```bash
flutter pub get
```

## Step 2: Install iOS Pods

```bash
cd ios && pod install && cd ..
```

## Step 3: Clean Build (If Needed)

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

If you are upgrading from an older Android SDK/plugin version and Gradle still resolves stale dependencies, refresh Android dependencies as well:

```bash
cd android
./gradlew --refresh-dependencies
cd ..
```

---

# 3. ELECTRONIC PASSPORT (ePassport) CONFIGURATION

If you want to use **NFC reading for electronic passports**, follow these additional steps:

---

# 3.1. Android - ePassport Setup

The eNROLL Neo Android SDK already includes NFC support.

No additional configuration is needed for Android.

---

# 3.2. iOS - ePassport Setup

## Step 1: Add NFC Capabilities to Info.plist

Add the following NFC configuration to your `ios/Runner/Info.plist`:

```xml
<key>com.apple.developer.nfc.readersession.felica.systemcodes</key>
<array>
    <string>A0000002471001</string>
</array>

<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>A0000002471001</string>
</array>

<key>NFCReaderUsageDescription</key>
<string>We need NFC access to read your electronic passport</string>
```

## Step 2: Enable NFC Capability in Xcode

1. Open your iOS project in Xcode (`ios/Runner.xcworkspace`)
2. Select your target → **Signing & Capabilities**
3. Click **+ Capability**
4. Add:

```text
Near Field Communication Tag Reading
```

> NFC reading requires a physical iOS device and will not work on simulators.

---

# ⚠️ Important Notes

* No `MainActivity` changes are needed.
* The plugin handles Android namespace conflicts internally.
* Android `minSdkVersion 24` is required.
* JitPack repository must be added to resolve Android dependencies.
* ePassport/NFC support is optional.

---

# 4. USAGE

Create a widget and return `EnrollNeoPlugin` inside the build function:

```dart
return EnrollNeoPlugin(
  mainScreenContext: context,
  tenantId: 'TENANT_ID',
  tenantSecret: 'TENANT_SECRET',
  enrollMode: EnrollMode.onboarding,
  enrollEnvironment: EnrollEnvironment.staging,
  localizationCode: EnrollLocalizations.en,
  onSuccess: (applicantId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("success: $applicantId");
    });
  },
  onError: (error) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("Error: ${error.toString()}");
    });
  },
  onGettingRequestId: (requestId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("requestId:: $requestId");
    });
  },
  applicationId: 'APPLICATION_ID',
  levelOfTrust: 'LEVEL_OF_TRUST_TOKEN',
  googleApiKey: 'GOOGLE_API_KEY',
  correlationId: 'correlationId',
  requestId: 'requestId',
  skipTutorial: false,
  enrollColors: EnrollColors(
    primary: DynamicColor(r: 0, g: 0, b: 0, opacity: 1.0),
    secondary: DynamicColor(r: 255, g: 255, b: 255, opacity: 1.0),
  ),
  enrollForcedDocumentType:
      EnrollForcedDocumentType.nationalIdOrPassport,
  templateId: 'templateId',
  contractParameters: 'contractParameters',
  enrollExitStep: EnrollStepType.phoneOtp,
);
```

---

# 4.1. Icon Customization

You can fully replace the SDK's default logo, step illustrations, popup glyphs, field icons, and UI icons by passing an `EnrollTheme` to `EnrollNeoPlugin`.

The `EnrollTheme` parameter takes priority over `enrollColors`.

If you only need to customize colors, you can continue using `enrollColors`.

---

# 4.1.1. Android Icon Customization

## Step 1: Add your custom drawables

Place your PNG/XML drawables inside:

```text
android/app/src/main/res/drawable/
```

Example:

```text
example/android/app/src/main/res/drawable/my_logo.png
example/android/app/src/main/res/drawable/my_location_icon.xml
```

Reference them by name (without extension) using `EnrollStepIcon.assetName`.

## Step 2: Build an EnrollTheme

```dart
final EnrollTheme myTheme = EnrollTheme(
  colors: EnrollColors(
    primary: const Color(0xFF1D56B8),
    secondary: const Color(0xFF5791DB),
  ),
  icons: const EnrollIcons(
    logo: EnrollLogoConfig(
      mode: EnrollLogoMode.custom,
      assetName: 'my_logo',
      renderingMode: EnrollIconRenderingMode.original,
    ),
    location: EnrollLocationIcons(
      tutorial: EnrollStepIcon(assetName: 'my_location_icon'),
    ),
    common: EnrollCommonIcons(
      termsAndConditions: EnrollStepIcon(assetName: 'my_terms_icon'),
      popups: EnrollPopupIcons(
        successIcon: EnrollStepIcon(assetName: 'my_success_icon'),
      ),
    ),
  ),
);
```

## Step 3: Pass it to the plugin

```dart
EnrollNeoPlugin(
  // ...other parameters...
  enrollTheme: myTheme,
);
```

---

# 4.1.2. iOS Icon Customization

You can also fully replace the SDK's default logo, step illustrations, popup glyphs, field icons, and UI icons on iOS using the same `EnrollTheme` API.

## Step 1: Add your custom assets to iOS

1. Open your iOS project:

```text
ios/Runner.xcworkspace
```

2. Navigate to:

```text
Runner → Assets.xcassets
```

3. Add your image assets (PNG/SVG supported).

4. Make sure:

* The asset is included in the `Runner` target.
* The asset name exactly matches the value passed in `assetName`.
* The asset is configured correctly for all required scales (`1x`, `2x`, `3x`) if using PNG files.

Example:

```text
ios/Runner/Assets.xcassets/my_logo.imageset
ios/Runner/Assets.xcassets/my_location_icon.imageset
```

After adding the assets, they are immediately ready to use inside the SDK theme configuration.

## Step 2: Build an EnrollTheme

```dart
final EnrollTheme myTheme = EnrollTheme(
  colors: EnrollColors(
    primary: const Color(0xFF1D56B8),
    secondary: const Color(0xFF5791DB),
  ),
  icons: const EnrollIcons(
    logo: EnrollLogoConfig(
      mode: EnrollLogoMode.custom,
      assetName: 'my_logo',
      renderingMode: EnrollIconRenderingMode.original,
    ),
    location: EnrollLocationIcons(
      tutorial: EnrollStepIcon(assetName: 'my_location_icon'),
    ),
    common: EnrollCommonIcons(
      termsAndConditions: EnrollStepIcon(assetName: 'my_terms_icon'),
      popups: EnrollPopupIcons(
        successIcon: EnrollStepIcon(assetName: 'my_success_icon'),
      ),
    ),
  ),
);
```

## Step 3: Pass it to the plugin

```dart
EnrollNeoPlugin(
  // ...other parameters...
  enrollTheme: myTheme,
);
```

## Rendering modes

`EnrollIconRenderingMode.original`

* Keeps original asset colors.
* Recommended for logos and colorful illustrations.

`EnrollIconRenderingMode.template`

* Applies SDK tint color to the asset.
* Recommended for monochrome icons.

## Important Notes for iOS

* Asset names are case-sensitive.
* SVG assets are not supported directly in `Assets.xcassets`.
* PDF vector assets are recommended.
* If an asset cannot be resolved, the SDK automatically falls back to the default built-in asset.
* `EnrollTheme` takes priority over `enrollColors`.

---

# Available icon groups

| Group                       | Icons                                                                                                                                              |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| `logo`                      | Splash and app-bar logo (`EnrollLogoConfig`)                                                                                                       |
| `location`                  | `tutorial`, `requestAccess`, `accessError`, `grab`                                                                                                 |
| `nationalId`                | `tutorial`, `tutorialIdOrPassport`, `preScan`, `scanError`, `choose`                                                                               |
| `passport`                  | `tutorial`, `preScan`, `ePassportPreScan`, `choose`                                                                                                |
| `phone`                     | `tutorial`, `select`, `validateOtp`                                                                                                                |
| `email`                     | `tutorial`, `select`, `validateOtp`                                                                                                                |
| `faceMatching`              | `tutorial`, `preScan`, `error`                                                                                                                     |
| `securityQuestions`         | `tutorial`, `authScreen`                                                                                                                           |
| `password`                  | `tutorial`, `authScreen`                                                                                                                           |
| `signature`                 | `tutorial`                                                                                                                                         |
| `common.backgrounds`        | `main`, `layer1`, `layer2`, `layer3`, `blur`, `header`, `footer`                                                                                   |
| `common.popups`             | `background`, `warningIcon`, `errorIcon`, `successIcon`                                                                                            |
| `common.fieldIcons`         | `user`, `calendar`, `gender`, `issuingAuthority`, `nationality`, `num`, `passport`, `address`, `idCard`, `profession`, `religion`, `maritalStatus` |
| `common.ui`                 | `visibility`, `visibilityOff`, `mobile`, `mail`, `answer`, `error`, `info`, `edit`, `activePhone`                                                  |
| `common.termsAndConditions` | Single icon                                                                                                                                        |
| `update`                    | `modeIcon`, `idCard`, `passport`, `mobile`, `email`, `device`, `address`, `securityQuestions`, `password`                                          |
| `forget`                    | `modeIcon`, `nationalId`, `passport`, `phone`, `email`, `device`, `location`, `securityQuestions`, `password`                                      |

If a drawable or asset cannot be resolved at runtime, the SDK logs a warning and falls back to its built-in asset automatically.

---

# 5. ENROLL MODES

```dart
enum EnrollMode {
  onboarding,
  auth,
  update,
  signContract
}
```

| Mode           | Description                | Requirements                                                   |
| -------------- | -------------------------- | -------------------------------------------------------------- |
| `onboarding`   | Registering a new user     | `tenantId`, `tenantSecret`                                     |
| `auth`         | Verifying an existing user | `tenantId`, `tenantSecret`, `applicantId`, `levelOfTrustToken` |
| `update`       | Updating user verification | `tenantId`, `tenantSecret`, `applicantId`                      |
| `signContract` | Contract signing           | `tenantId`, `tenantSecret`, `templateId`                       |

---

# 6. VALUES DESCRIPTION

| Key                        | Description                  |
| -------------------------- | ---------------------------- |
| `tenantId`                 | Required tenant ID           |
| `tenantSecret`             | Required tenant secret       |
| `enrollMode`               | SDK mode                     |
| `environment`              | Staging or production        |
| `enrollCallback`           | Success/error callback       |
| `localizationCode`         | EN or AR                     |
| `googleApiKey`             | Google Maps API key          |
| `applicantId`              | Applicant ID                 |
| `levelOfTrustToken`        | Level of trust token         |
| `skipTutorial`             | Skip tutorial screens        |
| `appColors`                | Override SDK colors          |
| `enrollTheme`              | Unified theme customization  |
| `correlationId`            | Correlation ID               |
| `templateId`               | Contract template ID         |
| `contractParameters`       | Contract parameters          |
| `enrollForcedDocumentType` | Force specific document type |
| `requestId`                | Continue previous request    |
| `enrollExitStep`           | Exit SDK after specific step |

---

# 7. ENROLL STEP TYPES

```dart
enum EnrollStepType {
  phoneOtp,
  personalConfirmation,
  smileLiveness,
  emailOtp,
  saveMobileDevice,
  deviceLocation,
  password,
  securityQuestions,
  amlCheck,
  termsAndConditions,
  electronicSignature,
  ntraCheck,
  csoCheck,
}
```

---

# 8. SECURITY NOTES

* Never hardcode `tenantSecret`, `levelOfTrustToken`, or API keys inside the application.
* Use secure storage such as Android Keystore or iOS Keychain.
* Always update the SDK to the latest stable version.
* Rooted devices are blocked by default for security reasons.
