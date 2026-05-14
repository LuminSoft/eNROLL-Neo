package com.example.enroll_neo_plugin

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.compose.ui.graphics.Color
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.luminsoft.enroll_sdk.core.models.*
import com.luminsoft.enroll_sdk.main.main_data.main_models.get_onboaring_configurations.EkycStepType
import com.luminsoft.enroll_sdk.sdk.eNROLL
import com.luminsoft.enroll_sdk.ui_components.theme.AppColors
import com.luminsoft.enroll_sdk.ui_components.theme.AppIcons
import com.luminsoft.enroll_sdk.ui_components.theme.AppTheme
import com.luminsoft.enroll_sdk.ui_components.theme.BackgroundIcons
import com.luminsoft.enroll_sdk.ui_components.theme.CommonIcons
import com.luminsoft.enroll_sdk.ui_components.theme.EmailIcons
import com.luminsoft.enroll_sdk.ui_components.theme.FaceMatchingIcons
import com.luminsoft.enroll_sdk.ui_components.theme.FieldIcons
import com.luminsoft.enroll_sdk.ui_components.theme.ForgetIcons
import com.luminsoft.enroll_sdk.ui_components.theme.IconRenderingMode
import com.luminsoft.enroll_sdk.ui_components.theme.IconSource
import com.luminsoft.enroll_sdk.ui_components.theme.LocationIcons
import com.luminsoft.enroll_sdk.ui_components.theme.LogoConfig
import com.luminsoft.enroll_sdk.ui_components.theme.LogoMode
import com.luminsoft.enroll_sdk.ui_components.theme.NationalIdIcons
import com.luminsoft.enroll_sdk.ui_components.theme.PassportIcons
import com.luminsoft.enroll_sdk.ui_components.theme.PasswordIcons
import com.luminsoft.enroll_sdk.ui_components.theme.PhoneIcons
import com.luminsoft.enroll_sdk.ui_components.theme.PopupIcons
import com.luminsoft.enroll_sdk.ui_components.theme.SecurityQuestionsIcons
import com.luminsoft.enroll_sdk.ui_components.theme.SignatureIcons
import com.luminsoft.enroll_sdk.ui_components.theme.StepIcon
import com.luminsoft.enroll_sdk.ui_components.theme.UiIcons
import com.luminsoft.enroll_sdk.ui_components.theme.UpdateIcons
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

/** EnrollNeoPlugin */
class EnrollNeoPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var context: Context
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "enroll_neo_plugin")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "enroll_neo_plugin_channel")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "startEnroll" -> {
                handleStartEnroll(call, result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    fun convertJsonToEnrollColors(json: JSONObject): EnrollColors {
        return EnrollColors(
            primary = json.optJSONObject("primary")?.let { parseDynamicColor(it) },
            secondary = json.optJSONObject("secondary")?.let { parseDynamicColor(it) },
            appBackgroundColor = json.optJSONObject("appBackgroundColor")
                ?.let { parseDynamicColor(it) },
            textColor = json.optJSONObject("textColor")?.let { parseDynamicColor(it) },
            errorColor = json.optJSONObject("errorColor")?.let { parseDynamicColor(it) },
            successColor = json.optJSONObject("successColor")?.let { parseDynamicColor(it) },
            warningColor = json.optJSONObject("warningColor")?.let { parseDynamicColor(it) },
            appWhite = json.optJSONObject("appWhite")?.let { parseDynamicColor(it) },
            appBlack = json.optJSONObject("appBlack")?.let { parseDynamicColor(it) }
        )
    }

    //return null if all values are null
    fun parseDynamicColor(json: JSONObject): DynamicColor? {
        val r = json.optInt("r", -1).takeIf { it != -1 }
        val g = json.optInt("g", -1).takeIf { it != -1 }
        val b = json.optInt("b", -1).takeIf { it != -1 }
        val opacity = json.optDouble("opacity", -1.0).takeIf { it != -1.0 }

        return if (r == null && g == null && b == null && opacity == null) {
            null
        } else {
            DynamicColor(r, g, b, opacity)
        }
    }


    fun convertDynamicColorToColor(dynamicColor: DynamicColor?): Color {
        return dynamicColor?.let {
            Color(
                alpha = (it.opacity ?: 1.0).toFloat(),
                red = (it.r ?: 0) / 255f,
                green = (it.g ?: 0) / 255f,
                blue = (it.b ?: 0) / 255f
            )
        } ?: Color(0xFFFFFFFF) // Default white color if dynamicColor is null
    }


    //only add non-null colors
    fun convertEnrollColorsToAppColors(
        enrollColors: EnrollColors,
        defaultColors: AppColors
    ): AppColors {
        return AppColors(
            primary = enrollColors.primary?.let { convertDynamicColorToColor(it) }
                ?: defaultColors.primary,
            secondary = enrollColors.secondary?.let { convertDynamicColorToColor(it) }
                ?: defaultColors.secondary,
            backGround = enrollColors.appBackgroundColor?.let { convertDynamicColorToColor(it) }
                ?: defaultColors.backGround,
            textColor = enrollColors.textColor?.let { convertDynamicColorToColor(it) }
                ?: defaultColors.textColor,
            errorColor = enrollColors.errorColor?.let { convertDynamicColorToColor(it) }
                ?: defaultColors.errorColor,
            successColor = enrollColors.successColor?.let { convertDynamicColorToColor(it) }
                ?: defaultColors.successColor,
            warningColor = enrollColors.warningColor?.let { convertDynamicColorToColor(it) }
                ?: defaultColors.warningColor,
            white = enrollColors.appWhite?.let { convertDynamicColorToColor(it) }
                ?: defaultColors.white,
            appBlack = enrollColors.appBlack?.let { convertDynamicColorToColor(it) }
                ?: defaultColors.appBlack
        )
    }

    fun processEnrollColorsJson(jsonString: String): EnrollColors {
        val jsonObject = JSONObject(jsonString)
        return convertJsonToEnrollColors(jsonObject)
    }

    fun mapToJsonString(map: Map<String, Any?>): String {
        return try {
            val json = JSONObject(map).toString()
            json
        } catch (e: Exception) {
            Log.e("EnrollNeoPlugin", "Error converting map to JSON string: ${e.message}")
            "unexpected_error"
        }
    }


    private fun getExitStep(step: String): EkycStepType? {
        return when (step) {
            "phoneOtp" -> EkycStepType.PhoneOtp
            "personalConfirmation" -> EkycStepType.PersonalConfirmation
            "smileLiveness" -> EkycStepType.SmileLiveness
            "emailOtp" -> EkycStepType.EmailOtp
            "saveMobileDevice" -> EkycStepType.SaveMobileDevice
            "deviceLocation" -> EkycStepType.DeviceLocation
            "password" -> EkycStepType.SettingPassword
            "securityQuestions" -> EkycStepType.SecurityQuestions
            "amlCheck" -> EkycStepType.AmlCheck
            "termsAndConditions" -> EkycStepType.TermsConditions
            "electronicSignature" -> EkycStepType.ElectronicSignature
            "ntraCheck" -> EkycStepType.NtraCheck
            "csoCheck" -> EkycStepType.CsoCheck
            else -> null
        }
    }

    private fun handleStartEnroll(call: MethodCall, result: MethodChannel.Result) {
        if (activity == null) {
            Log.e("EnrollNeoPlugin", "Activity is null, cannot start enrollment")
            result.error("ACTIVITY_ERROR", "Activity is not available", null)
            return
        }

        val json = call.arguments<String>()

        try {
            val gson = Gson()
            val jsonObject = gson.fromJson(json, JsonObject::class.java)
            val tenantId = jsonObject.get("tenantId")?.asString ?: ""
            val skipTutorial = jsonObject.get("skipTutorial")?.asBoolean ?: false
            val googleApiKey = jsonObject.get("googleApiKey")?.asString ?: ""
            val correlationId = jsonObject.get("correlationId")?.asString ?: ""
            val templateId = jsonObject.get("templateId")?.asString ?: ""
            val contractParameters = jsonObject.get("contractParameters")?.asString ?: ""
            val tenantSecret = jsonObject.get("tenantSecret")?.asString ?: ""
            var applicationId = ""
            if (jsonObject.has("applicationId") && !jsonObject.get("applicationId").isJsonNull) {
                applicationId = jsonObject.get("applicationId").asString
            }
            var requestId = ""
            if (jsonObject.has("requestId") && !jsonObject.get("requestId").isJsonNull) {
                requestId = jsonObject.get("requestId").asString
            }
            var levelOfTrust = ""
            if (jsonObject.has("levelOfTrust") && !jsonObject.get("levelOfTrust").isJsonNull) {
                levelOfTrust = jsonObject.get("levelOfTrust").asString
            }
            val enrollMode = when (jsonObject.get("enrollMode")?.asString) {
                "onboarding" -> {
                    EnrollMode.ONBOARDING
                }

                "auth" -> {
                    EnrollMode.AUTH
                }

                "signContract" -> {
                    EnrollMode.SIGN_CONTRACT
                }

                else -> {
                    EnrollMode.UPDATE
                }
            }
//            Log.d("enrollForcedDocumentType", jsonObject.get("enrollForcedDocumentType")?.asString)

            val enrollForcedDocumentType =
                if (jsonObject.has("enrollForcedDocumentType") && !jsonObject.get("enrollForcedDocumentType").isJsonNull) {
                    when (jsonObject.get("enrollForcedDocumentType")?.asString) {
                        "nationalIdOnly" -> {
                            EnrollForcedDocumentType.NATIONAL_ID_ONLY
                        }

                        "passportOnly" -> {
                            EnrollForcedDocumentType.PASSPORT_ONLY
                        }

                        else -> {
                            EnrollForcedDocumentType.NATIONAL_ID_OR_PASSPORT
                        }
                    }
                } else {
                    EnrollForcedDocumentType.NATIONAL_ID_OR_PASSPORT
                }

            val exitStep = if (jsonObject.has("exitStep") && !jsonObject.get("exitStep").isJsonNull) {
                getExitStep(jsonObject.get("exitStep").asString)
            } else {
                null
            }

            val enrollEnvironment =
                if (jsonObject.get("enrollEnvironment")?.asString == "production") {
                    EnrollEnvironment.PRODUCTION
                } else {
                    EnrollEnvironment.STAGING
                }
            val localizationCode = if (jsonObject.get("localizationCode")?.asString == "ar") {
                LocalizationCode.AR
            } else {
                LocalizationCode.EN
            }

            val defaultAppColors = AppColors(
                primary = Color(0xFF1D56B8),
                secondary = Color(0xff5791DB),
                backGround = Color(0xFFFFFFFF),
                textColor = Color(0xff004194),
                errorColor = Color(0xFFDB305B),
                successColor = Color(0xff61CC3D),
                warningColor = Color(0xFFF9D548),
                white = Color(0xffffffff),
                appBlack = Color(0xff333333)
            )

            // Parse unified theme object (colors + icons)
            val themeJson = if (jsonObject.has("theme") && !jsonObject.get("theme").isJsonNull) {
                JSONObject(jsonObject.get("theme").toString())
            } else {
                null
            }

            // Check if "colors" field is present inside theme or at root level
            val appColors = if (themeJson != null && themeJson.has("colors")) {
                val enrollColorsJson = themeJson.get("colors").toString()
                val enrollColors = processEnrollColorsJson(enrollColorsJson)
                convertEnrollColorsToAppColors(enrollColors, defaultAppColors)
            } else if (jsonObject.has("colors") && !jsonObject.get("colors").isJsonNull) {
                val enrollColorsJson = jsonObject.get("colors").toString()
                val enrollColors = processEnrollColorsJson(enrollColorsJson)
                convertEnrollColorsToAppColors(enrollColors, defaultAppColors)
            } else {
                defaultAppColors
            }


            Log.d("EnrollNeoPlugin", "tenantId is $tenantId")
            Log.d("EnrollNeoPlugin", "tenantSecret is $tenantSecret")
            Log.d("EnrollNeoPlugin", "applicationId is $applicationId")
            Log.d("EnrollNeoPlugin", "requestId is $requestId")
            Log.d("EnrollNeoPlugin", "levelOfTrust is $levelOfTrust")
            Log.d("EnrollNeoPlugin", "skipTutorial is $skipTutorial")
            Log.d("EnrollNeoPlugin", "correlationId is $correlationId")
            Log.d("EnrollNeoPlugin", "templateId is $templateId")
            Log.d("EnrollNeoPlugin", "contractParameters is $contractParameters")
            Log.d("EnrollNeoPlugin", "googleApiKey is $googleApiKey")
            Log.d("EnrollNeoPlugin", "enrollEnvironment is $enrollEnvironment")
            Log.d("EnrollNeoPlugin", "enrollMode is $enrollMode")
            Log.d("EnrollNeoPlugin", "localizationCode is $localizationCode")
            Log.d("EnrollNeoPlugin", "appColors is $appColors")
            Log.d("EnrollNeoPlugin", "exitStep is $exitStep")

            // Parse icons from theme or root level
            val appIcons = if (themeJson != null && themeJson.has("icons")) {
                val iconsJson = JSONObject(themeJson.get("icons").toString())
                parseAppIcons(iconsJson)
            } else if (jsonObject.has("icons") && !jsonObject.get("icons").isJsonNull) {
                val iconsJson = JSONObject(jsonObject.get("icons").toString())
                parseAppIcons(iconsJson)
            } else {
                AppIcons()
            }

            val appTheme = AppTheme(
                colors = appColors,
                icons = appIcons
            )

            eNROLL.init(
                tenantId,
                tenantSecret,
                applicationId,
                levelOfTrust,
                enrollMode,
                enrollEnvironment,
                localizationCode = localizationCode,
                object : EnrollCallback {
                    override fun success(enrollSuccessModel: EnrollSuccessModel) {
                        Log.d("EnrollNeoPlugin", "eNROLL Message: ${enrollSuccessModel.enrollMessage}")
                        val eventData = mapOf(
                            "event" to "on_success",
                            "data" to mapOf("applicantId" to enrollSuccessModel.applicantId)
                        )
                        eventSink?.success(mapToJsonString(eventData))
                    }

                    override fun error(enrollFailedModel: EnrollFailedModel) {
                        Log.e("EnrollNeoPlugin", "eNROLL Error: ${enrollFailedModel.failureMessage}")
                        val eventData = mapOf(
                            "event" to "on_error",
                            "data" to mapOf("message" to enrollFailedModel.failureMessage)
                        )
                        eventSink?.success(mapToJsonString(eventData))
                    }

                    override fun getRequestId(requestId: String) {
                        Log.d("EnrollNeoPlugin", "requestId: $requestId")
                        val eventData = mapOf(
                            "event" to "on_request_id",
                            "data" to mapOf("requestId" to requestId)
                        )
                        eventSink?.success(mapToJsonString(eventData))
                    }
                },
                googleApiKey = googleApiKey,
                skipTutorial = skipTutorial,
                correlationId = correlationId,
                appTheme = appTheme,
                enrollForcedDocumentType = enrollForcedDocumentType,
                requestId = requestId,
                templateId = templateId,
                contractParameters = contractParameters,
                exitStep = exitStep
            )

            eNROLL.launch(activity!!)

        } catch (e: Exception) {
            Log.e("EnrollNeoPlugin", "Error in handleStartEnroll: ${e.message}", e)
            eventSink?.error("ENROLLMENT_ERROR", "An error occurred: ${e.message}", null)
        }

    }

    // -----------------------------------------------------------------------
    // Icon JSON parsing
    // -----------------------------------------------------------------------

    private fun resolveDrawableName(name: String): Int {
        val resId = context.resources.getIdentifier(name, "drawable", context.packageName)
        if (resId == 0) {
            Log.w("EnrollNeoPlugin", "Drawable not found: $name")
        }
        return resId
    }

    private fun parseStepIcon(json: JSONObject): StepIcon? {
        val assetName = json.optString("assetName", "").takeIf { it.isNotEmpty() } ?: return null
        val resId = resolveDrawableName(assetName)
        if (resId == 0) return null
        val renderingMode = when (json.optString("renderingMode", "original")) {
            "template" -> IconRenderingMode.TEMPLATE
            else -> IconRenderingMode.ORIGINAL
        }
        return StepIcon(source = IconSource.Resource(resId), renderingMode = renderingMode)
    }

    private fun parseLogoConfig(json: JSONObject): LogoConfig {
        val mode = when (json.optString("mode", "defaultLogo")) {
            "custom" -> LogoMode.CUSTOM
            "hidden" -> LogoMode.HIDDEN
            else -> LogoMode.DEFAULT
        }
        val assetName = json.optString("assetName", "").takeIf { it.isNotEmpty() }
        val asset = assetName?.let {
            val resId = resolveDrawableName(it)
            if (resId != 0) IconSource.Resource(resId) else null
        }
        val renderingMode = when (json.optString("renderingMode", "original")) {
            "template" -> IconRenderingMode.TEMPLATE
            else -> IconRenderingMode.ORIGINAL
        }
        return LogoConfig(mode = mode, asset = asset, renderingMode = renderingMode)
    }

    private fun parseAppIcons(json: JSONObject): AppIcons {
        return AppIcons(
            logo = json.optJSONObject("logo")?.let { parseLogoConfig(it) } ?: LogoConfig(),
            location = json.optJSONObject("location")?.let { parseLocationIcons(it) } ?: LocationIcons(),
            nationalId = json.optJSONObject("nationalId")?.let { parseNationalIdIcons(it) } ?: NationalIdIcons(),
            passport = json.optJSONObject("passport")?.let { parsePassportIcons(it) } ?: PassportIcons(),
            phone = json.optJSONObject("phone")?.let { parsePhoneIcons(it) } ?: PhoneIcons(),
            email = json.optJSONObject("email")?.let { parseEmailIcons(it) } ?: EmailIcons(),
            faceMatching = json.optJSONObject("faceMatching")?.let { parseFaceMatchingIcons(it) } ?: FaceMatchingIcons(),
            securityQuestions = json.optJSONObject("securityQuestions")?.let { parseSecurityQuestionsIcons(it) } ?: SecurityQuestionsIcons(),
            password = json.optJSONObject("password")?.let { parsePasswordIcons(it) } ?: PasswordIcons(),
            signature = json.optJSONObject("signature")?.let { parseSignatureIcons(it) } ?: SignatureIcons(),
            common = json.optJSONObject("common")?.let { parseCommonIcons(it) } ?: CommonIcons(),
            update = json.optJSONObject("update")?.let { parseUpdateIcons(it) } ?: UpdateIcons(),
            forget = json.optJSONObject("forget")?.let { parseForgetIcons(it) } ?: ForgetIcons(),
        )
    }

    private fun parseLocationIcons(json: JSONObject) = LocationIcons(
        tutorial = json.optJSONObject("tutorial")?.let { parseStepIcon(it) },
        requestAccess = json.optJSONObject("requestAccess")?.let { parseStepIcon(it) },
        accessError = json.optJSONObject("accessError")?.let { parseStepIcon(it) },
        grab = json.optJSONObject("grab")?.let { parseStepIcon(it) },
    )

    private fun parseNationalIdIcons(json: JSONObject) = NationalIdIcons(
        tutorial = json.optJSONObject("tutorial")?.let { parseStepIcon(it) },
        tutorialIdOrPassport = json.optJSONObject("tutorialIdOrPassport")?.let { parseStepIcon(it) },
        preScan = json.optJSONObject("preScan")?.let { parseStepIcon(it) },
        scanError = json.optJSONObject("scanError")?.let { parseStepIcon(it) },
        choose = json.optJSONObject("choose")?.let { parseStepIcon(it) },
    )

    private fun parsePassportIcons(json: JSONObject) = PassportIcons(
        tutorial = json.optJSONObject("tutorial")?.let { parseStepIcon(it) },
        preScan = json.optJSONObject("preScan")?.let { parseStepIcon(it) },
        ePassportPreScan = json.optJSONObject("ePassportPreScan")?.let { parseStepIcon(it) },
        choose = json.optJSONObject("choose")?.let { parseStepIcon(it) },
    )

    private fun parsePhoneIcons(json: JSONObject) = PhoneIcons(
        tutorial = json.optJSONObject("tutorial")?.let { parseStepIcon(it) },
        select = json.optJSONObject("select")?.let { parseStepIcon(it) },
        validateOtp = json.optJSONObject("validateOtp")?.let { parseStepIcon(it) },
    )

    private fun parseEmailIcons(json: JSONObject) = EmailIcons(
        tutorial = json.optJSONObject("tutorial")?.let { parseStepIcon(it) },
        select = json.optJSONObject("select")?.let { parseStepIcon(it) },
        validateOtp = json.optJSONObject("validateOtp")?.let { parseStepIcon(it) },
    )

    private fun parseFaceMatchingIcons(json: JSONObject) = FaceMatchingIcons(
        tutorial = json.optJSONObject("tutorial")?.let { parseStepIcon(it) },
        preScan = json.optJSONObject("preScan")?.let { parseStepIcon(it) },
        error = json.optJSONObject("error")?.let { parseStepIcon(it) },
    )

    private fun parseSecurityQuestionsIcons(json: JSONObject) = SecurityQuestionsIcons(
        tutorial = json.optJSONObject("tutorial")?.let { parseStepIcon(it) },
        authScreen = json.optJSONObject("authScreen")?.let { parseStepIcon(it) },
    )

    private fun parsePasswordIcons(json: JSONObject) = PasswordIcons(
        tutorial = json.optJSONObject("tutorial")?.let { parseStepIcon(it) },
        authScreen = json.optJSONObject("authScreen")?.let { parseStepIcon(it) },
    )

    private fun parseSignatureIcons(json: JSONObject) = SignatureIcons(
        tutorial = json.optJSONObject("tutorial")?.let { parseStepIcon(it) },
    )

    private fun parseCommonIcons(json: JSONObject) = CommonIcons(
        backgrounds = json.optJSONObject("backgrounds")?.let { parseBackgroundIcons(it) } ?: BackgroundIcons(),
        popups = json.optJSONObject("popups")?.let { parsePopupIcons(it) } ?: PopupIcons(),
        fieldIcons = json.optJSONObject("fieldIcons")?.let { parseFieldIcons(it) } ?: FieldIcons(),
        ui = json.optJSONObject("ui")?.let { parseUiIcons(it) } ?: UiIcons(),
        termsAndConditions = json.optJSONObject("termsAndConditions")?.let { parseStepIcon(it) },
    )

    private fun parseBackgroundIcons(json: JSONObject) = BackgroundIcons(
        main = json.optJSONObject("main")?.let { parseStepIcon(it) },
        layer1 = json.optJSONObject("layer1")?.let { parseStepIcon(it) },
        layer2 = json.optJSONObject("layer2")?.let { parseStepIcon(it) },
        layer3 = json.optJSONObject("layer3")?.let { parseStepIcon(it) },
        blur = json.optJSONObject("blur")?.let { parseStepIcon(it) },
        header = json.optJSONObject("header")?.let { parseStepIcon(it) },
        footer = json.optJSONObject("footer")?.let { parseStepIcon(it) },
    )

    private fun parsePopupIcons(json: JSONObject) = PopupIcons(
        background = json.optJSONObject("background")?.let { parseStepIcon(it) },
        warningIcon = json.optJSONObject("warningIcon")?.let { parseStepIcon(it) },
        errorIcon = json.optJSONObject("errorIcon")?.let { parseStepIcon(it) },
        successIcon = json.optJSONObject("successIcon")?.let { parseStepIcon(it) },
    )

    private fun parseFieldIcons(json: JSONObject) = FieldIcons(
        user = json.optJSONObject("user")?.let { parseStepIcon(it) },
        calendar = json.optJSONObject("calendar")?.let { parseStepIcon(it) },
        gender = json.optJSONObject("gender")?.let { parseStepIcon(it) },
        issuingAuthority = json.optJSONObject("issuingAuthority")?.let { parseStepIcon(it) },
        nationality = json.optJSONObject("nationality")?.let { parseStepIcon(it) },
        num = json.optJSONObject("num")?.let { parseStepIcon(it) },
        passport = json.optJSONObject("passport")?.let { parseStepIcon(it) },
        address = json.optJSONObject("address")?.let { parseStepIcon(it) },
        idCard = json.optJSONObject("idCard")?.let { parseStepIcon(it) },
        profession = json.optJSONObject("profession")?.let { parseStepIcon(it) },
        religion = json.optJSONObject("religion")?.let { parseStepIcon(it) },
        maritalStatus = json.optJSONObject("maritalStatus")?.let { parseStepIcon(it) },
    )

    private fun parseUiIcons(json: JSONObject) = UiIcons(
        visibility = json.optJSONObject("visibility")?.let { parseStepIcon(it) },
        visibilityOff = json.optJSONObject("visibilityOff")?.let { parseStepIcon(it) },
        mobile = json.optJSONObject("mobile")?.let { parseStepIcon(it) },
        mail = json.optJSONObject("mail")?.let { parseStepIcon(it) },
        answer = json.optJSONObject("answer")?.let { parseStepIcon(it) },
        error = json.optJSONObject("error")?.let { parseStepIcon(it) },
        info = json.optJSONObject("info")?.let { parseStepIcon(it) },
        edit = json.optJSONObject("edit")?.let { parseStepIcon(it) },
        activePhone = json.optJSONObject("activePhone")?.let { parseStepIcon(it) },
    )

    private fun parseUpdateIcons(json: JSONObject) = UpdateIcons(
        modeIcon = json.optJSONObject("modeIcon")?.let { parseStepIcon(it) },
        idCard = json.optJSONObject("idCard")?.let { parseStepIcon(it) },
        passport = json.optJSONObject("passport")?.let { parseStepIcon(it) },
        mobile = json.optJSONObject("mobile")?.let { parseStepIcon(it) },
        email = json.optJSONObject("email")?.let { parseStepIcon(it) },
        device = json.optJSONObject("device")?.let { parseStepIcon(it) },
        address = json.optJSONObject("address")?.let { parseStepIcon(it) },
        securityQuestions = json.optJSONObject("securityQuestions")?.let { parseStepIcon(it) },
        password = json.optJSONObject("password")?.let { parseStepIcon(it) },
    )

    private fun parseForgetIcons(json: JSONObject) = ForgetIcons(
        modeIcon = json.optJSONObject("modeIcon")?.let { parseStepIcon(it) },
        nationalId = json.optJSONObject("nationalId")?.let { parseStepIcon(it) },
        passport = json.optJSONObject("passport")?.let { parseStepIcon(it) },
        phone = json.optJSONObject("phone")?.let { parseStepIcon(it) },
        email = json.optJSONObject("email")?.let { parseStepIcon(it) },
        device = json.optJSONObject("device")?.let { parseStepIcon(it) },
        location = json.optJSONObject("location")?.let { parseStepIcon(it) },
        securityQuestions = json.optJSONObject("securityQuestions")?.let { parseStepIcon(it) },
        password = json.optJSONObject("password")?.let { parseStepIcon(it) },
    )
}

data class EnrollColors(
    val primary: DynamicColor?,
    val secondary: DynamicColor?,
    val appBackgroundColor: DynamicColor?,
    val textColor: DynamicColor?,
    val errorColor: DynamicColor?,
    val successColor: DynamicColor?,
    val warningColor: DynamicColor?,
    val appWhite: DynamicColor?,
    val appBlack: DynamicColor?
)

data class DynamicColor(
    val r: Int?,
    val g: Int?,
    val b: Int?,
    val opacity: Double?
)
