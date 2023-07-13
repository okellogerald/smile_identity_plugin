package com.tembo_plus.smile_identity_plugin

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class SmileIdentityPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private var manager = SmileIdentityManager()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    manager.onAttachedToEngine(flutterPluginBinding, this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    return manager.onMethodCall(call, result)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    manager.onDetachedFromEngine()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    manager.initializeActivity(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }
}

open class SmileIdentityMainActivity : FlutterFragmentActivity(), MethodCallHandler {
  private var manager = SmileIdentityManager()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    manager.initializeActivity(this)
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    manager.configureFlutterEngine(flutterEngine, this)
  }

  @Deprecated("Deprecated in Java")
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    manager.onActivityResult(requestCode, resultCode)
  }

  override fun onRequestPermissionsResult(
      requestCode: Int,
      permissions: Array<out String>,
      grantResults: IntArray
  ) {
    super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    manager.onRequestPermissionsResult(requestCode, permissions, grantResults)
  }

  override fun onDetachedFromWindow() {
    super.onDetachedFromWindow()
    manager.onDetachedFromWindow()
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    manager.onMethodCall(call, result)
  }
}
