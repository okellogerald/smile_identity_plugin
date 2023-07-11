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
  final _eventsController = StreamController<_Event>.broadcast();

  Stream<SmileState> get onStateChanged => _controller.stream;

  Future<String?> getPlatformVersion() {
    return SmileIdentityPluginPlatform.instance.getPlatformVersion();
  }

  void _init() {
    _eventsController.stream.listen((event) {
      /// Does not work if called directly in the channel.setMethodHandler method
      /// permissions are assumed to have already been granted
      /// todo: May need to create an EventsChannel
      if (event == _Event.capture) {
        capture(value.data!, handleCameraPermission: false);
      }
      if (event == _Event.submit) {
        submitJob();
      }
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
            bool capturedSuccessfully = false;
            try {
              capturedSuccessfully = (call.arguments["success"] as bool);
            } catch (_) {}
            value = value.copyWith(captured: capturedSuccessfully);
            if (value.captured) _eventsController.add(_Event.submit);
          };
          break;

        case "submit_state":
          function = () {
            bool submittedSuccessfully = false;
            String? error;
            try {
              submittedSuccessfully = (call.arguments["completed"] as bool);
            } catch (_) {}
            try {
              error = call.arguments["error"] as String?;
            } catch (_) {}

            dPrint('''
Error Equal: ${value.error == error}
Submitted Equal: ${value.submitted == submittedSuccessfully}
''');

            if (value.error == error &&
                value.submitted == submittedSuccessfully) {
                  //
            } else {
              value = value.copyWith(submitted: submittedSuccessfully);
              value = value.addError(error);
            }
          };
          break;

        case "permission_state":
          function = () {
            final granted = call.arguments["success"] ?? false;
            if (granted) _eventsController.add(_Event.capture);
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
    value = value.addError(null);

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final data = Map<String, dynamic>.from(smileData.captureParams);
      data["handlePermissions"] = handleCameraPermission;
      await _channel.invokeMethod("capture", smileData.captureParams);
      return;
    }

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
    value = value.addError(null);
    await _channel.invokeMethod("submit", value.data!.submitParams);
    dPrint("submitting job");
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
  print(value);
  print("-------------------------------------------");
}
