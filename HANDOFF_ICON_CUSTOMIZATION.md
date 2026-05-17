# Handoff: Port Icon Customization from `enroll_flutter_plugin` → `enroll_neo_plugin`

> **Created:** 2026-05-13
> **Last updated:** 2026-05-13 (Phase 0 ✅ done — Lite SDK v1.3.0 published)
> **Audience:** Next chat session that will execute the plugin implementation
> **Reference branch:** `release/production` of `enroll_flutter_plugin`
> **Target:** `enroll_neo_plugin` (master)

---

## 1. Goal

Bring the **icon customization** capability from `enroll_flutter_plugin` (which already has it on `release/production`) into `enroll_neo_plugin` so consumers can pass a unified `EnrollTheme(colors, icons)` object containing logo + step illustrations + popup/field/UI icons.

The end-state public API on Neo should match the Flutter plugin one-to-one:

```dart
EnrollNeoPlugin(
  // ...existing...
  enrollTheme: EnrollTheme(
    colors: EnrollColors(primary: Color(0xFF756C10)),
    icons: EnrollIcons(
      logo: EnrollLogoConfig(mode: EnrollLogoMode.custom, assetName: 'my_logo'),
      location: EnrollLocationIcons(tutorial: EnrollStepIcon(assetName: 'my_loc')),
      // ... etc
    ),
  ),
)
```

---

## 2. Blocker Status — RESOLVED ✅

> **Lite SDK v1.3.0 published with full icon-customization API.**

### What was shipped

- **Source repo (private):** Azure DevOps `ekyc-android` repo, branch `icon-customization-luminlight-sdk`, commit `b22de95e` titled *"Release v1.3.0 - Icon customization (BC, additive)"*.
- **Release repo (public):** `LuminSoft/eNROLL-Lite-Android`, branch `enroll-lite-master`, commit `8ea48c8`, tag `v1.3.0`.
- **Artifacts:** `eNROLL-sdk-1.3.0.aar` (6.2 MB) + `pom-1.3.0.xml` (8.9 KB), prepared on Desktop and pushed to the GitHub release repo.
- **Distribution:** JitPack will publish at `com.github.LuminSoft:eNROLL-Lite-Android:1.3.0` once the GitHub Release is created and JitPack runs.

### Pending USER action (one-time, web UI)

1. Open <https://github.com/LuminSoft/eNROLL-Lite-Android/releases/new>.
2. Select tag `v1.3.0` (already pushed).
3. Title: `Release v1.3.0 - Icon customization`.
4. Description: paste the `[1.3.0]` section from `@/Users/luminsoft/StudioProjects/ekyc-android/CHANGELOG.md`.
5. Attach files from `~/Desktop/`:
   - `eNROLL-sdk-1.3.0.aar`
   - `pom-1.3.0.xml`
6. Click **Publish release**.
7. Verify at <https://jitpack.io/#LuminSoft/eNROLL-Lite-Android/1.3.0> — wait for the green **"Get it"** badge (2–5 minutes).

### What the new SDK version exposes

Verified inside `eNROLL-sdk-1.3.0.aar` → `classes.jar`:

```
AppTheme, AppIcons, StepIcon, IconSource (+IconSource$Resource),
LogoConfig, LogoMode, IconRenderingMode, IconResolverKt,
LocationIcons, NationalIdIcons, PassportIcons, PhoneIcons, EmailIcons,
FaceMatchingIcons, SecurityQuestionsIcons, PasswordIcons, SignatureIcons,
CommonIcons, BackgroundIcons, PopupIcons, FieldIcons, UiIcons,
UpdateIcons, ForgetIcons
```

All the public API classes that `enroll_flutter_plugin`'s Android Kotlin bridge imports are present. The Neo plugin Android port can compile against `eNROLL-Lite-Android:v1.3.0` without any further SDK work.

### Reference for the SDK port itself

`@/Users/luminsoft/StudioProjects/ekyc-android/ICON_CUSTOMIZATION.md` (561 lines) — full architecture, slot map, rendering modes, migration guidance. Read this before doing any plugin-side work.

---

## 3. Reference Audit — What `enroll_flutter_plugin` Has

### 3.1 Files only present in `enroll_flutter_plugin`

```text
lib/constants/enroll_theme.dart      (1714 bytes — wraps EnrollColors + EnrollIcons)
lib/constants/enroll_icons.dart      (17322 bytes — full icon class hierarchy)
```

### 3.2 Files modified relative to current Neo state

| File | What changed in flutter_plugin |
|---|---|
| `lib/enroll_plugin.dart` | Added `enrollTheme` field + `enrollTheme`-priority resolution; kept `appColors` for backward compat |
| `lib/constants/enroll_init_model.dart` | Replaced `colors` field with `theme: EnrollTheme?`; emits `theme` AND root-level `colors` (for iOS BC) |
| `android/src/main/kotlin/com/example/enroll_plugin/EnrollPlugin.kt` | Added `parseAppIcons` + 14 sub-parsers; uses `eNROLL.init(..., appTheme = AppTheme(colors, icons))` instead of `appColors = ...` |
| `android/build.gradle` | Bumped to `eNROLL-Android:v1.5.24`, added bouncycastle excludes/replacements, added `androidx.compose.ui:ui-graphics` |
| `ios/Classes/EnrollPlugin.swift` | **Unchanged behavior** — iOS still reads colors at root (Dart emits both `theme.colors` and root `colors`) |
| `example/lib/main.dart` | Added `_exampleTheme` showing how to pass `EnrollTheme` |

### 3.3 The 14 icon parsers in `EnrollPlugin.kt`

Each top-level group is a JSON object → Kotlin data class:

```text
parseAppIcons        → AppIcons
  parseLogoConfig    → LogoConfig
  parseLocationIcons → LocationIcons         (tutorial, requestAccess, accessError, grab)
  parseNationalIdIcons → NationalIdIcons     (tutorial, tutorialIdOrPassport, preScan, scanError, choose)
  parsePassportIcons → PassportIcons         (tutorial, preScan, ePassportPreScan, choose)
  parsePhoneIcons    → PhoneIcons            (tutorial, select, validateOtp)
  parseEmailIcons    → EmailIcons            (tutorial, select, validateOtp)
  parseFaceMatchingIcons → FaceMatchingIcons (tutorial, preScan, error)
  parseSecurityQuestionsIcons → SecurityQuestionsIcons (tutorial, authScreen)
  parsePasswordIcons → PasswordIcons         (tutorial, authScreen)
  parseSignatureIcons → SignatureIcons       (tutorial)
  parseCommonIcons   → CommonIcons
    parseBackgroundIcons → BackgroundIcons   (main, layer1, layer2, layer3, blur, header, footer)
    parsePopupIcons      → PopupIcons        (background, warningIcon, errorIcon, successIcon)
    parseFieldIcons      → FieldIcons        (user, calendar, gender, issuingAuthority, nationality, num, passport, address, idCard, profession, religion, maritalStatus)
    parseUiIcons         → UiIcons           (visibility, visibilityOff, mobile, mail, answer, error, info, edit, activePhone)
    + termsAndConditions: StepIcon
  parseUpdateIcons   → UpdateIcons           (modeIcon, idCard, passport, mobile, email, device, address, securityQuestions, password)
  parseForgetIcons   → ForgetIcons           (modeIcon, nationalId, passport, phone, email, device, location, securityQuestions, password)
```

The drawable name → resource ID resolver:

```kotlin
private fun resolveDrawableName(name: String): Int =
    context.resources.getIdentifier(name, "drawable", context.packageName)
```

### 3.4 Dart-side JSON contract sent over MethodChannel

Top-level keys produced by `EnrollInitModel.toJson()` when `theme != null`:

```json
{
  "tenantId": "...", "tenantSecret": "...", "...": "...",
  "theme":  { "colors": { ... }, "icons": { "logo": {...}, "location": {...}, ... } },
  "colors": { ... }                        // duplicated at root for iOS BC
}
```

Android plugin reads `jsonObject.get("theme")` first, then falls back to root `colors`.

iOS plugin reads only root `colors` (unchanged).

---

## 4. Implementation Plan

### Phase 0 — Lite SDK (`eNROLL-Lite-Android`) ✅ DONE

Lite SDK v1.3.0 was released on 2026-05-13. See **Section 2** for what was shipped and the one remaining manual GitHub Release step.

**Summary of work that was done:**

- Bumped `eNROLL-sdk/build.gradle` `version` from `1.2.6` → `1.3.0`.
- Bumped `BuildInfo.SDK_VERSION` from `"1.2.6"` → `"1.3.0"`.
- Bumped sample app `versionCode` 152→153, `versionName` 1.1.52→1.1.53.
- Added `CHANGELOG.md` `[1.3.0]` entry.
- Committed all icon-customization work to Azure (`icon-customization-luminlight-sdk` branch).
- Ran `./scripts/release.sh 1.3.0` which:
  - Built `eNROLL-sdk-1.3.0.aar` + `pom-1.3.0.xml`.
  - Cloned the GitHub release repo, refreshed `jitpack.yml`, pushed to `enroll-lite-master`.
  - Created and pushed tag `v1.3.0`.
  - Copied the artifacts to `~/Desktop/` for the GitHub Release upload.
- Verified `classes.jar` exposes all 25+ icon-customization public types.

### Phase 1 — Neo plugin Android (Kotlin)

1. Bump `android/build.gradle` SDK dep:
   ```groovy
   implementation 'com.github.LuminSoft:eNROLL-Lite-Android:v1.3.0'
   ```
   (verify JitPack has built v1.3.0 first — green "Get it" badge at <https://jitpack.io/#LuminSoft/eNROLL-Lite-Android/1.3.0>)
2. Replace `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/android/src/main/kotlin/com/example/enroll_neo_plugin/EnrollNeoPlugin.kt` with a port of `@/Users/luminsoft/StudioProjects/enroll_flutter_plugin/android/src/main/kotlin/com/example/enroll_plugin/EnrollPlugin.kt`. Specifically:
   - Add imports for `AppTheme`, `AppIcons`, and all 14 icon classes.
   - Add private helpers: `resolveDrawableName`, `parseStepIcon`, `parseLogoConfig`, `parseAppIcons`, `parseLocationIcons`, `parseNationalIdIcons`, `parsePassportIcons`, `parsePhoneIcons`, `parseEmailIcons`, `parseFaceMatchingIcons`, `parseSecurityQuestionsIcons`, `parsePasswordIcons`, `parseSignatureIcons`, `parseCommonIcons`, `parseBackgroundIcons`, `parsePopupIcons`, `parseFieldIcons`, `parseUiIcons`, `parseUpdateIcons`, `parseForgetIcons`.
   - In `handleStartEnroll`:
     - Read `theme` JSON object first; fall back to root-level `colors`/`icons` for backward compat.
     - Build `AppColors` (existing) AND `AppIcons` (new).
     - Build `AppTheme(colors = appColors, icons = appIcons)`.
     - Call `eNROLL.init(..., appTheme = appTheme, ...)` instead of `..., appColors = appColors, ...`.
   - Keep all logging tags as `EnrollNeoPlugin` (not `EnrollPlugin`).
3. Confirm `eNROLL.init` signature on the new Lite SDK accepts `appTheme: AppTheme`.

### Phase 2 — Neo plugin Dart

1. **Create** `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/lib/constants/enroll_icons.dart` — copy verbatim from `@/Users/luminsoft/StudioProjects/enroll_flutter_plugin/lib/constants/enroll_icons.dart`. No package-name changes needed (Dart imports are absolute via `package:`).
2. **Create** `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/lib/constants/enroll_theme.dart` — copy from flutter_plugin and update import paths from `package:enroll_plugin/...` to `package:enroll_neo_plugin/...`.
3. **Modify** `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/lib/constants/enroll_init_model.dart`:
   - Add `import 'package:enroll_neo_plugin/constants/enroll_theme.dart';`
   - Add field `EnrollTheme? theme;`
   - **Keep** existing `EnrollColors? colors;` field for backward compat (or replace if breaking is acceptable — flutter_plugin replaced it).
   - In `toJson()`:
     - If `theme != null`, emit `data['theme'] = theme!.toJson();`
     - **Always** also emit `data['colors'] = theme?.colors?.toJson() ?? colors?.toJson();` for iOS BC.
4. **Modify** `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/lib/enroll_neo_plugin.dart`:
   - Add field `final EnrollTheme? enrollTheme;`
   - Constructor parameter `this.enrollTheme,`
   - In `initState()`, resolve theme:
     ```dart
     final resolvedTheme = widget.enrollTheme
         ?? (widget.enrollColors != null
             ? EnrollTheme(colors: widget.enrollColors)
             : null);
     ```
   - Pass `theme: resolvedTheme` to `EnrollInitModel(...)`.
   - Add `export 'package:enroll_neo_plugin/constants/enroll_theme.dart';` and `export 'package:enroll_neo_plugin/constants/enroll_icons.dart';` at the top.
5. Verify deprecation messaging is consistent with what the Neo team wants for `enrollColors`.

### Phase 3 — iOS (Swift)

**No code changes required.** iOS will continue to receive root-level `colors` from Dart's `toJson()`, so existing color customization keeps working on iOS. Icons remain Android-only (matches flutter_plugin behavior).

Optionally add a docstring to `EnrollNeoPlugin.swift` clarifying that icon customization is Android-only.

### Phase 4 — Example app & docs

1. Update `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/example/lib/main.dart` mirroring `@/Users/luminsoft/StudioProjects/enroll_flutter_plugin/example/lib/main.dart` — add `_exampleTheme` snippet (commented out by default).
2. Add a sample drawable (e.g. `sample_location_icon.xml`) to `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/example/android/app/src/main/res/drawable/`.
3. Update `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/README.md` with an `Icon Customization` section.
4. Update `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/CHANGELOG.md` with a new version entry.

### Phase 5 — Versioning & verify

1. Bump `pubspec.yaml` `version:` from `1.1.2` → `1.2.0` (minor — additive feature).
2. Run `flutter pub get` in plugin root and example.
3. From `example/`, `flutter run` and verify default colors still work (no `enrollTheme` passed).
4. Add `enrollTheme: _exampleTheme` and verify the sample drawable appears on tutorial screens, popup, terms screen, etc.
5. iOS: build and confirm color customization still works.

---

## 5. File-by-File Diff Summary (target Neo state after port)

| File | Action |
|---|---|
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/lib/constants/enroll_icons.dart` | **CREATE** (copy from flutter_plugin verbatim) |
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/lib/constants/enroll_theme.dart` | **CREATE** (copy + change `import 'package:enroll_plugin/...'` → `package:enroll_neo_plugin/...`) |
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/lib/constants/enroll_init_model.dart` | **MODIFY** (add `theme: EnrollTheme?`; keep `colors` for BC; emit both `theme` and root `colors`) |
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/lib/enroll_neo_plugin.dart` | **MODIFY** (add `enrollTheme` field; resolve priority; export new modules) |
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/android/src/main/kotlin/com/example/enroll_neo_plugin/EnrollNeoPlugin.kt` | **MODIFY** (add 14 icon parsers; switch `eNROLL.init` to `appTheme`) |
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/android/build.gradle` | **MODIFY** (bump Lite SDK; review BC dep block) |
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/ios/Classes/EnrollNeoPlugin.swift` | **NO CHANGE** (iOS continues with colors-only via root JSON) |
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/example/lib/main.dart` | **MODIFY** (add commented-out `_exampleTheme`) |
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/example/android/app/src/main/res/drawable/sample_location_icon.xml` | **CREATE** (sample drawable for testing) |
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/README.md` | **MODIFY** (add Icon Customization section) |
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/CHANGELOG.md` | **MODIFY** (1.2.0 entry) |
| `@/Users/luminsoft/StudioProjects/enroll_neo_plugin/pubspec.yaml` | **MODIFY** (version bump 1.1.2 → 1.2.0) |

> Counted: **9 files modified, 3 files created**.

---

## 6. Backward Compatibility Contract

The port must NOT break existing consumers that pass only `enrollColors`:

| Caller pattern | After port |
|---|---|
| `EnrollNeoPlugin(enrollColors: c)` | Continues to work — colors flow through `EnrollTheme(colors: c)` internally |
| `EnrollNeoPlugin(enrollTheme: t)` | New canonical path — colors + icons supported |
| `EnrollNeoPlugin(enrollColors: c, enrollTheme: t)` | `enrollTheme` wins; `enrollColors` is ignored (matches flutter_plugin) |
| `EnrollNeoPlugin(/* neither */)` | Continues to work — SDK uses defaults |

iOS: `enrollColors` and `enrollTheme.colors` both end up at root-level `colors` in JSON; iOS code unchanged.

Android: receives `theme` (preferred) and root-level `colors` (BC fallback).

---

## 7. Risk Register

| Risk | Mitigation |
|---|---|
| Lite SDK port introduces regressions | Run full e2e on the example app before publishing v1.2.7 |
| `eNROLL.init` signature drift between full and Lite SDK | Verify signature in Lite SDK build before plugin Android port |
| Drawable name resolution silently returns 0 (icon missing) | Already logged: `Log.w("EnrollPlugin", "Drawable not found: $name")` |
| iOS drift if Dart stops emitting root `colors` | Dart `toJson()` MUST emit BOTH `theme` and root `colors` — see comment in `enroll_init_model.dart` |
| Pub.dev publish: extra files (`build/`, `output/`, `tmp/`) | Add to `.pubignore`; check before `flutter pub publish` |

---

## 8. Open Questions for Next Chat

1. ~~Which path: A (port to Lite first), B (switch to full SDK), or C (stub/local AAR)?~~ **Resolved → Option A done (Lite SDK v1.3.0 published).**
2. Should `enrollColors` field on Neo be marked `@Deprecated` like the (commented-out) marker in flutter_plugin, or kept neutral?
3. Should the Neo plugin keep the `eNROLL-Lite-Android` brand or align fully with the flutter_plugin SDK? **Recommended: stay on Lite — v1.3.0 now has feature parity for icon customization.**
4. ~~Lite SDK target version — bump to `v1.2.7` (patch) or `v1.3.0` (minor)?~~ **Resolved → `v1.3.0`** (MINOR for new additive feature).

---

## 9. Quick-Start Commands for Next Chat

```bash
# Read this handoff
cat /Users/luminsoft/StudioProjects/enroll_neo_plugin/HANDOFF_ICON_CUSTOMIZATION.md

# Inspect reference plugin
ls /Users/luminsoft/StudioProjects/enroll_flutter_plugin/lib/constants/
cat /Users/luminsoft/StudioProjects/enroll_flutter_plugin/lib/constants/enroll_theme.dart
cat /Users/luminsoft/StudioProjects/enroll_flutter_plugin/lib/constants/enroll_icons.dart

# Inspect Android Kotlin plugin reference
cat /Users/luminsoft/StudioProjects/enroll_flutter_plugin/android/src/main/kotlin/com/example/enroll_plugin/EnrollPlugin.kt

# Inspect target neo plugin
cat /Users/luminsoft/StudioProjects/enroll_neo_plugin/lib/enroll_neo_plugin.dart
cat /Users/luminsoft/StudioProjects/enroll_neo_plugin/lib/constants/enroll_init_model.dart
cat /Users/luminsoft/StudioProjects/enroll_neo_plugin/android/src/main/kotlin/com/example/enroll_neo_plugin/EnrollNeoPlugin.kt

# Reference SDK port (icon-customization branch in ekyc-android)
ls /Users/luminsoft/StudioProjects/ekyc-android/eNROLL-sdk/src/main/java/com/luminsoft/enroll_sdk/ui_components/theme/
cat /Users/luminsoft/StudioProjects/ekyc-android/ICON_CUSTOMIZATION.md
```

---

## 10. Acceptance Criteria

- [x] Lite SDK published with `AppTheme`, `AppIcons`, and all icon data classes — **v1.3.0**
- [ ] GitHub Release for `v1.3.0` published (USER manual step — see Section 2)
- [ ] JitPack shows green **"Get it"** for `v1.3.0`
- [ ] `enroll_neo_plugin` compiles cleanly against `eNROLL-Lite-Android:v1.3.0`
- [ ] Existing `enrollColors`-only callers see no behavior change (BC verified)
- [ ] New `enrollTheme` callers see custom logo + step icons render on Android
- [ ] iOS callers see colors apply from `enrollColors` OR `enrollTheme.colors` identically
- [ ] Example app demonstrates icon customization with a commented `_exampleTheme` block
- [ ] CHANGELOG and README updated
- [ ] Plugin version bumped to `1.2.0`
- [ ] No deprecated SDK API calls

---

**End of handoff. Start the new chat by reading this file end-to-end before making any edits.**
