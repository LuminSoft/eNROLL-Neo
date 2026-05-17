// ignore_for_file: public_member_api_docs

/// Controls how a custom icon asset is colorized when displayed.
///
/// - [original]: Renders the asset exactly as designed — all colors preserved.
///   Use for full-color illustrations, logos, photos.
/// - [template]: Replaces all colors with the SDK theme color.
///   Use for simple monochrome vector icons.
enum EnrollIconRenderingMode {
  /// Preserves the original colors of the asset. **Default.**
  original,

  /// Applies theme-color tinting to the entire asset.
  template,
}

/// Configuration for a single custom icon.
///
/// [assetName] is the **Android drawable resource name** (without the
/// `R.drawable.` prefix). For example, if your drawable file is
/// `res/drawable/my_location_icon.png`, pass `"my_location_icon"`.
///
/// [renderingMode] controls whether the icon is tinted to match the theme
/// or rendered with its original colors. Defaults to [EnrollIconRenderingMode.original].
class EnrollStepIcon {
  /// The Android drawable resource name (e.g. `"my_location_icon"`).
  final String assetName;

  /// How the icon should be rendered.
  final EnrollIconRenderingMode renderingMode;

  const EnrollStepIcon({
    required this.assetName,
    this.renderingMode = EnrollIconRenderingMode.original,
  });

  Map<String, dynamic> toJson() => {
        'assetName': assetName,
        'renderingMode': renderingMode.name,
      };
}

/// Controls how the SDK logo is displayed.
enum EnrollLogoMode {
  /// Show the built-in eNROLL logo.
  defaultLogo,

  /// Hide the logo entirely.
  hidden,

  /// Show a custom logo asset.
  custom,
}

/// Configuration for the SDK logo on splash screens and the app bar.
class EnrollLogoConfig {
  /// How the logo should be displayed.
  final EnrollLogoMode mode;

  /// The Android drawable resource name for the custom logo.
  /// Required when [mode] is [EnrollLogoMode.custom].
  final String? assetName;

  /// How the logo should be rendered.
  final EnrollIconRenderingMode renderingMode;

  /// Whether to show the "Sponsored by" splash footer.
  final bool showSponsoredBy;

  const EnrollLogoConfig({
    this.mode = EnrollLogoMode.defaultLogo,
    this.assetName,
    this.renderingMode = EnrollIconRenderingMode.original,
    this.showSponsoredBy = true,
  });

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        if (assetName != null) 'assetName': assetName,
        'renderingMode': renderingMode.name,
        'showSponsoredBy': showSponsoredBy,
      };
}

// ---------------------------------------------------------------------------
// Business-flow icon groups
// ---------------------------------------------------------------------------

/// Icons for the **Location** step.
class EnrollLocationIcons {
  final EnrollStepIcon? tutorial;
  final EnrollStepIcon? requestAccess;
  final EnrollStepIcon? accessError;
  final EnrollStepIcon? grab;

  const EnrollLocationIcons({
    this.tutorial,
    this.requestAccess,
    this.accessError,
    this.grab,
  });

  Map<String, dynamic> toJson() => {
        if (tutorial != null) 'tutorial': tutorial!.toJson(),
        if (requestAccess != null) 'requestAccess': requestAccess!.toJson(),
        if (accessError != null) 'accessError': accessError!.toJson(),
        if (grab != null) 'grab': grab!.toJson(),
      };
}

/// Icons for the **National ID** step.
class EnrollNationalIdIcons {
  final EnrollStepIcon? tutorial;
  final EnrollStepIcon? tutorialIdOrPassport;
  final EnrollStepIcon? preScan;
  final EnrollStepIcon? scanError;
  final EnrollStepIcon? choose;

  const EnrollNationalIdIcons({
    this.tutorial,
    this.tutorialIdOrPassport,
    this.preScan,
    this.scanError,
    this.choose,
  });

  Map<String, dynamic> toJson() => {
        if (tutorial != null) 'tutorial': tutorial!.toJson(),
        if (tutorialIdOrPassport != null)
          'tutorialIdOrPassport': tutorialIdOrPassport!.toJson(),
        if (preScan != null) 'preScan': preScan!.toJson(),
        if (scanError != null) 'scanError': scanError!.toJson(),
        if (choose != null) 'choose': choose!.toJson(),
      };
}

/// Icons for the **Passport** step.
class EnrollPassportIcons {
  final EnrollStepIcon? tutorial;
  final EnrollStepIcon? preScan;
  final EnrollStepIcon? ePassportPreScan;
  final EnrollStepIcon? choose;

  const EnrollPassportIcons({
    this.tutorial,
    this.preScan,
    this.ePassportPreScan,
    this.choose,
  });

  Map<String, dynamic> toJson() => {
        if (tutorial != null) 'tutorial': tutorial!.toJson(),
        if (preScan != null) 'preScan': preScan!.toJson(),
        if (ePassportPreScan != null)
          'ePassportPreScan': ePassportPreScan!.toJson(),
        if (choose != null) 'choose': choose!.toJson(),
      };
}

/// Icons for the **Phone OTP** step.
class EnrollPhoneIcons {
  final EnrollStepIcon? tutorial;
  final EnrollStepIcon? select;
  final EnrollStepIcon? validateOtp;

  const EnrollPhoneIcons({
    this.tutorial,
    this.select,
    this.validateOtp,
  });

  Map<String, dynamic> toJson() => {
        if (tutorial != null) 'tutorial': tutorial!.toJson(),
        if (select != null) 'select': select!.toJson(),
        if (validateOtp != null) 'validateOtp': validateOtp!.toJson(),
      };
}

/// Icons for the **Email OTP** step.
class EnrollEmailIcons {
  final EnrollStepIcon? tutorial;
  final EnrollStepIcon? select;
  final EnrollStepIcon? validateOtp;

  const EnrollEmailIcons({
    this.tutorial,
    this.select,
    this.validateOtp,
  });

  Map<String, dynamic> toJson() => {
        if (tutorial != null) 'tutorial': tutorial!.toJson(),
        if (select != null) 'select': select!.toJson(),
        if (validateOtp != null) 'validateOtp': validateOtp!.toJson(),
      };
}

/// Icons for the **Face Matching / Smile Liveness** step.
class EnrollFaceMatchingIcons {
  final EnrollStepIcon? tutorial;
  final EnrollStepIcon? preScan;
  final EnrollStepIcon? error;

  const EnrollFaceMatchingIcons({
    this.tutorial,
    this.preScan,
    this.error,
  });

  Map<String, dynamic> toJson() => {
        if (tutorial != null) 'tutorial': tutorial!.toJson(),
        if (preScan != null) 'preScan': preScan!.toJson(),
        if (error != null) 'error': error!.toJson(),
      };
}

/// Icons for the **Security Questions** step.
class EnrollSecurityQuestionsIcons {
  final EnrollStepIcon? tutorial;
  final EnrollStepIcon? authScreen;

  const EnrollSecurityQuestionsIcons({
    this.tutorial,
    this.authScreen,
  });

  Map<String, dynamic> toJson() => {
        if (tutorial != null) 'tutorial': tutorial!.toJson(),
        if (authScreen != null) 'authScreen': authScreen!.toJson(),
      };
}

/// Icons for the **Password** step.
class EnrollPasswordIcons {
  final EnrollStepIcon? tutorial;
  final EnrollStepIcon? authScreen;

  const EnrollPasswordIcons({
    this.tutorial,
    this.authScreen,
  });

  Map<String, dynamic> toJson() => {
        if (tutorial != null) 'tutorial': tutorial!.toJson(),
        if (authScreen != null) 'authScreen': authScreen!.toJson(),
      };
}

/// Icons for the **Electronic Signature** step.
class EnrollSignatureIcons {
  final EnrollStepIcon? tutorial;

  const EnrollSignatureIcons({this.tutorial});

  Map<String, dynamic> toJson() => {
        if (tutorial != null) 'tutorial': tutorial!.toJson(),
      };
}

// ---------------------------------------------------------------------------
// Shared / cross-cutting icon groups
// ---------------------------------------------------------------------------

/// Background images used across screens.
class EnrollBackgroundIcons {
  final EnrollStepIcon? main;
  final EnrollStepIcon? layer1;
  final EnrollStepIcon? layer2;
  final EnrollStepIcon? layer3;
  final EnrollStepIcon? blur;
  final EnrollStepIcon? header;
  final EnrollStepIcon? footer;

  const EnrollBackgroundIcons({
    this.main,
    this.layer1,
    this.layer2,
    this.layer3,
    this.blur,
    this.header,
    this.footer,
  });

  Map<String, dynamic> toJson() => {
        if (main != null) 'main': main!.toJson(),
        if (layer1 != null) 'layer1': layer1!.toJson(),
        if (layer2 != null) 'layer2': layer2!.toJson(),
        if (layer3 != null) 'layer3': layer3!.toJson(),
        if (blur != null) 'blur': blur!.toJson(),
        if (header != null) 'header': header!.toJson(),
        if (footer != null) 'footer': footer!.toJson(),
      };
}

/// Popup and dialog icons.
class EnrollPopupIcons {
  final EnrollStepIcon? background;
  final EnrollStepIcon? warningIcon;
  final EnrollStepIcon? errorIcon;
  final EnrollStepIcon? successIcon;

  const EnrollPopupIcons({
    this.background,
    this.warningIcon,
    this.errorIcon,
    this.successIcon,
  });

  Map<String, dynamic> toJson() => {
        if (background != null) 'background': background!.toJson(),
        if (warningIcon != null) 'warningIcon': warningIcon!.toJson(),
        if (errorIcon != null) 'errorIcon': errorIcon!.toJson(),
        if (successIcon != null) 'successIcon': successIcon!.toJson(),
      };
}

/// Profile / data display field icons.
class EnrollFieldIcons {
  final EnrollStepIcon? user;
  final EnrollStepIcon? calendar;
  final EnrollStepIcon? gender;
  final EnrollStepIcon? issuingAuthority;
  final EnrollStepIcon? nationality;
  final EnrollStepIcon? num;
  final EnrollStepIcon? passport;
  final EnrollStepIcon? address;
  final EnrollStepIcon? idCard;
  final EnrollStepIcon? profession;
  final EnrollStepIcon? religion;
  final EnrollStepIcon? maritalStatus;

  const EnrollFieldIcons({
    this.user,
    this.calendar,
    this.gender,
    this.issuingAuthority,
    this.nationality,
    this.num,
    this.passport,
    this.address,
    this.idCard,
    this.profession,
    this.religion,
    this.maritalStatus,
  });

  Map<String, dynamic> toJson() => {
        if (user != null) 'user': user!.toJson(),
        if (calendar != null) 'calendar': calendar!.toJson(),
        if (gender != null) 'gender': gender!.toJson(),
        if (issuingAuthority != null)
          'issuingAuthority': issuingAuthority!.toJson(),
        if (nationality != null) 'nationality': nationality!.toJson(),
        if (num != null) 'num': num!.toJson(),
        if (passport != null) 'passport': passport!.toJson(),
        if (address != null) 'address': address!.toJson(),
        if (idCard != null) 'idCard': idCard!.toJson(),
        if (profession != null) 'profession': profession!.toJson(),
        if (religion != null) 'religion': religion!.toJson(),
        if (maritalStatus != null) 'maritalStatus': maritalStatus!.toJson(),
      };
}

/// General UI icons used across screens.
class EnrollUiIcons {
  final EnrollStepIcon? visibility;
  final EnrollStepIcon? visibilityOff;
  final EnrollStepIcon? mobile;
  final EnrollStepIcon? mail;
  final EnrollStepIcon? answer;
  final EnrollStepIcon? error;
  final EnrollStepIcon? info;
  final EnrollStepIcon? edit;
  final EnrollStepIcon? activePhone;

  const EnrollUiIcons({
    this.visibility,
    this.visibilityOff,
    this.mobile,
    this.mail,
    this.answer,
    this.error,
    this.info,
    this.edit,
    this.activePhone,
  });

  Map<String, dynamic> toJson() => {
        if (visibility != null) 'visibility': visibility!.toJson(),
        if (visibilityOff != null) 'visibilityOff': visibilityOff!.toJson(),
        if (mobile != null) 'mobile': mobile!.toJson(),
        if (mail != null) 'mail': mail!.toJson(),
        if (answer != null) 'answer': answer!.toJson(),
        if (error != null) 'error': error!.toJson(),
        if (info != null) 'info': info!.toJson(),
        if (edit != null) 'edit': edit!.toJson(),
        if (activePhone != null) 'activePhone': activePhone!.toJson(),
      };
}

/// Common icons shared across all flows.
class EnrollCommonIcons {
  final EnrollBackgroundIcons? backgrounds;
  final EnrollPopupIcons? popups;
  final EnrollFieldIcons? fieldIcons;
  final EnrollUiIcons? ui;
  final EnrollStepIcon? termsAndConditions;

  const EnrollCommonIcons({
    this.backgrounds,
    this.popups,
    this.fieldIcons,
    this.ui,
    this.termsAndConditions,
  });

  Map<String, dynamic> toJson() => {
        if (backgrounds != null) 'backgrounds': backgrounds!.toJson(),
        if (popups != null) 'popups': popups!.toJson(),
        if (fieldIcons != null) 'fieldIcons': fieldIcons!.toJson(),
        if (ui != null) 'ui': ui!.toJson(),
        if (termsAndConditions != null)
          'termsAndConditions': termsAndConditions!.toJson(),
      };
}

// ---------------------------------------------------------------------------
// Update / Forget mode step-list icons
// ---------------------------------------------------------------------------

/// Icons shown in the **Update** step-list screen.
class EnrollUpdateIcons {
  final EnrollStepIcon? modeIcon;
  final EnrollStepIcon? idCard;
  final EnrollStepIcon? passport;
  final EnrollStepIcon? mobile;
  final EnrollStepIcon? email;
  final EnrollStepIcon? device;
  final EnrollStepIcon? address;
  final EnrollStepIcon? securityQuestions;
  final EnrollStepIcon? password;

  const EnrollUpdateIcons({
    this.modeIcon,
    this.idCard,
    this.passport,
    this.mobile,
    this.email,
    this.device,
    this.address,
    this.securityQuestions,
    this.password,
  });

  Map<String, dynamic> toJson() => {
        if (modeIcon != null) 'modeIcon': modeIcon!.toJson(),
        if (idCard != null) 'idCard': idCard!.toJson(),
        if (passport != null) 'passport': passport!.toJson(),
        if (mobile != null) 'mobile': mobile!.toJson(),
        if (email != null) 'email': email!.toJson(),
        if (device != null) 'device': device!.toJson(),
        if (address != null) 'address': address!.toJson(),
        if (securityQuestions != null)
          'securityQuestions': securityQuestions!.toJson(),
        if (password != null) 'password': password!.toJson(),
      };
}

/// Icons shown in the **Forget Profile Data** step-list screen.
class EnrollForgetIcons {
  final EnrollStepIcon? modeIcon;
  final EnrollStepIcon? nationalId;
  final EnrollStepIcon? passport;
  final EnrollStepIcon? phone;
  final EnrollStepIcon? email;
  final EnrollStepIcon? device;
  final EnrollStepIcon? location;
  final EnrollStepIcon? securityQuestions;
  final EnrollStepIcon? password;

  const EnrollForgetIcons({
    this.modeIcon,
    this.nationalId,
    this.passport,
    this.phone,
    this.email,
    this.device,
    this.location,
    this.securityQuestions,
    this.password,
  });

  Map<String, dynamic> toJson() => {
        if (modeIcon != null) 'modeIcon': modeIcon!.toJson(),
        if (nationalId != null) 'nationalId': nationalId!.toJson(),
        if (passport != null) 'passport': passport!.toJson(),
        if (phone != null) 'phone': phone!.toJson(),
        if (email != null) 'email': email!.toJson(),
        if (device != null) 'device': device!.toJson(),
        if (location != null) 'location': location!.toJson(),
        if (securityQuestions != null)
          'securityQuestions': securityQuestions!.toJson(),
        if (password != null) 'password': password!.toJson(),
      };
}

// ---------------------------------------------------------------------------
// Top-level icon configuration
// ---------------------------------------------------------------------------

/// Top-level icon configuration for the eNROLL SDK.
///
/// All fields are optional — when `null`, the SDK uses its built-in assets.
///
/// Example:
/// ```dart
/// EnrollIcons(
///   logo: EnrollLogoConfig(
///     mode: EnrollLogoMode.custom,
///     assetName: 'my_company_logo',
///     renderingMode: EnrollIconRenderingMode.original,
///     showSponsoredBy: false,
///   ),
///   location: EnrollLocationIcons(
///     tutorial: EnrollStepIcon(assetName: 'my_location_tutorial'),
///   ),
/// )
/// ```
class EnrollIcons {
  final EnrollLogoConfig? logo;
  final EnrollLocationIcons? location;
  final EnrollNationalIdIcons? nationalId;
  final EnrollPassportIcons? passport;
  final EnrollPhoneIcons? phone;
  final EnrollEmailIcons? email;
  final EnrollFaceMatchingIcons? faceMatching;
  final EnrollSecurityQuestionsIcons? securityQuestions;
  final EnrollPasswordIcons? password;
  final EnrollSignatureIcons? signature;
  final EnrollCommonIcons? common;
  final EnrollUpdateIcons? update;
  final EnrollForgetIcons? forget;

  const EnrollIcons({
    this.logo,
    this.location,
    this.nationalId,
    this.passport,
    this.phone,
    this.email,
    this.faceMatching,
    this.securityQuestions,
    this.password,
    this.signature,
    this.common,
    this.update,
    this.forget,
  });

  Map<String, dynamic> toJson() => {
        if (logo != null) 'logo': logo!.toJson(),
        if (location != null) 'location': location!.toJson(),
        if (nationalId != null) 'nationalId': nationalId!.toJson(),
        if (passport != null) 'passport': passport!.toJson(),
        if (phone != null) 'phone': phone!.toJson(),
        if (email != null) 'email': email!.toJson(),
        if (faceMatching != null) 'faceMatching': faceMatching!.toJson(),
        if (securityQuestions != null)
          'securityQuestions': securityQuestions!.toJson(),
        if (password != null) 'password': password!.toJson(),
        if (signature != null) 'signature': signature!.toJson(),
        if (common != null) 'common': common!.toJson(),
        if (update != null) 'update': update!.toJson(),
        if (forget != null) 'forget': forget!.toJson(),
      };
}
