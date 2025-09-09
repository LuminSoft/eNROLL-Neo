/// The [EnrollMode] enum represents the different modes in which the eNROLL plugin can operate.
///
/// It defines whether the plugin is being used for onboarding a new user or for authentication.
enum EnrollMode {
  /// The onboarding mode, used when registering a new user in the system.
  onboarding,

  /// The authentication mode, used when verifying the identity of an existing user.
  auth,

  /// The update mode, used when verifying the identity of an existing user.
  update,

  /// The sign contract mode, used when signing contract templates .
  signContract
}
