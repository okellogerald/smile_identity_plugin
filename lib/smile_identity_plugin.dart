import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'models/smile_data.dart';
import 'models/smile_state.dart';
import 'smile_identity_plugin_platform_interface.dart';

enum _Event { capture, submit }

class SmileIdentityPlugin extends ValueNotifier<SmileState> {
  SmileIdentityPlugin() : super(const SmileState()) {
    _init();
  }

  static const _channel = MethodChannel("smile_identity_plugin");

  final _controller = StreamController<SmileState>.broadcast();

  /// Handles events stream triggered by the plugin itself based on the responses
  /// from the method channel.
  final _eventsController = StreamController<_Event>.broadcast();

  /// SmileState Stream
  Stream<SmileState> get onStateChanged => _controller.stream;

  String get _randomJobId => const Uuid().v1();
  String get _randomTag => (const Uuid().v1()).replaceAll("-", "");
  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  void _init() {
    _channel.setMethodCallHandler(_methodCallHandler);
    _eventsController.stream.listen(_eventsHandler);

    addListener(() => _controller.add(value));
  }

  Future<String?> getPlatformVersion() {
    return SmileIdentityPluginPlatform.instance.getPlatformVersion();
  }

  Future<bool> checkCameraPermission() async {
    final result = await _channel.invokeMethod<bool>("check_camera");
    return result ?? false;
  }

  Future<void> capture(
    SmileData data, {
    bool handleCameraPermission = true,
  }) async {
    final smileData = data.copyWith(jobId: _randomJobId, tag: _randomTag);
    value = value.copyWith(data: smileData);

    // Removing Any Errors
    value = value.addError(null);

    // For iOS
    if (_isIOS || _isMacOS) {
      final data = Map<String, dynamic>.from(smileData.captureParams);
      data["handlePermissions"] = handleCameraPermission;
      await _channel.invokeMethod("capture", smileData.captureParams);
      return;
    }

    // For Android
    bool grantedCameraPermission = true;
    if (handleCameraPermission) {
      grantedCameraPermission = await checkCameraPermission();
      if (!grantedCameraPermission) {
        final result = await _channel.invokeMethod("request_camera_permission");
        dPrint(result);
      }
    }

    if (!grantedCameraPermission) return;
    await _channel.invokeMethod("capture", smileData.captureParams);
  }

  Future<void> _submitJob() async {
    value = value.addError(null);
    await _channel.invokeMethod("submit", value.data!.submitParams);
  }

  void removeSmileDataCache() => value = const SmileState();

  void _eventsHandler(_Event event) {
    switch (event) {
      case _Event.capture:
        capture(value.data!, handleCameraPermission: false);
        break;

      case _Event.submit:
        _submitJob();
        break;

      default:
    }
  }

  Future<dynamic> _methodCallHandler(MethodCall call) async {
    dPrint('''
      method: ${call.method}
      args: ${call.arguments}
    ''');

    switch (call.method) {
      case "capture_state":
        return _handleCaptureStateCall(call);
      case "submit_state":
        return _handleSubmitStateCall(call);
      case "permission_state":
        return _handlePermissionState(call);
    }
  }

  void _handleCaptureStateCall(MethodCall call) {
    final captured = call.findArg<bool>("success") ?? false;
    value = value.copyWith(captured: captured);
    if (value.captured) _eventsController.add(_Event.submit);
  }

  void _handleSubmitStateCall(MethodCall call) {
    final submitted = call.findArg<bool>("success") ?? false;
    final error = call.findArg<String>("error");

    dPrint('''
      Error Equal: ${value.error == error}
      Submitted Equal: ${value.submitted == submitted}
    ''');

    if (value.error == error && value.submitted == submitted) return;
    value = value.copyWith(submitted: submitted);
    value = value.addError(error);
  }

  void _handlePermissionState(MethodCall call) {
    final granted = call.findArg("success") ?? false;
    if (granted) _eventsController.add(_Event.capture);
    if (!granted) {
      value = value.addError("Camera Permission Not Granted!");
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

void dPrint(value) {
  print("-------------------------------------------");
  print(value);
  print("-------------------------------------------");
}

extension _DynamicExt on MethodCall {
  /// Finds a value from a call argument (expected to be a Map).
  /// Returns null if could not find the value or if it is of a
  /// different type
  T? findArg<T>(String key) {
    try {
      return Map.from(arguments)[key] as T;
    } catch (_) {
      return null;
    }
  }
}
