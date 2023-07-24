import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:smile_identity_plugin/models/capture_state.dart';
import 'package:smile_identity_plugin/models/submit_state.dart';
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

  final _statesController = StreamController<SmileState>.broadcast();

  /// Handles events stream triggered by the plugin itself based on the responses
  /// from the method channel.
  final _eventsController = StreamController<_Event>.broadcast();

  /// SmileState Stream
  Stream<SmileState> get onStateChanged => _statesController.stream;

  String get _randomJobId => const Uuid().v1();
  String get _randomTag => (const Uuid().v1()).replaceAll("-", "");
  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  void _init() {
    _channel.setMethodCallHandler(_methodCallHandler);
    _eventsController.stream.listen(_eventsHandler);

    addListener(() => _statesController.add(value));
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
    final e = data.copyWith(jobId: _randomJobId, tag: _randomTag);

    value = SmileState(data: e, captureState: const CaptureState.capturing());

    // For iOS
    if (_isIOS || _isMacOS) {
      final data = Map<String, dynamic>.from(value.data!.captureParams);
      data["handlePermissions"] = handleCameraPermission;
      await _channel.invokeMethod("capture", data);
      return;
    }

    // For Android
    bool grantedCameraPermission = true;
    if (handleCameraPermission) {
      grantedCameraPermission = await checkCameraPermission();
      if (!grantedCameraPermission) {
        await _channel.invokeMethod("request_camera_permission");
      }
    }

    if (!grantedCameraPermission) return;
    await _channel.invokeMethod("capture", value.data!.captureParams);
  }

  Future<void> _submitJob() async {
    value = value.copyWith(submitState: const SubmitState.submitting());
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

  /// handling events / responses from the native code
  Future<dynamic> _methodCallHandler(MethodCall call) async {
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
    final error = call.findArg<String>("error") ?? "Capturing failed!";

    if (captured) {
      value = value.copyWith(captureState: const CaptureState.captured());
      _eventsController.add(_Event.submit);
      return;
    }
    value = value.copyWith(captureState: CaptureState.error(error));
  }

  void _handleSubmitStateCall(MethodCall call) {
    final submitted = call.findArg<bool>("success") ?? false;
    final error = call.findArg<String>("error") ?? "Submission Failed!";

    if (submitted) {
      value = value.copyWith(submitState: const SubmitState.submitted());
      return;
    }
    value = value.copyWith(submitState: SubmitState.error(error));
  }

  void _handlePermissionState(MethodCall call) {
    final granted = call.findArg("success") ?? false;
    if (granted) _eventsController.add(_Event.capture);
    if (!granted) {
      value = value.copyWith(
        captureState: const CaptureState.error("Camera Permission denied!"),
      );
    }
  }

  @override
  void dispose() {
    _statesController.close();
    super.dispose();
  }
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
