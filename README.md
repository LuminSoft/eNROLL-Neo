# eNROLL

Our in-house developed eNROLL platform serves as a technological compliance solution. A solution
that is now familiarized across the globe in countries with big populations, where falsification of
identity, signatures, and phishing is very common.

The software utilizes a set of AI-powered technologies, like the OCR (Optical Character
Recognition), to cut back on the risks of human-based errors and the time needed for identification.

![App Screenshot](https://firebasestorage.googleapis.com/v0/b/excel-hr-app.appspot.com/o/Screenshot%202024-09-02%20at%2011.03.04%E2%80%AFAM.png?alt=media&token=37acf293-9e0e-456c-8b7a-3b97c512d911)

![App Screenshot](https://firebasestorage.googleapis.com/v0/b/excel-hr-app.appspot.com/o/Screenshot%202024-09-02%20at%2011.03.28%E2%80%AFAM.png?alt=media&token=1d5aafeb-ffe3-4faa-aa72-37b28f1810a9)

![App Screenshot](https://firebasestorage.googleapis.com/v0/b/excel-hr-app.appspot.com/o/Screenshot%202024-09-02%20at%2011.03.39%E2%80%AFAM.png?alt=media&token=76489515-b21b-403f-a338-0f9889486b4b)

## REQUIREMENTS

- Minimum Flutter version 3.3.4
- Android minSdkVersion 24
- Kotlin Version 2.1.0
- iOS Deployment Target 13.0+

## 2. INSTALLATION

1- Run this command with Flutter:

```bash
$ flutter pub add enroll_plugin
```

This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):

```bash
dependencies:
  enroll_plugin: ^latest_version
```

- You can find the latest version here https://pub.dev/packages/enroll_plugin/versions

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

- Add these two sources to the iOS project Podfile

```bash
source 'https://github.com/innovatrics/innovatrics-podspecs'
source 'https://github.com/LuminSoft/eNROLL-iOS-specs'
source 'https://github.com/CocoaPods/Specs.git'
```

### 2.3. Add a license file to your project:

- For Android

![App Screenshot](https://firebasestorage.googleapis.com/v0/b/excel-hr-app.appspot.com/o/lic_android.png?alt=media&token=9a6556c1-cea1-4fce-b073-0dba76bedf8f)

- For iOS

![App Screenshot](https://firebasestorage.googleapis.com/v0/b/excel-hr-app.appspot.com/o/lic_ios.webp?alt=media&token=c4bcf3d8-d9d2-4c99-9a62-97349ff30fac)

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
import 'package:enroll_plugin/enroll_plugin.dart';
```

## 4. USAGE

- Create a widget and just return the EnrollPlugin widget in the build function as:

```dart
return EnrollPlugin(
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
    levelOfTrustToken: 'LEVEL_OF_TRUST_TOKEN',
    googleApiKey: 'GOOGLE_API_KEY',
    correlationId: 'correlationId',
    requestId: 'requestId',
    skipTutorial: false,
    appColors: AppColors(
      primary: "#000000",
      secondary: "#FFFFFF",
      background: "#F8F8F8",
      successColor: "#4CAF50",
      warningColor: "#FFC107",
      errorColor: "#F44336",
      textColor: "#212121",
    ),
    enrollForcedDocumentType: EnrollForcedDocumentType.nationalIdOrPassport,
    templateId: 'templateId',
    contractParameters: 'contractParameters',
    exitStep:EnrollStepType.phoneOtp
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
