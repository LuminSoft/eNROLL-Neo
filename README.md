# eNROLL Neo

eNROLL Neo is a lightweight compliance solution that prevents identity fraud and phishing. Powered by AI, it reduces errors and speeds up identification, ensuring secure verification.

This is the **lightweight version** of the eNROLL SDK, optimized for faster integration and smaller app size.

## REQUIREMENTS

- Minimum Flutter version 3.3.4
- Android minSdkVersion 24
- Kotlin Version 2.1.0
- iOS Deployment Target 13.0+

## 2. INSTALLATION

1- Run this command with Flutter:

```bash
$ flutter pub add enroll_neo_plugin
```

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```bash
dependencies:
  enroll_neo_plugin: ^latest_version
```

- You can find the latest version here https://pub.dev/packages/enroll_neo_plugin/versions

### 2.1. Android

- Add these lines to build.gradle file:

```bash
maven { url 'https://jitpack.io' }
maven { url = uri("https://maven.innovatrics.com/releases") }
```

- Upgrade minSdkVersion to 24 in app/build.gradle.
- Add the following lines to settings.gradle file:

```bash
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

### 2.2. iOS

- Add the following to your project info.plist file

```xml
<key>NSCameraUsageDescription</key>
<string>"Your Message to the users"</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>"Your Message to the users"</string>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

- Add these sources to the iOS project Podfile (contact LuminSoft for correct sources)

```bash
source 'https://github.com/CocoaPods/Specs.git'
# Add eNROLL Neo iOS SDK sources here
```

### 2.3. Add a license file to your project:

- For Android: Add `iengine.lic` to `android/app/src/main/res/raw/`

- For iOS: Add `iengine.lic` to the root of your iOS Runner project

ℹ️ Make sure your iOS project has a reference for the license file or instead:

- open iOS project
- Drag and drop the license file to the root folder of the project as described above
- make sure to copy items if needed, check the box is checked
- then done

### 2.4. Run Command line:

```bash
flutter pub get
```

## 3. IMPORT

```dart
import 'package:enroll_neo_plugin/enroll_neo_plugin.dart';
```

## 4. USAGE

- Create a widget and just return the EnrollNeoPlugin widget in the build function as:

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
    enrollForcedDocumentType: EnrollForcedDocumentType.nationalIdOrPassport,
    templateId: 'templateId',
    contractParameters: 'contractParameters',
    enrollExitStep: EnrollStepType.phoneOtp
);
```

## 5. ENROLL MODES

The SDK supports **4 modes** defined in the `EnrollMode` enum:

```dart
enum EnrollMode {
  onboarding,
  auth,
  update,
  signContract
}
```

### Mode Details

| Mode           | Description                                                | Requirements                                                                             |
|----------------|------------------------------------------------------------|------------------------------------------------------------------------------------------|
| `onboarding`   | Registering a new user in the system.                      | `tenantId`, `tenantSecret` (required).                                                   |
| `auth`         | Verifying the identity of an existing user.                | `tenantId`, `tenantSecret`, **`applicantId`**, **`levelOfTrustToken`** (all required).   |
| `update`       | Updating or re-verifying the identity of an existing user. | `tenantId`, `tenantSecret`, `applicantId` (required).                                    |
| `signContract` | Signing contract templates by a user.                      | `tenantId`, `tenantSecret`, **`templateId`** (required). Optional: `contractParameters`. |

## 6. VALUES DESCRIPTION

| Keys.                         | Values                                                                                                                                                        |
|:------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `tenantId`                    | **Required**. Write your organization tenant id.                                                                                                              |
| `tenantSecret`                | **Required**. Write your organization tenant secret.                                                                                                          |
| `enrollMode`                  | **Required**. Mode of the SDK. (See [Enroll Modes](#5-enroll-modes)).                                                                                         |
| `environment`                 | **Required**. Select the EnrollEnvironment: EnrollEnvironment.STAGING  for staging and EnrollEnvironment.PRODUCTION for production.                           |
| `enrollCallback`              | **Required**. Callback function to receive success and error response.                                                                                        |
| `localizationCode`            | **Required**. Select your language code LocalizationCode.EN for English, and LocalizationCode.AR for Arabic. The default value is English.                    |
| `googleApiKey`                | **Optional**. Google Api Key to view the user current location on the map.                                                                                    |
| `applicantId`                 | **Optional**. Write your Application ID (Required for `auth` and recommended for `update`).                                                                   |
| `levelOfTrustToken`           | **Optional**. Write your Organization's level of trust (Required for `auth`).                                                                                 |
| `skipTutorial`                | **Optional**. Choose to ignore the tutorial or not.                                                                                                           |
| `appColors`                   | **Optional**. Collection of the app colors that you could override, like (primary, secondary, background, successColor, warningColor, errorColor, textColor). |
| `correlationId`               | **Optional**. Correlation ID to connect your User ID with our Request ID.                                                                                     |
| `templateId`                  | **Optional**. The ID of the contract to be signed (Required for `signContract`).                                                                              |
| `contractParameters`          | **Optional**. Extra contract parameters for `signContract`.                                                                                                   |
| `enrollForcedDocumentType`    | **Optional**. Enroll forced document type to force the users to use a national ID only or a passport only, or allow choosing one of them.                     |
| `requestId`                   | **Optional**. Write your request ID to allow continuing a previously initiated request (runaway) instead of starting from the beginning.                      |
| `enrollExitStep`              | **Optional**. Enroll Step Type to allows the SDK to automatically close after a specified enrollment step passes successfully.                                |

## 7. ENROLL Step Types

The SDK supports **13 step type** defined in the `EnrollStepType` enum:

```dart
enum EnrollStepType {
  /// One-time password verification sent to the user's phone number.
  /// Used to validate phone ownership.
  phoneOtp,

  /// Confirms the user's personal information (e.g. national ID, passport).
  personalConfirmation,

  /// Performs smile-based liveness detection to ensure the user is physically present step.
  smileLiveness,

  /// One-time password verification sent to the user's email address.
  /// Used to validate email ownership.
  emailOtp,

  /// Registers and saves the current mobile device as a trusted device step.
  saveMobileDevice,

  /// Captures and verifies the user's device location for compliance and security step.
  deviceLocation,

  /// Creates or confirms the user's account password step.
  password,

  /// Verifies answers to predefined security questions for additional authentication step.
  securityQuestions,

  /// Performs Anti-Money Laundering (AML) checks against regulatory databases step.
  amlCheck,

  /// Displays and requires acceptance of the terms and conditions step.
  termsAndConditions,

  /// Captures the user's electronic signature for legal consent step.
  electronicSignature,

  /// Performs NTRA (National Telecom Regulatory Authority) verification step.
  ntraCheck,

  /// Performs CSO (Central Security Office) verification checks step.
  csoCheck,
}
```

## 8. SECURITY NOTES

- Never hardcode `tenantSecret`, `levelOfTrustToken`, or API keys inside the mobile application. Use a secure storage mechanism (e.g., Keychain on iOS, Keystore on Android).
- Regularly update the SDK to the latest stable version for security patches.
- Rooted devices are blocked by default for security reasons.
