import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'models/smile_data.dart';
import 'models/smile_state.dart';
import 'smile_identity_plugin_platform_interface.dart';

class SmileIdentityPlugin extends ValueNotifier<SmileState> {
  SmileIdentityPlugin() : super(const SmileState()) {
    _init();
  }

  static const _channel = MethodChannel("smile_identity_plugin");

  final _controller = StreamController<SmileState>.broadcast();
  final _whetherToRecallCallController = StreamController<bool>.broadcast();

  Stream<SmileState> get onStateChanged => _controller.stream;

  Future<String?> getPlatformVersion() {
    return SmileIdentityPluginPlatform.instance.getPlatformVersion();
  }

  void _init() {
    _whetherToRecallCallController.stream.listen((event) {
      /// Does not work if called directly in the channel.setMethodHandler method
      /// permissions are assumed to have already been granted
      if (event) capture(value.data!, handleCameraPermission: false);
    });

    _channel.setMethodCallHandler((call) async {
      final method = call.method;
      late Function? function;

      dPrint('''
method: ${call.method}
args: ${call.arguments}
''');

      switch (method) {
        case "capture_state":
          function = () {
            value = value.copyWith(captured: call.arguments["success"]);
            dPrint("captured: ${value.captured}");
            if (value.captured) {
              submitJob();
            }
          };
          break;

        case "submit_state":
          function = () {
            value = value.copyWith(submitted: call.arguments["success"]);
          };
          break;

        case "permission_state":
          function = () {
            final granted = call.arguments["success"] ?? false;
            dPrint("Granted: $granted");
            // if (granted) capture(value.data!, handleCameraPermission: false);
            if (granted) _whetherToRecallCallController.add(true);
            if (!granted) {
              value = value.addError("Camera Permission Not Granted!");
            }
          };
          break;
      }
      if (function != null) function.call();
    });

    addListener(() {
      _controller.add(value);
    });
  }

  String get jobId => const Uuid().v1();
  String get tag => (const Uuid().v1()).replaceAll("-", "");

  Future<bool> checkCameraPermission() async {
    final result = await _channel.invokeMethod<bool>("check_camera");
    dPrint(result);
    if (result == true) {
      return true;
    }
    return false;
  }

  Future<void> capture(
    SmileData data, {
    bool handleCameraPermission = true,
  }) async {
    final smileData = data.copyWith(jobId: jobId, tag: tag);
    value = value.copyWith(data: smileData);

    bool grantedCameraPermission = true;
    if (handleCameraPermission) {
      grantedCameraPermission = await checkCameraPermission();
      if (!grantedCameraPermission) {
        final result = await _channel.invokeMethod("request_camera_permission");
        dPrint(result);
      }
    }

    if (!grantedCameraPermission) return;
    dPrint("Granted Permission: $grantedCameraPermission");

    await _channel.invokeMethod("capture", smileData.captureParams);
  }

  Future<void> submitJob() async {
    await _channel.invokeMethod("submit", value.data!.submitParams);
  }

  void removeSmileDataCache() {
    value = const SmileState();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

void dPrint(value) {
  print("-------------------------------------------");
  print("-------------------------------------------");
  print("-------------------------------------------");
  print(value);
  print("-------------------------------------------");
  print("-------------------------------------------");
  print("-------------------------------------------");
}
