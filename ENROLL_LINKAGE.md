# enroll_neo_plugin — Linkage & Sync Guide

## What This Repo Is

**Flutter plugin** for the **enroll-neo** product line. Wraps the eNROLL Lite Android SDK (without Innovatrics, uses own OCR) for Flutter apps.

## Product Line

**enroll-neo** — lightweight eKYC without Innovatrics dependency.

## Native SDK Dependency

| Field | Value |
|---|---|
| Branch | `development-lumin-sdk` |
| Artifact | `com.github.LuminSoft:eNROLL-Lite-Android` |
| Current Version | `v1.3.2` |
| Declared in | `android/build.gradle` |
| iOS Distribution | XCFramework (`ios/Frameworks/EnrollFramework.xcframework`) |
| iOS Core Pod | `EnrollNeoCore 1.0.17` |

## Sibling Projects (same product line)

| Plugin | Path | Type |
|---|---|---|
| enroll-neo-react-native | `/Users/luminsoft/StudioProjects/enroll-neo-react-native` | React Native |
| enroll-capacitor-neo | `/Users/luminsoft/StudioProjects/enroll-capacitor-neo` | Capacitor |

## What This Plugin Exposes

- `EnrollNeoPlugin` widget with `startEnroll` method channel
- Modes: onboarding, auth, update, signContract
- Theming: `EnrollTheme` (colors + icons), `enrollColors` (cross-platform fallback)
- Icon customization with `showSponsoredBy` logo option
- Localization: en, ar
- Options: forcedDocumentType, exitStep, skipTutorial, correlationId, googleApiKey, requestId, contractSigning
- Callbacks: onSuccess, onError, onGettingRequestId

## How to Update When Native SDK Changes

1. Update `android/build.gradle` → change `eNROLL-Lite-Android:vX.Y.Z`
2. Update `pubspec.yaml` → bump plugin version
3. Mirror new parameters/types to Dart API if needed
4. Update `.enroll-linkage.json` with new version
5. Tell Cascade to mirror changes to React Native and Capacitor siblings
6. Run sync check: `bash /Users/luminsoft/StudioProjects/ekyc-android/scripts/check-enroll-sync.sh`

## Where to Update Docs

- `README.md` — installation and usage
- `CHANGELOG.md` — version history
- `HANDOFF_ICON_CUSTOMIZATION.md` — icon customization guide
- `.enroll-linkage.json` — machine-readable metadata

## TODO — Pending Feature Gaps

- [ ] **forgetProfileData mode** — Native SDK supports `FORGET_PROFILE_DATA` but this plugin does not expose it
  - Implementation: `lib/constants/enroll_mode.dart` (add enum value)
  - Android bridge: `android/src/main/kotlin/.../EnrollNeoPlugin.kt`
  - iOS bridge: `ios/Classes/EnrollNeoPlugin.swift`
  - Note: Neo RN/Cap already have this mode in their types but Flutter doesn't yet

## iOS: XCFramework Distribution

- This plugin bundles `EnrollFramework.xcframework` at `ios/Frameworks/`
- When updating the XCFramework, also copy it to sibling Neo plugins:
  - `enroll-neo-react-native/ios/Frameworks/EnrollFramework.xcframework`
  - `enroll-capacitor-neo/ios/Frameworks/EnrollFramework.xcframework`
- Use `/copy-flutter-to-sibling-plugins` to automate this

## Naming Notes

- This plugin uses `enrollColors` / `enrollTheme` for theming
- Enroll (production) Flutter uses `appColors` (deprecated naming)
- Do NOT rename across product lines
