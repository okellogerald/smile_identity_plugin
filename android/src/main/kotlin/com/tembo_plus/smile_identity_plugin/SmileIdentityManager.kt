package com.tembo_plus.smile_identity_plugin

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.text.TextUtils
import android.widget.Toast
import checkForCameraPermission
import com.smileid.smileidui.CaptureType
import com.smileid.smileidui.SIDCaptureManager
import com.smileid.smileidui.SIDIDCaptureConfig
import com.smileid.smileidui.SIDSelfieCaptureConfig
import com.smileidentity.libsmileid.core.RetryOnFailurePolicy
import com.smileidentity.libsmileid.core.SIDConfig
import com.smileidentity.libsmileid.core.SIDNetworkRequest
import com.smileidentity.libsmileid.model.SIDMetadata
import com.smileidentity.libsmileid.model.SIDNetData
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.TimeUnit
import java.util.regex.Pattern
import requestCameraPermission

class SmileData(
    val userId: String,
    val jobId: String,
    val country: String,
    val idType: String,
    val idNumber: String,
    val firstName: String,
    val lastName: String,
    val tag: String,
    val jobType: Int,
    val environment: SIDNetData.Environment,
    val additionalValues: Map<String, Any>?,
    val callbackUrl: String,
)

class SmileIdentityManager {
  private lateinit var channel: MethodChannel
  private lateinit var request: SIDNetworkRequest
  private lateinit var activity: Activity
  private lateinit var smileData: SmileData
  private lateinit var result: Result

  fun onConfigureFlutterEngine(flutterEngine: FlutterEngine, handler: MethodCallHandler) {
    val messenger = flutterEngine.dartExecutor.binaryMessenger
    channel = MethodChannel(messenger, "smile_identity_plugin")
    channel.setMethodCallHandler(handler)
  }

  fun onAttachedToEngine(
      flutterPluginBinding: FlutterPlugin.FlutterPluginBinding,
      handler: MethodCallHandler,
  ) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "smile_identity_plugin")
    channel.setMethodCallHandler(handler)
  }

  fun onDetachedFromWindow() {
    channel.setMethodCallHandler(null)
  }

  fun onDetachedFromEngine() {
    onDetachedFromWindow()
  }

  fun onMethodCall(call: MethodCall, _result: Result) {
    result = _result

    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "check_camera" -> {
        val granted = checkForCameraPermission(activity)
        result.success(granted)
//        if (!granted) {
//          result.success("Success = True")
//          //channel.invokeMethod("permission_state", mapOf("success" to false))
//          // result.error("1000", "Camera Permission Not Granted!", null)
//        }
      }
      "request_camera_permission" -> {
        requestCameraPermission(activity)
        result.success("requesting camera permission")
      }
      "capture" -> {
        val args = call.arguments<Map<String, Any>>() as Map<String, Any>
        val tag = (args["tag"] ?: "") as String
        val captureType =
            when ((args["captureType"] ?: "") as String) {
              "SELFIE" -> CaptureType.SELFIE
              "ID_CAPTURE" -> CaptureType.ID_CAPTURE
              "SELFIE_AND_ID_CAPTURE" -> CaptureType.SELFIE_AND_ID_CAPTURE
              "ID_CAPTURE_AND_SELFIE" -> CaptureType.ID_CAPTURE_AND_SELFIE
              else -> CaptureType.SELFIE_AND_ID_CAPTURE
            }
        captureSelfie(tag, captureType)
        result.success("Capturing Images")
      }
      "submit" -> {
        getSmileDataFrom(call.arguments<Map<String, Any>>() as Map<String, Any>)
        showMessage("Submitting job...")
        submitJob()
        result.success("Submitting Job")
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun captureSelfie(tag: String, captureType: CaptureType) {
    try {
      val validTag = isTagFormatValid(tag)
      if (!validTag) throw Exception("You have passed an invalid tag")

      val granted = checkForCameraPermission(activity)
      if (!granted) {
        throw Exception("Camera Permission Not Granted")
      }

      val builder = SIDCaptureManager.Builder(activity, captureType, 1000 + captureType.ordinal)
      builder.setTag(tag)

      val selfieCaptureConfig = (SIDSelfieCaptureConfig.Builder()).build()
      val idCaptureConfig = (SIDIDCaptureConfig.Builder()).build()

      builder.setSidSelfieConfig(selfieCaptureConfig)
      builder.setSidIdCaptureConfig(idCaptureConfig)
      builder.build().start()
    } catch (e: Exception) {
      channel.invokeMethod("capture_state", mapOf("success" to false))
      showMessage("Error: ${e.message}")
    }
  }

  private fun submitJob() {
    try {
      val data = SIDNetData(this.activity, smileData.environment)
      data.callBackUrl = smileData.callbackUrl

      val meta = SIDMetadata()
      meta.sidUserIdInfo.countryCode = smileData.country
      meta.sidUserIdInfo.firstName = smileData.firstName
      meta.sidUserIdInfo.lastName = smileData.lastName

      // https://docs.smileidentity.com/supported-id-types/for-individuals-kyc/backed-by-id-authority
      meta.sidUserIdInfo.idType = smileData.idType
      meta.sidUserIdInfo.idNumber = smileData.idNumber

      meta.partnerParams.jobId = smileData.jobId
      meta.partnerParams.jobType = smileData.jobType
      meta.partnerParams.userId = smileData.userId
      if (smileData.additionalValues != null) {
        for (param in smileData.additionalValues!!) {
          meta.partnerParams.additionalValue(param.key, param.value.toString())
        }
      }

      val builder =
          SIDConfig.Builder(activity)
              .setRetryOnfailurePolicy(getRetryOnFailurePolicy())
              .setMode(SIDConfig.Mode.ENROLL)
              .setSmileIdNetData(data)
              .setSIDMetadata(meta)
              .setJobType(smileData.jobType)

      val config = builder.build(smileData.tag)
      request.submit(config)
      channel.invokeMethod("submit_state", mapOf("success" to true))
    } catch (e: Exception) {
      showMessage("${e.message}")
      channel.invokeMethod("submit_state", mapOf("success" to false))
    }
  }

  private fun getRetryOnFailurePolicy(): RetryOnFailurePolicy {
    val retryOnFailurePolicy = RetryOnFailurePolicy()
    retryOnFailurePolicy.setRetryCount(10)
    retryOnFailurePolicy.setRetryTimeout(TimeUnit.SECONDS.toMillis(15))
    return retryOnFailurePolicy
  }

  private fun isTagFormatValid(tag: String?): Boolean {
    return StringUtils.hasSpecialChars(tag)
  }

  fun initializeActivity(_activity: Activity) {
    activity = _activity

    request = SIDNetworkRequest(activity)
    request.setOnCompleteListener { showMessage("Completed!") }
    request.set0nErrorListener { showMessage("An error happened: ${it.message}") }
    request.setOnEnrolledListener { showMessage("You're enrolled") }
  }

  fun onActivityResult(requestCode: Int, resultCode: Int) {
    showMessage("Request Code: $requestCode,Result Code: $resultCode")
    when (requestCode) {
      // errors associated with smile-capture
      1000,
      1001,
      1002,
      1003,
      1004 -> {
        if (resultCode == -1) {
          channel.invokeMethod("capture_state", mapOf("success" to true))
        }
      }
    }
  }

  fun onRequestPermissionsResult(
      requestCode: Int,
      permissions: Array<out String>,
      grantResults: IntArray
  ) {
    when (requestCode) {
      // camera-permission error
      2023 -> {
        val index = permissions.indexOf(Manifest.permission.CAMERA)
        // showMessage("${grantResults[index] == PackageManager.PERMISSION_GRANTED}")
        if (index != -1) {
          if (grantResults[index] == PackageManager.PERMISSION_GRANTED) {
            channel.invokeMethod("permission_state", mapOf("success" to true))
            return
          }
        }
        channel.invokeMethod("permission_state", mapOf("success" to false))
      }
    }
  }

  private fun showMessage(message: String) {
    Toast.makeText(activity, message, Toast.LENGTH_SHORT).show()
  }

  private fun getSmileDataFrom(args: Map<String, Any>) {
    val env = (args["environment"] ?: "TEST") as String
    var environment = SIDNetData.Environment.TEST
    if (env == "PROD") {
      environment = SIDNetData.Environment.PROD
    }
    smileData =
        SmileData(
            userId = (args["userId"] ?: "") as String,
            jobId = (args["jobId"] ?: "") as String,
            country = (args["country"] ?: "") as String,
            idType = (args["idType"] ?: "") as String,
            idNumber = (args["idNumber"] ?: "") as String,
            firstName = (args["firstName"] ?: "") as String,
            lastName = (args["lastName"] ?: "") as String,
            tag = (args["tag"] ?: "") as String,
            jobType = (args["jobType"] ?: 1) as Int,
            environment = environment,
            additionalValues = (args["additionalValues"] ?: "") as Map<String, Any>?,
            callbackUrl = (args["callbackUrl"] ?: "") as String,
        )
  }
}

object StringUtils {
  private const val SPECIAL_CHAR_MATCHER = "^[a-zA-Z0-9_]*$"
  fun hasSpecialChars(search: String?): Boolean {
    val pattern = Pattern.compile(SPECIAL_CHAR_MATCHER, Pattern.CASE_INSENSITIVE)
    if (search == null) return false
    return !TextUtils.isEmpty(search) && pattern.matcher(search).find()
  }
}
