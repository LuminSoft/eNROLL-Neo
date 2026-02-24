import 'package:enroll_neo_plugin/constants/enroll_colors.dart';

/// The [EnrollInitModel] class is used to initialize the eNROLL plugin
/// with various configurations and settings for enrollment processes.
class EnrollInitModel {
  /// The localization code for the user's language and region.
  String? localizationCode;

  /// The environment in which the eNROLL plugin is running (e.g., production, sandbox).
  String? enrollEnvironment;

  /// The mode of enrollment, specifying how the process should operate.
  String? enrollMode;

  /// The ID of the tenant (organization or company) using the eNROLL system.
  String? tenantId;

  /// The ID of the applicant (user) undergoing the enrollment process.
  String? applicantId;

  /// The ID of the user undergoing the enrollment process.
  String? requestId;

  /// The level of trust assigned to the applicant, which can affect the enrollment process.
  String? levelOfTrust;

  /// Whether to skip the tutorial during the enrollment process.
  bool? skipTutorial;

  /// The tenant's secret key for authentication purposes.
  String? tenantSecret;

  /// The API key for Google services used during the enrollment process.
  String? googleApiKey;

  /// The correlation ID used to track and log the enrollment process.
  String? correlationId;

  /// The contract template ID used for sign contract.
  String? templateId;

  /// The contract parameters.
  String? contractParameters;

  /// Custom colors used in the eNROLL plugin UI.
  EnrollColors? colors;

  /// Custom enroll forced document type used in the eNROLL plugin UI.
  String? enrollForcedDocumentType;

  ///  Specifies the enrollment step at which the flow should exit when running in onboarding mode.
  String? enrollExitStep;

  /// Constructor for initializing [EnrollInitModel] with optional settings.
  ///
  /// [onGettingRequestId] is a callback function that triggers when a request ID is generated.
  EnrollInitModel(
      {this.localizationCode,
      this.enrollEnvironment,
      this.enrollMode,
      this.enrollForcedDocumentType,
      this.tenantId,
      this.tenantSecret,
      this.googleApiKey,
      this.colors,
      this.applicantId,
      this.requestId,
      this.levelOfTrust,
      this.skipTutorial,
      this.correlationId,
      this.templateId,
      this.contractParameters,
      this.enrollExitStep,
      required Function(String requestId) onGettingRequestId});

  /// Creates an [EnrollInitModel] object from a JSON map.
  ///
  /// This is useful when you need to deserialize data from a JSON response.
  EnrollInitModel.fromJson(Map<String, dynamic> json) {
    localizationCode = json['localizationCode'];
    enrollEnvironment = json['enrollEnvironment'];
    tenantId = json['tenantId'];
    enrollMode = json['enrollMode'];
    applicantId = json['applicationId'];
    requestId = json['requestId'];
    levelOfTrust = json['levelOfTrust'];
    skipTutorial = json['skipTutorial'];
    tenantSecret = json['tenantSecret'];
    googleApiKey = json['googleApiKey'];
    correlationId = json['correlationId'];
    templateId = json['templateId'];
    contractParameters = json['contractParameters'];
    colors = json['colors'];
    enrollForcedDocumentType = json['enrollForcedDocumentType'];
    enrollExitStep = json['exitStep'];

  }

  /// Converts the [EnrollInitModel] object into a JSON map.
  ///
  /// This is useful when you need to serialize the data to send it via an API.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['localizationCode'] = localizationCode;
    data['enrollEnvironment'] = enrollEnvironment;
    data['tenantId'] = tenantId;
    data['enrollMode'] = enrollMode;
    data['enrollForcedDocumentType'] = enrollForcedDocumentType;
    data['tenantSecret'] = tenantSecret;
    data['googleApiKey'] = googleApiKey;
    data['applicationId'] = applicantId;
    data['requestId'] = requestId;
    data['levelOfTrust'] = levelOfTrust;
    data['skipTutorial'] = skipTutorial;
    data['correlationId'] = correlationId;
    data['templateId'] = templateId;
    data['contractParameters'] = contractParameters;
    data['exitStep'] = enrollExitStep;
    if (colors != null) {
      data['colors'] = colors!.toJson();
    }
    return data;
  }
}
