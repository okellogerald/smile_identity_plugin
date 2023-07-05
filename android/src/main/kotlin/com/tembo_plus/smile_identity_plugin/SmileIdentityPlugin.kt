package com.tembo_plus.smile_identity_plugin

import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class SmileIdentityPlugin: FlutterPlugin, MethodCallHandler, ActivityAware
   {
  private lateinit var channel : MethodChannel
  var manager = SmileIdentityManager()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "smile_identity_plugin")
    channel.setMethodCallHandler(this)
    manager.updateChannel(channel)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    return manager.onMethodCall(call, result)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
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

open class SmileIdentityMainActivity: FlutterFragmentActivity(), MethodCallHandler {
  private lateinit var channel : MethodChannel
  var manager = SmileIdentityManager()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    manager.initializeActivity(this)
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    val messenger = flutterEngine.dartExecutor.binaryMessenger
    channel = MethodChannel(messenger, "smile_identity_plugin")
    manager.updateChannel(channel)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    manager.onActivityResult(requestCode, resultCode)
  }

  override fun onDetachedFromWindow() {
    super.onDetachedFromWindow()
     channel.setMethodCallHandler(null)
    manager.updateChannel(channel)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
     manager.onMethodCall(call, result)
  }
}
