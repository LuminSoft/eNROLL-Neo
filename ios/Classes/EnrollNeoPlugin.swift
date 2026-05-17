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
            var contractTemplateId:Int?
            var signContarctParam: String?
            var exitStep:EnrollFramework.StepType?
           // var enrolltheme : EnrollTheme?
            
            
            if let data = json.data(using: .utf8){
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                if let dict = jsonObject as? [String: Any] {
                    tenatId = dict["tenantId"] as? String ?? ""
                    tenantSecret = dict["tenantSecret"] as? String ?? ""
                    if let colors = dict["colors"] as? [String: Any]{
                        enrollColors = generateDynamicColors(colors: colors)
                    }
//                      if let theme = dict["theme"] as? [String: Any]{
//                        enrolltheme = generateDynamicTheme(theme:theme)
//                      }
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
                        contractTemplateId = Int(contractId)
                    }
                    if let contractParam =  dict["contractParameters"] as? String {
                        signContarctParam = contractParam
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
            
            UIApplication.shared.delegate?.window??.rootViewController?.present(try Enroll.initViewController(enrollInitModel: EnrollInitModel(tenantId: tenatId, tenantSecret: tenantSecret, enrollEnviroment: enrollEnvironment, localizationCode: localizationCode, enrollCallBack: self, enrollMode: mode ?? .onboarding, skipTutorial: skip ?? false, enrollColors: enrollColors, levelOffTrustId: levelOfTrust, applicantId: applicantId, correlationId: correlationId,forcedDocumentType: enrollForcedDocumentType,requestId: requestId,contractTemplateId:contractTemplateId,signContarctParam: signContarctParam, exitStep: exitStep ), presenterVC: (UIApplication.shared.delegate?.window??.rootViewController!)!), animated: true)
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
//     func generateDynamicTheme(theme: [String: Any]?) -> EnrollTheme {
//            guard let theme = theme else {
//                return EnrollTheme()
//            }
//
//            // Extract colors if provided in theme
//            var enrollColors: EnrollColors?
//            if let colorDict = theme["colors"] as? [String: Any] {
//                enrollColors = generateDynamicColors(colors: colorDict)
//            }
//
//            // Extract icons if provided in theme
//            var appIcons = AppIcons()
//            if let iconsDict = theme["icons"] as? [String: Any] {
//                appIcons = generateAppIcons(from: iconsDict)
//            }
//
//            return EnrollTheme(icons: appIcons, colors: enrollColors)
//        }
//
//        // MARK: - Generate AppIcons from Dictionary
//
//        func generateAppIcons(from dictionary: [String: Any]) -> AppIcons {
//            var logo = LogoConfig()
//            var location = LocationIcons()
//            var nationalId: NationalIdIcons?
//            var passport = PassportIcons()
//            var phone = PhoneIcons()
//            var email = EmailIcons()
//            var faceMatching = FaceMatchingIcons()
//            var securityQuestions = SecurityQuestionsIcons()
//            var password = PasswordIcons()
//            var signature = SignatureIcons()
//            var common = CommonIcons()
//            var update = UpdateIcons()
//            var forget = ForgetIcons()
//
//            // Parse logo configuration
//            if let logoDict = dictionary["logo"] as? [String: Any] {
//                logo = parseLogoConfig(from: logoDict)
//            }
//
//            // Parse location icons
//            if let locationDict = dictionary["location"] as? [String: Any] {
//                location = parseLocationIcons(from: locationDict)
//            }
//
//            // Parse national ID icons
//            if let nationalIdDict = dictionary["nationalId"] as? [String: Any] {
//                nationalId = parseNationalIdIcons(from: nationalIdDict)
//            }
//
//            // Parse passport icons
//            if let passportDict = dictionary["passport"] as? [String: Any] {
//                passport = parsePassportIcons(from: passportDict)
//            }
//
//            // Parse phone icons
//            if let phoneDict = dictionary["phone"] as? [String: Any] {
//                phone = parsePhoneIcons(from: phoneDict)
//            }
//
//            // Parse email icons
//            if let emailDict = dictionary["email"] as? [String: Any] {
//                email = parseEmailIcons(from: emailDict)
//            }
//
//            // Parse face matching icons
//            if let faceMatchingDict = dictionary["faceMatching"] as? [String: Any] {
//                faceMatching = parseFaceMatchingIcons(from: faceMatchingDict)
//            }
//
//            // Parse security questions icons
//            if let securityQuestionsDict = dictionary["securityQuestions"] as? [String: Any] {
//                securityQuestions = parseSecurityQuestionsIcons(from: securityQuestionsDict)
//            }
//
//            // Parse password icons
//            if let passwordDict = dictionary["password"] as? [String: Any] {
//                password = parsePasswordIcons(from: passwordDict)
//            }
//
//            // Parse signature icons
//            if let signatureDict = dictionary["signature"] as? [String: Any] {
//                signature = parseSignatureIcons(from: signatureDict)
//            }
//
//            // Parse common icons
//            if let commonDict = dictionary["common"] as? [String: Any] {
//                common = parseCommonIcons(from: commonDict)
//            }
//
//            // Parse update icons
//            if let updateDict = dictionary["update"] as? [String: Any] {
//                update = parseUpdateIcons(from: updateDict)
//            }
//
//            // Parse forget icons
//            if let forgetDict = dictionary["forget"] as? [String: Any] {
//                forget = parseForgetIcons(from: forgetDict)
//            }
//
//            return AppIcons(
//                logo: logo,
//                location: location,
//                nationalId: nationalId,
//                passport: passport,
//                phone: phone,
//                email: email,
//                faceMatching: faceMatching,
//                securityQuestions: securityQuestions,
//                password: password,
//                signature: signature,
//                common: common,
//                update: update,
//                forget: forget
//            )
//        }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
