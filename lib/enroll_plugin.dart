import 'dart:async';
import 'dart:convert';

import 'package:enroll_plugin/constants/enroll_colors.dart';
import 'package:enroll_plugin/constants/enroll_step_type.dart';
import 'package:enroll_plugin/constants/native_event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/enroll_environment.dart';
import 'constants/enroll_forced_document_type.dart';
import 'constants/enroll_init_model.dart';
import 'constants/enroll_localizations.dart';
import 'constants/enroll_mode.dart';
import 'constants/enroll_state.dart';
import 'constants/enroll_step_type.dart';
import 'constants/event_models.dart';
import 'constants/native_event_types.dart';

export 'package:enroll_plugin/constants/enroll_environment.dart';
export 'package:enroll_plugin/constants/enroll_localizations.dart';
export 'package:enroll_plugin/constants/enroll_mode.dart';

/// The [EnrollPlugin] widget is the main widget responsible for handling
/// the enrollment process in the eNROLL plugin.
///
/// It takes configuration options such as localization, environment, mode,
/// and various callbacks for handling success, errors, and request IDs.
class EnrollPlugin extends StatefulWidget {
  /// The localization code specifying the language of the plugin (e.g., Arabic or English).
  final EnrollLocalizations localizationCode;

  /// The environment in which the enrollment will be performed (e.g., staging or production).
  final EnrollEnvironment enrollEnvironment;

  /// The mode of the enrollment process (e.g., onboarding or authentication).
  final EnrollMode enrollMode;

  /// The tenant ID for the organization using the enrollment process.
  final String tenantId;

  /// The tenant secret key used for authentication.
  final String tenantSecret;

  /// A callback function to execute when the enrollment is successful.
  final Function(String applicantId) onSuccess;

  /// A callback function to execute when an error occurs during enrollment.
  final Function(String error) onError;

  /// A callback function to execute when a request ID is received during the process.
  final Function(String requestId) onGettingRequestId;

  /// The context of the main screen where the plugin is being used.
  final BuildContext mainScreenContext;

  /// The Google API key, used if required by the enrollment process.
  final String? googleApiKey;

  /// The level of trust for the applicant, used for authentication.
  final String? levelOfTrust;

  /// The ID of the application, used for authentication mode.
  final String? applicationId;

  /// The ID of the request, used for breaking the request.
  final String? requestId;

  /// The ID of the contract template, used for sign contract.
  final String? templateId;

  /// The contract parameters.
  final String? contractParameters;

  /// A unique correlation ID for tracking the enrollment session.
  final String? correlationId;

  /// Determines whether to skip the tutorial during the enrollment process.
  final bool? skipTutorial;

  /// Custom colors used in the enrollment process UI.
  final EnrollColors? enrollColors;

  /// The mode of the forced document type process (e.g., nationalIdOnly, passportOnly or nationalIdOrPassport).
  final EnrollForcedDocumentType? enrollForcedDocumentType;

  // Qptional exist step after which the sdk will exit  with step passed succeffully

  final EnrollStepType ? enrollExitStep;

 
  /// Constructor for the [EnrollPlugin] widget.
  ///
  /// Various configurations and callbacks must be provided for handling the
  /// success, error, and request ID retrieval during the enrollment process.
  const EnrollPlugin(
      {super.key,
      this.localizationCode = EnrollLocalizations.en,
      this.enrollEnvironment = EnrollEnvironment.staging,
      this.enrollMode = EnrollMode.onboarding,
      required this.tenantId,
      required this.tenantSecret,
      required this.onSuccess,
      required this.onError,
      required this.onGettingRequestId,
      required this.mainScreenContext,
      this.googleApiKey,
      this.enrollColors,
      this.levelOfTrust,
      this.applicationId,
      this.requestId,
      this.templateId,
      this.contractParameters,
      this.skipTutorial,
      this.correlationId,
      this.enrollForcedDocumentType,
      this.enrollExitStep});

  @override
  State<EnrollPlugin> createState() => _EnrollPluginState();
}

class _EnrollPluginState extends State<EnrollPlugin> {
  late final StreamController<EnrollState> enrollStream;
  late EnrollInitModel model;

  /// The [MethodChannel] used to communicate with native platform code for enrollment.
  static const MethodChannel _platform = MethodChannel('enroll_plugin');

  /// The [EventChannel] used to listen for native platform events during enrollment.
  static const EventChannel _eventChannel =
      EventChannel('enroll_plugin_channel');

  Stream<String>? _stream;

  @override
  void initState() {
    super.initState();

    enrollStream = StreamController();

    // Listen to the event channel for native platform events.
    _stream = _eventChannel.receiveBroadcastStream().map<String>((event) {
      return event;
    });
    _stream?.listen((event) {
      NativeEventModel model = NativeEventModel.fromJson(json.decode(event));
      switch (model.event) {
        case NativeEventTypes.onSuccess:
          var successModel = SuccessEventModel.fromJson(model.data!);
          enrollStream
              .add(EnrollSuccess(applicantId: successModel.applicantId ?? ''));
          break;
        case NativeEventTypes.onError:
          var errorModel = ErrorEventModel.fromJson(model.data!);
          enrollStream.add(EnrollError(errorString: errorModel.message ?? ''));
          break;
        case NativeEventTypes.onRequestId:
          var requestIdModel = RequestIdEventModel.fromJson(model.data!);
          widget.onGettingRequestId(requestIdModel.requestId ?? "");
          break;
        default:
          break;
      }
    });

    enrollStream.add(EnrollStart());

    // Set up system UI and orientation settings.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Validate required inputs.
    if (widget.tenantId == '') {
      widget.onError('Tenant ID cannot be empty');
      Navigator.of(context).pop();
    }
    if (widget.tenantSecret.isEmpty) {
      widget.onError('Tenant secret cannot be empty');
      Navigator.of(context).pop();
    }
    if (widget.enrollMode == EnrollMode.auth) {
      if (widget.applicationId == null) {
        widget.onError('Application ID cannot be empty');
        Navigator.of(context).pop();
      }
      if (widget.levelOfTrust == null) {
        widget.onError('Level of trust cannot be empty');
        Navigator.of(context).pop();
      }
    }

    // Initialize the enrollment model.
    model = EnrollInitModel(
        applicantId: widget.applicationId ?? '',
        requestId: widget.requestId ?? '',
        levelOfTrust: widget.levelOfTrust ?? '',
        skipTutorial: widget.skipTutorial ?? false,
        tenantId: widget.tenantId,
        tenantSecret: widget.tenantSecret,
        googleApiKey: widget.googleApiKey ?? '',
        enrollEnvironment: widget.enrollEnvironment.name,
        localizationCode: widget.localizationCode.name,
        enrollMode: widget.enrollMode.name,
        onGettingRequestId: widget.onGettingRequestId,
        correlationId: widget.correlationId ?? '',
        templateId: widget.templateId ?? '',
        contractParameters: widget.contractParameters ?? '',
        colors: widget.enrollColors ?? EnrollColors(),
        enrollForcedDocumentType: widget.enrollForcedDocumentType?.name,
        enrollExitStep: widget.enrollExitStep?.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.localizationCode == EnrollLocalizations.ar
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: StreamBuilder(
          stream: enrollStream.stream,
          builder: (context, snapshot) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (snapshot.data != null) {
                if (snapshot.data is EnrollSuccess) {
                  EnrollSuccess enrollSuccess = snapshot.data as EnrollSuccess;
                  widget.onSuccess(enrollSuccess.applicantId);
                  Navigator.of(widget.mainScreenContext).pop();
                } else if (snapshot.data is EnrollError) {
                  EnrollError error = snapshot.data as EnrollError;
                  widget.onError(error.errorString);
                  Navigator.of(widget.mainScreenContext).pop();
                } else if (snapshot.data is EnrollStart) {
                  _startEnroll();
                } else if (snapshot.data is RequestIdReceived) {
                  RequestIdReceived requestId =
                      snapshot.data as RequestIdReceived;
                  widget.onGettingRequestId(requestId.requestId);
                }
              }
            });
            return const SizedBox();
          }),
    );
  }

  /// Starts the enrollment process by invoking the 'startEnroll' method on the native platform.
  void _startEnroll() {
    var json = jsonEncode(model.toJson());

    _platform.invokeMethod('startEnroll', json).catchError((error) {
      if (error is PlatformException) {
        enrollStream.add(EnrollError(errorString: error.message ?? ""));
      } else {
        enrollStream.add(EnrollError(errorString: "unhandledError"));
      }
    });
  }
}
