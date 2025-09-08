package com.example.enroll_plugin

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.compose.ui.graphics.Color
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.luminsoft.enroll_sdk.core.models.*
import com.luminsoft.enroll_sdk.sdk.eNROLL
import com.luminsoft.enroll_sdk.ui_components.theme.AppColors
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

/** EnrollPlugin */
class EnrollPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var context: Context
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "enroll_plugin")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "enroll_plugin_channel")
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
            Log.e("EnrollPlugin", "Error converting map to JSON string: ${e.message}")
            "unexpected_error"
        }
    }


    private fun handleStartEnroll(call: MethodCall, result: MethodChannel.Result) {
        if (activity == null) {
            Log.e("EnrollPlugin", "Activity is null, cannot start enrollment")
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

            // Check if "colors" field is present and not null
            val appColors = if (jsonObject.has("colors") && !jsonObject.get("colors").isJsonNull) {
                val enrollColorsJson = jsonObject.get("colors").toString()
                val enrollColors = processEnrollColorsJson(enrollColorsJson)
                convertEnrollColorsToAppColors(enrollColors, defaultAppColors)
            } else {
                // Use defaultAppColors if "colors" field is not present
                defaultAppColors
            }


            Log.d("EnrollPlugin", "tenantId is $tenantId")
            Log.d("EnrollPlugin", "tenantSecret is $tenantSecret")
            Log.d("EnrollPlugin", "applicationId is $applicationId")
            Log.d("EnrollPlugin", "requestId is $requestId")
            Log.d("EnrollPlugin", "levelOfTrust is $levelOfTrust")
            Log.d("EnrollPlugin", "skipTutorial is $skipTutorial")
            Log.d("EnrollPlugin", "correlationId is $correlationId")
            Log.d("EnrollPlugin", "templateId is $templateId")
            Log.d("EnrollPlugin", "contractParameters is $contractParameters")
            Log.d("EnrollPlugin", "googleApiKey is $googleApiKey")
            Log.d("EnrollPlugin", "enrollEnvironment is $enrollEnvironment")
            Log.d("EnrollPlugin", "enrollMode is $enrollMode")
            Log.d("EnrollPlugin", "localizationCode is $localizationCode")
            Log.d("EnrollPlugin", "appColors is $appColors")

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
                        Log.d("EnrollPlugin", "eNROLL Message: ${enrollSuccessModel.enrollMessage}")
                        val eventData = mapOf(
                            "event" to "on_success",
                            "data" to mapOf("applicantId" to enrollSuccessModel.applicantId)
                        )
                        eventSink?.success(mapToJsonString(eventData))
                    }

                    override fun error(enrollFailedModel: EnrollFailedModel) {
                        Log.e("EnrollPlugin", "eNROLL Error: ${enrollFailedModel.failureMessage}")
                        val eventData = mapOf(
                            "event" to "on_error",
                            "data" to mapOf("message" to enrollFailedModel.failureMessage)
                        )
                        eventSink?.success(mapToJsonString(eventData))
                    }

                    override fun getRequestId(requestId: String) {
                        Log.d("EnrollPlugin", "requestId: $requestId")
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
                appColors = appColors,
                enrollForcedDocumentType = enrollForcedDocumentType,
                requestId = requestId,
                templateId = templateId,
                contractParameters = contractParameters
            )

            eNROLL.launch(activity!!)

        } catch (e: Exception) {
            Log.e("EnrollPlugin", "Error in handleStartEnroll: ${e.message}", e)
            eventSink?.error("ENROLLMENT_ERROR", "An error occurred: ${e.message}", null)
        }

    }
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
