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

  Future<String?> getPlatformVersion() {
    return SmileIdentityPluginPlatform.instance.getPlatformVersion();
  }

  void _init() {
    _channel.setMethodCallHandler((call) async {
      final method = call.method;
      if (method == "capture_state") {
        print("capture_state ${call.arguments["success"]}");
        value = value.copyWith(captured: call.arguments["success"]);
      }
      if (method == "submit_state") {
        print("submit_state ${call.arguments["success"]}");
        value = value.copyWith(submitted: call.arguments["success"]);
      }
    });
  }

  String get jobId => const Uuid().v1();
  String get tag => (const Uuid().v1()).replaceAll("-", "");

  Future<void> capture(SmileData data) async {
    final smileData = data.copyWith(jobId: jobId, tag: tag);
    value = value.copyWith(data: smileData);
    await _channel.invokeMethod("capture", smileData.tag);
  }

  Future<void> submitJob() async {
    await _channel.invokeMethod("submit", value.data!.toMap());
  }

  void removeSmileDataCache() {
    value = const SmileState();
  }
}
