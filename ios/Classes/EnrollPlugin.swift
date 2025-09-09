import Flutter
import UIKit
import EnrollFramework

public class EnrollPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, EnrollCallBack {
    
    
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
        let channel = FlutterMethodChannel(name: "enroll_plugin", binaryMessenger: registrar.messenger())
        let eventChannelName = "enroll_plugin_channel"
        let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: registrar.messenger())
        
        let instance = EnrollPlugin()
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
            
            
            if let data = json.data(using: .utf8){
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                if let dict = jsonObject as? [String: Any] {
                    tenatId = dict["tenantId"] as? String ?? ""
                    tenantSecret = dict["tenantSecret"] as? String ?? ""
                    if let colors = dict["colors"] as? [String: Any]{
                        enrollColors = generateDynamicColors(colors: colors)
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
            
            UIApplication.shared.delegate?.window??.rootViewController?.present(try Enroll.initViewController(enrollInitModel: EnrollInitModel(tenantId: tenatId, tenantSecret: tenantSecret, enrollEnviroment: enrollEnvironment, localizationCode: localizationCode, enrollCallBack: self, enrollMode: mode ?? .onboarding, skipTutorial: skip ?? false, enrollColors: enrollColors, levelOffTrustId: levelOfTrust, applicantId: applicantId, correlationId: correlationId,forcedDocumentType: enrollForcedDocumentType,requestId: requestId,contractTemplateId:contractTemplateId,signContarctParam: signContarctParam ), presenterVC: (UIApplication.shared.delegate?.window??.rootViewController!)!), animated: true)
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
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
