import 'package:enroll_neo_plugin/constants/enroll_step_type.dart';
import 'package:enroll_neo_plugin/enroll_neo_plugin.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Example theme demonstrating typography + JSON localization overrides.
///
/// Android setup:
/// - Keep `enroll_localizations_en.json` and `enroll_localizations_ar.json`
///   under `example/android/app/src/main/assets/`.
/// - To apply a custom [fontFamily], add the font file under
///   `example/android/app/src/main/res/font/` and reference its resource name
///   (without extension). If the font is missing, the SDK falls back to its
///   default font automatically.
///
/// Android loads each JSON file from app assets by name (`.json` assumed when
/// no extension is given) and applies it as a localization override for the
/// matching language. (iOS typography support is pending.)
// ignore: unused_element
final EnrollTheme _typographyTheme = EnrollTheme(
  colors: EnrollColors(
    primary: const Color(0xFF1D56B8),
    secondary: const Color(0xFF5791DB),
  ),
  typography: const EnrollTypography(
    //dynamicTypeEnabled: false,
    //sizes: EnrollFontSizes.large,
    localizationOverrides: EnrollLocalizationOverrides(
      englishFileName: 'enroll_localizations_en',
      arabicFileName: 'enroll_localizations_ar',
    ),
  ),
);

/// Example theme combining custom colors and icons.
// ignore: unused_element
final EnrollTheme _exampleTheme = EnrollTheme(
  colors: EnrollColors(
    primary: const Color(0xFF756C10),
    secondary: const Color(0xFF192537),
  ),
  icons: const EnrollIcons(
    logo: EnrollLogoConfig(
      mode: EnrollLogoMode.custom,
      assetName: 'sample_location_icon',
      renderingMode: EnrollIconRenderingMode.original,
      showSponsoredBy: false,
    ),
    location: EnrollLocationIcons(
      tutorial: EnrollStepIcon(
        assetName: 'sample_location_icon',
        renderingMode: EnrollIconRenderingMode.original,
      ),
    ),
    phone: EnrollPhoneIcons(
      select: EnrollStepIcon(assetName: 'sample_location_icon'),
    ),
    email: EnrollEmailIcons(
      tutorial: EnrollStepIcon(
        assetName: 'sample_location_icon',
        renderingMode: EnrollIconRenderingMode.original,
      ),
    ),
    nationalId: EnrollNationalIdIcons(
      tutorial: EnrollStepIcon(
        assetName: 'sample_location_icon',
        renderingMode: EnrollIconRenderingMode.original,
      ),
      tutorialIdOrPassport: EnrollStepIcon(
        assetName: 'sample_location_icon',
        renderingMode: EnrollIconRenderingMode.original,
      ),
    ),
    common: EnrollCommonIcons(
      termsAndConditions: EnrollStepIcon(
        assetName: 'sample_location_icon',
        renderingMode: EnrollIconRenderingMode.original,
      ),
      popups: EnrollPopupIcons(
        successIcon: EnrollStepIcon(
          assetName: 'sample_location_icon',
          renderingMode: EnrollIconRenderingMode.original,
        ),
      ),
    ),
  ),
);

/// My App
class MyApp extends StatefulWidget {
  /// My App constructor
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Builder(builder: (context) {
      return Scaffold(
        body: EnrollNeoPlugin(
          mainScreenContext: context,
          tenantId: '3bab5a01-b3e2-4900-890c-d5fc6990e610',
          tenantSecret: 'e84e5d36-ede2-42a6-abba-ae01a9b773fc',
          requestId: '',
          enrollMode: EnrollMode.onboarding,
          enrollEnvironment: EnrollEnvironment.staging,
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
          localizationCode: EnrollLocalizations.en,
          applicationId: 'APPLICATION_ID',
          skipTutorial: false,
          levelOfTrust: 'LEVEL_OF_TRUST_TOKEN',
          googleApiKey: 'GOOGLE_API_KEY',
          correlationId: 'correlationIdTest',
          templateId: "templateId",
          contractParameters: "contractParameters",
          enrollExitStep: EnrollStepType.personalConfirmation,
          // Demonstrates EnrollTypography + JSON localization overrides.
          enrollTheme: _typographyTheme,
          // Swap to _exampleTheme to demonstrate custom colors + icons instead.
          // enrollTheme: _exampleTheme,
          // For PDF file-based signContract (EnrollMode.signContract), pass the
          // PDF bytes instead of a templateId, e.g.:
          //   signContractFile: contractBytes, // Uint8List
          //   contractFileName: 'contract.pdf',
        ),
      );
    }));
  }
}
