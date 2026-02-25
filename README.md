# eNROLL Neo

eNROLL Neo is a lightweight compliance solution that prevents identity fraud and phishing. Powered by AI, it reduces errors and speeds up identification, ensuring secure verification.

This is the **lightweight version** of the eNROLL SDK, optimized for faster integration and smaller app size.

## REQUIREMENTS
android
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

### 2.1. Android Setup

#### Step 1: Update minSdkVersion
Upgrade `minSdkVersion` to **24** in `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 24  // Update this line
    }
}
```

#### Step 2: Add Maven Repositories
Add JitPack repository to your **project-level** `android/build.gradle`:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }  // Add this line
    }
}
```

**Note**: If your project uses the newer Gradle structure, add it to `android/settings.gradle` instead:

```gradle
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }  // Add this line
    }
}
```

#### Step 3: (Optional) Add R8 Optimization
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

### 2.2. iOS Setup

#### Step 1: Update Info.plist
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

#### Step 2: Add Pod Sources
Add these sources to your `ios/Podfile` (at the top, before `platform :ios`):

```ruby
source 'https://github.com/LuminSoft/eNROLL-Neo-iOS-specs.git'
source 'https://github.com/LuminSoft/eNROLL-Neo-Core-specs.git'
source 'https://github.com/CocoaPods/Specs.git'
```

#### Step 3: Update Deployment Target
Ensure iOS deployment target is at least 13.0 in your `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

### 2.3. Final Setup Steps

#### Step 1: Get Dependencies
Run the following command in your project root:

```bash
flutter pub get
```

#### Step 2: Install iOS Pods
Navigate to the iOS directory and install pods:

```bash
cd ios && pod install && cd ..
```

#### Step 3: Clean Build (if needed)
If you encounter any build issues, run:

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

---

## ⚠️ Important Notes

- **No MainActivity changes needed**: Users do NOT need to modify their MainActivity file. The plugin handles everything automatically.
- **No namespace conflicts**: The plugin uses its own namespace internally, no user action required.
- **Android minSdk 24**: This is the only critical requirement for Android users.
- **JitPack repository**: Must be added to use the eNROLL-Lite Android SDK.

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
