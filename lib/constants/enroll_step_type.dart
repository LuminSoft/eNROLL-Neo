/// Represents the different steps in the user enrollment flow.
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
