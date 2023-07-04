import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'smile_identity_plugin_platform_interface.dart';

/// An implementation of [SmileIdentityPluginPlatform] that uses method channels.
class MethodChannelSmileIdentityPlugin extends SmileIdentityPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('smile_identity_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
