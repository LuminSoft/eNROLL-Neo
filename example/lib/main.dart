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
          tenantId: '8eb393b6-baed-4004-a65e-8bf3c4bfac09',
          tenantSecret: '07e127d9-a770-4b7f-af4b-86f806da634f',
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
          localizationCode: EnrollLocalizations.ar,
          applicationId: 'APPLICATION_ID',
          skipTutorial: false,
          levelOfTrust: '7b4e1e88-6cdd-459b-a009-c0b595a30420',
          googleApiKey: 'AIzaSyCqLOHRPi_s1LO6hj8YeqY7HByu7G5kqcY',
          correlationId: '',
          templateId: "",
          contractParameters: "",
          enrollExitStep: EnrollStepType.termsAndConditions,
        ),
      );
    }));
  }
}
