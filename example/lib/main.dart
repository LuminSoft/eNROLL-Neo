import 'package:enroll_neo_plugin/constants/enroll_step_type.dart';
import 'package:enroll_neo_plugin/enroll_neo_plugin.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

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
          tenantId: 'TENANT_ID',
          tenantSecret: 'TENANT_SECRET',
          requestId:'requestId',
          enrollMode: EnrollMode.onboarding,
          enrollEnvironment: EnrollEnvironment.production,
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
        ),
      );
    }));
  }
}
