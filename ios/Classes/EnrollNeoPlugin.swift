import Flutter
import UIKit
import EnrollFramework

public class EnrollNeoPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, EnrollCallBack {
    
    
    func dictionartToJsonString(dictionary: [String: Any?]) -> String{
        guard let decoded = try? JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed) else {
            return "enExpectedError"
        }
        guard let jsonString = String(data: decoded, encoding: .utf8) else {
            print("Something is wrong while converting JSON data to JSON string.")
            return "unexpected Error"
        }
        return jsonString
    }
    
    //MARK: - Enroll Callbacks
    
    public func enrollDidSucceed(with model: EnrollFramework.EnrollSuccessModel) {
        if let eventSink = eventSink {
            var dict: [String: Any?] = [:]
            dict["event"] = "on_success"
            dict["data"] = ["applicantId": model.applicantId]
            eventSink(dictionartToJsonString(dictionary: dict))
        }
    }
    
    public func enrollDidFail(with error: EnrollFramework.EnrollErrorModel) {
        if let eventSink = eventSink {
            var dict: [String: Any?] = [:]
            dict["event"] = "on_error"
            dict["data"] = ["message": error.errorMessage]
            eventSink(dictionartToJsonString(dictionary: dict))
        }
    }
    
    public func didInitializeRequest(with requestId: String) {
        if let eventSink = eventSink {
            var dict: [String: Any?] = [:]
            dict["event"] = "on_request_id"
            dict["data"] = ["requestId": requestId]
            eventSink(dictionartToJsonString(dictionary: dict))
        }
    }
    
    //MARK: - Properties
    var eventSink: FlutterEventSink?
    
    //MARK: - Registering
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "enroll_neo_plugin", binaryMessenger: registrar.messenger())
        let eventChannelName = "enroll_neo_plugin_channel"
        let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: registrar.messenger())
        
        let instance = EnrollNeoPlugin()
        eventChannel.setStreamHandler(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
        
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startEnroll":
            if let json = call.arguments as? String {
                launchEnroll(json: json)
            }
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    //MARK: - Launching Enroll
    func launchEnroll(json: String){
        do {
            
            var tenatId: String = ""
            var tenantSecret: String = ""
            var requestId: String?
            var enrollEnvironment: EnrollFramework.EnrollEnviroment = .staging
            var localizationCode: EnrollFramework.LocalizationEnum = .en
            var enrollColors: EnrollColors?
            var skip: Bool?
            var mode: EnrollMode?
            var applicantId: String?
            var levelOfTrust: String?
            var correlationId: String?
            var enrollForcedDocumentType: EnrollForcedDocumentType?
            var contractTemplateId:String?
            var questionnaireId:String?
            var signContarctParam: String?
            var signContarctFile: Data?
            var signContarctFileName : String?
            var exitStep:EnrollFramework.StepType?
            var enrolltheme : EnrollTheme?
            
            
            if let data = json.data(using: .utf8){
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                if let dict = jsonObject as? [String: Any] {
                    tenatId = dict["tenantId"] as? String ?? ""
                    tenantSecret = dict["tenantSecret"] as? String ?? ""
                    if let colors = dict["colors"] as? [String: Any]{
                        enrollColors = generateDynamicColors(colors: colors)
                    }
                    if let theme = dict["theme"] as? [String: Any]{
                     enrolltheme = generateDynamicTheme(theme:theme)
                     if let typographyDict = theme["typography"] as? [String: Any] {
                     let parsedTypography = generateDynamicTypography(typographyDict)
                     if enrolltheme == nil {
                       enrolltheme = EnrollTheme()
                        }
                         enrolltheme?.typography = parsedTypography
                         }
                       }
                    if let enrollMode = dict["enrollMode"] as? String{
                        if let value = getEnrollMode(mode: enrollMode) {
                            mode = value
                        }
                    }
                    if let skipTutorial = dict["skipTutorial"] as? Bool{
                        skip = skipTutorial
                    }
                    if let levelOfTrustSring =  dict["levelOfTrust"] as? String {
                        levelOfTrust = levelOfTrustSring
                    }
                    if let appId =  dict["applicationId"] as? String {
                        applicantId = appId
                    }
                    if let reqId =  dict["requestId"] as? String {
                                            requestId = reqId
                    }
                    
                    if let correlId =  dict["correlationId"] as? String {
                        correlationId = correlId
                    }

                    if let enrollForcedDocument =  dict["enrollForcedDocumentType"] as? String {
                        if enrollForcedDocument=="nationalIdOnly"{
                            enrollForcedDocumentType=EnrollForcedDocumentType.nationalId
                        }else  if enrollForcedDocument=="passportOnly"{
                            enrollForcedDocumentType=EnrollForcedDocumentType.passport
                        }else{
                            enrollForcedDocumentType=EnrollForcedDocumentType.deafult

                        }
                    }
                    if let  enrollExistStep = dict["exitStep"] as? String {
                        exitStep = getExitStep(step: enrollExistStep)
                    }
                    if let contractId =  dict["templateId"] as? String {
                        contractTemplateId = contractId
                    }
                     if let questionnaire = dict["questionnaireId"] as? String {
                        questionnaireId = questionnaire
                    }
                    if let contractParam =  dict["contractParameters"] as? String {
                        signContarctParam = contractParam
                    }
                   if let contractFileBase64 = dict["signContractFile"] as? String,
                         !contractFileBase64.isEmpty,
                          let contractFileData = Data(base64Encoded: contractFileBase64) {
                           signContarctFile = contractFileData
                    }
                    if let contractFileName =  dict["contractFileName"] as? String {
                    signContarctFileName = contractFileName
                    }



                    let localizationName = dict["localizationCode"] as? String ?? ""
                    let environmentName = dict["enrollEnvironment"] as? String ?? ""
                    if localizationName == "ar" {
                        localizationCode = .ar
                        UIView.appearance().semanticContentAttribute = .forceRightToLeft
                        UICollectionView.appearance().semanticContentAttribute = .forceRightToLeft
                        UINavigationBar.appearance().semanticContentAttribute = .forceRightToLeft
                        UITextField.appearance().semanticContentAttribute = .forceRightToLeft
                        UITextField.appearance().textAlignment = .right
                        UITextView.appearance().semanticContentAttribute = .forceRightToLeft
                        UITableView.appearance().semanticContentAttribute = .forceRightToLeft
                    }else {
                        localizationCode = .en
                        UIView.appearance().semanticContentAttribute = .forceLeftToRight
                        UICollectionView.appearance().semanticContentAttribute = .forceLeftToRight
                        UINavigationBar.appearance().semanticContentAttribute = .forceLeftToRight
                        UITextField.appearance().semanticContentAttribute = .forceLeftToRight
                        UITextView.appearance().semanticContentAttribute = .forceLeftToRight
                        UITextField.appearance().textAlignment = .left
                        UITableView.appearance().semanticContentAttribute = .forceLeftToRight
                    }
                    enrollEnvironment = environmentName == "staging" ? .staging : .production
                    
                    
                }
            }
              // Apply typography (and the rest of the theme) to the shared
              // EnrollThemeManager so the SDK picks up custom fonts /
              // localization overrides for this session.
            EnrollThemeManager.shared.configure(enrolltheme)
            
            UIApplication.shared.delegate?.window??.rootViewController?.present(try Enroll.initViewController(enrollInitModel: EnrollInitModel(tenantId: tenatId, tenantSecret: tenantSecret, enrollEnviroment: enrollEnvironment, localizationCode: localizationCode, enrollCallBack: self, enrollMode: mode ?? .onboarding, skipTutorial: skip ?? false, enrollColors: enrollColors,enrollTheme: enrolltheme, levelOffTrustId: levelOfTrust, applicantId: applicantId, correlationId: correlationId,forcedDocumentType: enrollForcedDocumentType,requestId: requestId,contractTemplateId:contractTemplateId,signContarctParam: signContarctParam,signContarctFile: signContarctFile, signContarctFileName: signContarctFileName, exitStep: exitStep ), presenterVC: (UIApplication.shared.delegate?.window??.rootViewController!)!), animated: true)
        }catch{
            if let eventSink = eventSink {
                eventSink("unexpected error")
            }
            
        }
        
    }
    
    //MARK: - Helpers
    
    func getEnrollMode(mode: String) -> EnrollMode?{
        switch mode.lowercased() {
        case  "onboarding":
            return .onboarding
        case  "update":
            return .update
        case  "auth":
            return .authentication
        case "forget":
            return .forget
        case "signcontract":
            return .signContarct
        case "questionnaire":
             return .questionnaire
        default:
            return nil
        }
    }
    
    func getExitStep(step: String) -> StepType?{
        switch step {
        case  "phoneOtp":
            return .phoneOtp
        case  "personalConfirmation":
            return .personalConfirmation
        case  "smileLiveness":
            return .smileLiveness
        case "emailOtp":
            return .emailOtp
        case "saveMobileDevice":
            return .saveMobileDevice
        case "deviceLocation":
            return .deviceLocation
        case "password":
            return .password
        case "securityQuestions":
            return .securityQuestions
        case "amlCheck":
            return .amlCheck
        case "termsAndConditions":
            return .termsAndConditions
        case "electronicSignature":
            return .electronicSignature
        case "ntraCheck":
            return .ntraCheck
        case "csoCheck":
            return .csoCheck
        default:
            return nil
        }
    }
    
    func generateDynamicColors(colors: [String: Any]?) -> EnrollColors{
        var primaryColor: UIColor?
        var appBackgroundColor: UIColor?
        var appBlack: UIColor?
        var secondary: UIColor?
        var appWhite: UIColor?
        var errorColor: UIColor?
        var textColor: UIColor?
        var successColor: UIColor?
        var warningColor: UIColor?
        
        
        if let primary = colors?["primary"] as? [String: Any]{
            if let red = primary["r"] as? Int, let green = primary["g"] as? Int, let blue = primary["b"] as? Int{
                primaryColor = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1.0)
            }
        }
        
        if let backgroundColor = colors?["appBackgroundColor"] as? [String: Any] {
            if let red = backgroundColor["r"] as? Int, let green = backgroundColor["g"] as? Int, let blue = backgroundColor["b"] as? Int, let alpha = backgroundColor["opacity"] as? Double {
                appBackgroundColor = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha))
            }
        }
        
        if let black = colors?["appBlack"] as? [String: Any] {
            if let red = black["r"] as? Int, let green = black["g"] as? Int, let blue = black["b"] as? Int, let alpha = black["opacity"] as? Double {
                appBlack = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha))
            }
        }
        
        if let secondaryColor = colors?["secondary"] as? [String: Any] {
            if let red = secondaryColor["r"] as? Int, let green = secondaryColor["g"] as? Int, let blue = secondaryColor["b"] as? Int, let alpha = secondaryColor["opacity"] as? Double {
                secondary = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha))
            }
        }
        
        
        if let white = colors?["appWhite"] as? [String: Any] {
            if let red = white["r"] as? Int, let green = white["g"] as? Int, let blue = white["b"] as? Int, let alpha = white["opacity"] as? Double {
                appWhite = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha))
            }
        }
        
        
        if let error = colors?["errorColor"] as? [String: Any] {
            if let red = error["r"] as? Int, let green = error["g"] as? Int, let blue = error["b"] as? Int, let alpha = error["opacity"] as? Double {
                errorColor = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha))
            }
        }
        
        if let text = colors?["textColor"] as? [String: Any] {
            if let red = text["r"] as? Int, let green = text["g"] as? Int, let blue = text["b"] as? Int, let alpha = text["opacity"] as? Double {
                textColor = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha))
            }
        }
        
        if let success = colors?["successColor"] as? [String: Any] {
            if let red = success["r"] as? Int, let green = success["g"] as? Int, let blue = success["b"] as? Int, let alpha = success["opacity"] as? Double {
                successColor = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha))
            }
        }
        
        if let warning = colors?["warningColor"] as? [String: Any] {
            if let red = warning["r"] as? Int, let green = warning["g"] as? Int, let blue = warning["b"] as? Int, let alpha = warning["opacity"] as? Double {
                warningColor = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha))
            }
        }
        
        return EnrollColors(primary: primaryColor, secondary: secondary, appBackgroundColor: appBackgroundColor, textColor: textColor, errorColor: errorColor, successColor: successColor, warningColor: warningColor, appWhite: appWhite, appBlack: appBlack)
    }
     func generateDynamicTheme(theme: [String: Any]?) -> EnrollTheme {
            guard let theme = theme else {
                return EnrollTheme()
            }

            // Extract colors if provided in theme
            var enrollColors: EnrollColors?
            if let colorDict = theme["colors"] as? [String: Any] {
                enrollColors = generateDynamicColors(colors: colorDict)
            }

            // Extract icons if provided in theme
            var appIcons = AppIcons()
            if let iconsDict = theme["icons"] as? [String: Any] {
                appIcons = generateAppIcons(from: iconsDict)
            }

            return EnrollTheme(icons: appIcons, colors: enrollColors)
        }

    // MARK: - Generate Dynamic Typography

    /// Builds an `EnrollTypography` from the JSON dictionary sent by Flutter.
    /// Mirrors the Dart-side `EnrollTypography.toJson()` shape.
    func generateDynamicTypography(_ dict: [String: Any]) -> EnrollTypography {
        let fontFamily = dict["fontFamily"] as? String
        let dynamicTypeEnabled = dict["dynamicTypeEnabled"] as? Bool ?? true

        // `sizes` is now a string preset: "default" | "medium" | "large".
        var sizes = EnrollFontSizes(size: .default)
        if let sizeName = dict["sizes"] as? String {
            switch sizeName.lowercased() {
            case "medium":
                sizes = EnrollFontSizes(size: .medium)
            case "large":
                sizes = EnrollFontSizes(size: .large)
            default:
                sizes = EnrollFontSizes(size: .default)
            }
        }

        var localizationOverrides: EnrollLocalizationOverrides?
        if let overridesDict = dict["localizationOverrides"] as? [String: Any] {
            let englishFileName = overridesDict["englishFileName"] as? String
            let arabicFileName = overridesDict["arabicFileName"] as? String
            if englishFileName != nil || arabicFileName != nil {
                localizationOverrides = EnrollLocalizationOverrides(
                    englishFileName: englishFileName,
                    arabicFileName: arabicFileName,
                    bundle: .main
                )
            }
        }

        return EnrollTypography(
            fontFamily: fontFamily,
            dynamicTypeEnabled: dynamicTypeEnabled,
            sizes: sizes,
            localizationOverrides: localizationOverrides
        )
    }
//        // MARK: - Generate AppIcons from Dictionary

        func generateAppIcons(from dictionary: [String: Any]) -> AppIcons {
            var logo = LogoConfig()
            var location = LocationIcons()
            var nationalId: NationalIdIcons?
            var passport = PassportIcons()
            var phone = PhoneIcons()
            var email = EmailIcons()
            var faceMatching = FaceMatchingIcons()
            var securityQuestions = SecurityQuestionsIcons()
            var password = PasswordIcons()
            var signature = SignatureIcons()
            var common = CommonIcons()
            var update = UpdateIcons()
            var forget = ForgetIcons()

            // Parse logo configuration
            if let logoDict = dictionary["logo"] as? [String: Any] {
                logo = parseLogoConfig(from: logoDict)
            }

            // Parse location icons
            if let locationDict = dictionary["location"] as? [String: Any] {
                location = parseLocationIcons(from: locationDict)
            }

            // Parse national ID icons
            if let nationalIdDict = dictionary["nationalId"] as? [String: Any] {
                nationalId = parseNationalIdIcons(from: nationalIdDict)
            }

            // Parse passport icons
            if let passportDict = dictionary["passport"] as? [String: Any] {
                passport = parsePassportIcons(from: passportDict)
            }

            // Parse phone icons
            if let phoneDict = dictionary["phone"] as? [String: Any] {
                phone = parsePhoneIcons(from: phoneDict)
            }

            // Parse email icons
            if let emailDict = dictionary["email"] as? [String: Any] {
                email = parseEmailIcons(from: emailDict)
            }

            // Parse face matching icons
            if let faceMatchingDict = dictionary["faceMatching"] as? [String: Any] {
                faceMatching = parseFaceMatchingIcons(from: faceMatchingDict)
            }

            // Parse security questions icons
            if let securityQuestionsDict = dictionary["securityQuestions"] as? [String: Any] {
                securityQuestions = parseSecurityQuestionsIcons(from: securityQuestionsDict)
            }

            // Parse password icons
            if let passwordDict = dictionary["password"] as? [String: Any] {
                password = parsePasswordIcons(from: passwordDict)
            }

            // Parse signature icons
            if let signatureDict = dictionary["signature"] as? [String: Any] {
                signature = parseSignatureIcons(from: signatureDict)
            }

            // Parse common icons
            if let commonDict = dictionary["common"] as? [String: Any] {
                common = parseCommonIcons(from: commonDict)
            }

            // Parse update icons
            if let updateDict = dictionary["update"] as? [String: Any] {
                update = parseUpdateIcons(from: updateDict)
            }

            // Parse forget icons
            if let forgetDict = dictionary["forget"] as? [String: Any] {
                forget = parseForgetIcons(from: forgetDict)
            }

            return AppIcons(
                logo: logo,
                location: location,
                nationalId: nationalId,
                passport: passport,
                phone: phone,
                email: email,
                faceMatching: faceMatching,
                securityQuestions: securityQuestions,
                password: password,
                signature: signature,
                common: common,
                update: update,
                forget: forget
            )
        }
    // MARK: - Logo Config Parser

       func parseLogoConfig(from dictionary: [String: Any]) -> LogoConfig {
           var mode: LogoMode = .default
           var icon: EnrollIcon?
           var showSponseredBy:Bool?
           
           if let modeString = dictionary["mode"] as? String {
               switch modeString.lowercased() {
               case "hidden":
                   mode = .hidden
               case "custom":
                   mode = .custom
               default:
                   mode = .default
               }
           }
           
           if let iconDict = dictionary["assetName"] as? String {
               icon = parseEnrollIcon(from: dictionary)
           }
           if let showSponsereBy = dictionary["showSponsoredBy"] as? Bool{
               showSponseredBy = showSponsereBy
           }
           
           return LogoConfig(mode: mode, icon: icon,showSponsoredBy: showSponseredBy ?? true)
       }

       // MARK: - EnrollIcon Parser

       func parseEnrollIcon(from dictionary: [String: Any]) -> EnrollIcon {
           let assetName = dictionary["assetName"] as? String ?? ""
           
           var renderingMode: EnrollIconRenderingMode = .original
           if let renderingModeString = dictionary["renderingMode"] as? String {
               renderingMode = renderingModeString.lowercased() == "template" ? .template : .original
           }
           
           var validationMode: IconValidationMode = .relaxed
           if let validationModeString = dictionary["validationMode"] as? String {
               validationMode = validationModeString.lowercased() == "strict" ? .strict : .relaxed
           }
           
           let bundle = Bundle.main
           
           return EnrollIcon(
               assetName: assetName,
               renderingMode: renderingMode,
               bundle: bundle,
               validationMode: validationMode
           )
       }

       // MARK: - StepIcon Parser

       func parseStepIcon(from dictionary: [String: Any]) -> StepIcon? {
           guard let iconDict = dictionary as? [String: Any] else {
               return nil
           }
           
           guard let enrollIcon = parseEnrollIcon(from: iconDict) as? EnrollIcon else {
               return nil
           }
           
           return StepIcon(icon: enrollIcon)
       }

       // MARK: - Location Icons Parser

       func parseLocationIcons(from dictionary: [String: Any]) -> LocationIcons {
           let tutorial = parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:])
           let requestAccess = parseStepIcon(from: dictionary["requestAccess"] as? [String: Any] ?? [:])
           let accessError = parseStepIcon(from: dictionary["accessError"] as? [String: Any] ?? [:])
           let grab = parseStepIcon(from: dictionary["grab"] as? [String: Any] ?? [:])
           
           return LocationIcons(
               tutorial: tutorial,
               requestAccess: requestAccess,
               accessError: accessError,
               grab: grab
           )
       }

       // MARK: - National ID Icons Parser

       func parseNationalIdIcons(from dictionary: [String: Any]) -> NationalIdIcons {
           let tutorial = parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:])
           let tutorialIdOrPassport = parseStepIcon(from: dictionary["tutorialIdOrPassport"] as? [String: Any] ?? [:])
           let preScan = parseStepIcon(from: dictionary["preScan"] as? [String: Any] ?? [:])
           let scanError = parseStepIcon(from: dictionary["scanError"] as? [String: Any] ?? [:])
           let choose = parseStepIcon(from: dictionary["choose"] as? [String: Any] ?? [:])
           
           return NationalIdIcons(
               tutorial: tutorial,
               tutorialIdOrPassport: tutorialIdOrPassport,
               preScan: preScan,
               scanError: scanError,
               choose: choose
           )
       }

       // MARK: - Passport Icons Parser

       func parsePassportIcons(from dictionary: [String: Any]) -> PassportIcons {
           let tutorial = parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:])
           let preScan = parseStepIcon(from: dictionary["preScan"] as? [String: Any] ?? [:])
           let ePassportPreScan = parseStepIcon(from: dictionary["ePassportPreScan"] as? [String: Any] ?? [:])
           let choose = parseStepIcon(from: dictionary["choose"] as? [String: Any] ?? [:])
           let scanError = parseStepIcon(from: dictionary["scanError"] as? [String: Any] ?? [:])
           
           return PassportIcons(
               tutorial: tutorial,
               preScan: preScan,
               ePassportPreScan: ePassportPreScan,
               choose: choose,
               scanError: scanError
           )
       }

       // MARK: - Phone Icons Parser

       func parsePhoneIcons(from dictionary: [String: Any]) -> PhoneIcons {
           let tutorial = parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:])
           let select = parseStepIcon(from: dictionary["select"] as? [String: Any] ?? [:])
           let validateOtp = parseStepIcon(from: dictionary["validateOtp"] as? [String: Any] ?? [:])
           
           return PhoneIcons(
               tutorial: tutorial,
               select: select,
               validateOtp: validateOtp
           )
       }

       // MARK: - Email Icons Parser

       func parseEmailIcons(from dictionary: [String: Any]) -> EmailIcons {
           let tutorial = parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:])
           let select = parseStepIcon(from: dictionary["select"] as? [String: Any] ?? [:])
           let validateOtp = parseStepIcon(from: dictionary["validateOtp"] as? [String: Any] ?? [:])
           
           return EmailIcons(
               tutorial: tutorial,
               select: select,
               validateOtp: validateOtp
           )
       }

       // MARK: - Face Matching Icons Parser

       func parseFaceMatchingIcons(from dictionary: [String: Any]) -> FaceMatchingIcons {
           let tutorial = parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:])
           let preScan = parseStepIcon(from: dictionary["preScan"] as? [String: Any] ?? [:])
           let error = parseStepIcon(from: dictionary["error"] as? [String: Any] ?? [:])
           
           return FaceMatchingIcons(
               tutorial: tutorial,
               preScan: preScan,
               error: error
           )
       }

       // MARK: - Security Questions Icons Parser

       func parseSecurityQuestionsIcons(from dictionary: [String: Any]) -> SecurityQuestionsIcons {
           let tutorial = parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:])
           let authScreen = parseStepIcon(from: dictionary["authScreen"] as? [String: Any] ?? [:])
           
           return SecurityQuestionsIcons(
               tutorial: tutorial,
               authScreen: authScreen
           )
       }

       // MARK: - Password Icons Parser

       func parsePasswordIcons(from dictionary: [String: Any]) -> PasswordIcons {
           let tutorial = parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:])
           let authScreen = parseStepIcon(from: dictionary["authScreen"] as? [String: Any] ?? [:])
           
           return PasswordIcons(
               tutorial: tutorial,
               authScreen: authScreen
           )
       }

       // MARK: - Signature Icons Parser

       func parseSignatureIcons(from dictionary: [String: Any]) -> SignatureIcons {
           let tutorial = parseStepIcon(from: dictionary["tutorial"] as? [String: Any] ?? [:])
           return SignatureIcons(tutorial: tutorial)
       }

       // MARK: - Background Icons Parser

       func parseBackgroundIcons(from dictionary: [String: Any]) -> BackgroundIcons {
           let main = parseStepIcon(from: dictionary["main"] as? [String: Any] ?? [:])
           let layer1 = parseStepIcon(from: dictionary["layer1"] as? [String: Any] ?? [:])
           let layer2 = parseStepIcon(from: dictionary["layer2"] as? [String: Any] ?? [:])
           let layer3 = parseStepIcon(from: dictionary["layer3"] as? [String: Any] ?? [:])
           let blur = parseStepIcon(from: dictionary["blur"] as? [String: Any] ?? [:])
           let header = parseStepIcon(from: dictionary["header"] as? [String: Any] ?? [:])
           let footer = parseStepIcon(from: dictionary["footer"] as? [String: Any] ?? [:])
           
           return BackgroundIcons(
               main: main,
               layer1: layer1,
               layer2: layer2,
               layer3: layer3,
               blur: blur,
               header: header,
               footer: footer
           )
       }

       // MARK: - Popup Icons Parser

       func parsePopupIcons(from dictionary: [String: Any]) -> PopupIcons {
           let background = parseStepIcon(from: dictionary["background"] as? [String: Any] ?? [:])
           let warningIcon = parseStepIcon(from: dictionary["warningIcon"] as? [String: Any] ?? [:])
           let errorIcon = parseStepIcon(from: dictionary["errorIcon"] as? [String: Any] ?? [:])
           let successIcon = parseStepIcon(from: dictionary["successIcon"] as? [String: Any] ?? [:])
           let errorSign = parseStepIcon(from: dictionary["errorSign"] as? [String: Any] ?? [:])
           let successSign = parseStepIcon(from: dictionary["successSign"] as? [String: Any] ?? [:])
           let warningSign = parseStepIcon(from: dictionary["warningSign"] as? [String: Any] ?? [:])
           
           return PopupIcons(
               background: background,
               warningIcon: warningIcon,
               errorIcon: errorIcon,
               successIcon: successIcon,
               errorSign: errorSign,
               successSign: successSign,
               warningSign: warningSign
           )
       }

       // MARK: - Field Icons Parser
    
       func parseFieldIcons(from dictionary: [String: Any]) -> FieldIcons {
           let user = parseStepIcon(from: dictionary["user"] as? [String: Any] ?? [:])
           let calendar = parseStepIcon(from: dictionary["calendar"] as? [String: Any] ?? [:])
           let gender = parseStepIcon(from: dictionary["gender"] as? [String: Any] ?? [:])
           let issuingAuthority = parseStepIcon(from: dictionary["issuingAuthority"] as? [String: Any] ?? [:])
           let nationality = parseStepIcon(from: dictionary["nationality"] as? [String: Any] ?? [:])
           let num = parseStepIcon(from: dictionary["num"] as? [String: Any] ?? [:])
           let passport = parseStepIcon(from: dictionary["passport"] as? [String: Any] ?? [:])
           let address = parseStepIcon(from: dictionary["address"] as? [String: Any] ?? [:])
           let idCard = parseStepIcon(from: dictionary["idCard"] as? [String: Any] ?? [:])
           let profession = parseStepIcon(from: dictionary["profession"] as? [String: Any] ?? [:])
           let religion = parseStepIcon(from: dictionary["religion"] as? [String: Any] ?? [:])
           let maritalStatus = parseStepIcon(from: dictionary["maritalStatus"] as? [String: Any] ?? [:])
           
           return FieldIcons(
               user: user,
               calendar: calendar,
               gender: gender,
               issuingAuthority: issuingAuthority,
               nationality: nationality,
               num: num,
               passport: passport,
               address: address,
               idCard: idCard,
               profession: profession,
               religion: religion,
               maritalStatus: maritalStatus
           )
       }

       // MARK: - UI Icons Parser

       func parseUiIcons(from dictionary: [String: Any]) -> UiIcons {
           let visibility = parseStepIcon(from: dictionary["visibility"] as? [String: Any] ?? [:])
           let visibilityOff = parseStepIcon(from: dictionary["visibilityOff"] as? [String: Any] ?? [:])
           let mobile = parseStepIcon(from: dictionary["mobile"] as? [String: Any] ?? [:])
           let mail = parseStepIcon(from: dictionary["mail"] as? [String: Any] ?? [:])
           let answer = parseStepIcon(from: dictionary["answer"] as? [String: Any] ?? [:])
           let error = parseStepIcon(from: dictionary["error"] as? [String: Any] ?? [:])
           let info = parseStepIcon(from: dictionary["info"] as? [String: Any] ?? [:])
           let edit = parseStepIcon(from: dictionary["edit"] as? [String: Any] ?? [:])
           let activePhone = parseStepIcon(from: dictionary["activePhone"] as? [String: Any] ?? [:])
           
           return UiIcons(
               visibility: visibility,
               visibilityOff: visibilityOff,
               mobile: mobile,
               mail: mail,
               answer: answer,
               error: error,
               info: info,
               edit: edit,
               activePhone: activePhone
           )
       }

       // MARK: - Common Icons Parser

       func parseCommonIcons(from dictionary: [String: Any]) -> CommonIcons {
           let backgroundsDict = dictionary["backgrounds"] as? [String: Any] ?? [:]
           let backgrounds = parseBackgroundIcons(from: backgroundsDict)
           
           let popupsDict = dictionary["popups"] as? [String: Any] ?? [:]
           let popups = parsePopupIcons(from: popupsDict)
           
           let fieldIconsDict = dictionary["fieldIcons"] as? [String: Any] ?? [:]
           let fieldIcons = parseFieldIcons(from: fieldIconsDict)
           
           let uiDict = dictionary["ui"] as? [String: Any] ?? [:]
           let ui = parseUiIcons(from: uiDict)
           
           let termsAndConditions = parseStepIcon(from: dictionary["termsAndConditions"] as? [String: Any] ?? [:])
           
           return CommonIcons(
               backgrounds: backgrounds,
               popups: popups,
               fieldIcons: fieldIcons,
               ui: ui,
               termsAndConditions: termsAndConditions
           )
       }

       // MARK: - Update Icons Parser

       func parseUpdateIcons(from dictionary: [String: Any]) -> UpdateIcons {
           let modeIcon = parseStepIcon(from: dictionary["modeIcon"] as? [String: Any] ?? [:])
           let idCard = parseStepIcon(from: dictionary["idCard"] as? [String: Any] ?? [:])
           let passport = parseStepIcon(from: dictionary["passport"] as? [String: Any] ?? [:])
           let mobile = parseStepIcon(from: dictionary["mobile"] as? [String: Any] ?? [:])
           let email = parseStepIcon(from: dictionary["email"] as? [String: Any] ?? [:])
           let device = parseStepIcon(from: dictionary["device"] as? [String: Any] ?? [:])
           let address = parseStepIcon(from: dictionary["address"] as? [String: Any] ?? [:])
           let securityQuestions = parseStepIcon(from: dictionary["securityQuestions"] as? [String: Any] ?? [:])
           let password = parseStepIcon(from: dictionary["password"] as? [String: Any] ?? [:])
           
           return UpdateIcons(
               modeIcon: modeIcon,
               idCard: idCard,
               passport: passport,
               mobile: mobile,
               email: email,
               device: device,
               address: address,
               securityQuestions: securityQuestions,
               password: password
           )
       }

       // MARK: - Forget Icons Parser

       func parseForgetIcons(from dictionary: [String: Any]) -> ForgetIcons {
           let modeIcon = parseStepIcon(from: dictionary["modeIcon"] as? [String: Any] ?? [:])
           let nationalId = parseStepIcon(from: dictionary["nationalId"] as? [String: Any] ?? [:])
           let passport = parseStepIcon(from: dictionary["passport"] as? [String: Any] ?? [:])
           let phone = parseStepIcon(from: dictionary["phone"] as? [String: Any] ?? [:])
           let email = parseStepIcon(from: dictionary["email"] as? [String: Any] ?? [:])
           let device = parseStepIcon(from: dictionary["device"] as? [String: Any] ?? [:])
           let location = parseStepIcon(from: dictionary["location"] as? [String: Any] ?? [:])
           let securityQuestions = parseStepIcon(from: dictionary["securityQuestions"] as? [String: Any] ?? [:])
           let password = parseStepIcon(from: dictionary["password"] as? [String: Any] ?? [:])
           
           return ForgetIcons(
               modeIcon: modeIcon,
               nationalId: nationalId,
               passport: passport,
               phone: phone,
               email: email,
               device: device,
               location: location,
               securityQuestions: securityQuestions,
               password: password
           )
       }

    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
