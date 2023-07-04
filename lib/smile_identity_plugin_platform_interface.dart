import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'smile_identity_plugin_method_channel.dart';

abstract class SmileIdentityPluginPlatform extends PlatformInterface {
  /// Constructs a SmileIdentityPluginPlatform.
  SmileIdentityPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmileIdentityPluginPlatform _instance = MethodChannelSmileIdentityPlugin();

  /// The default instance of [SmileIdentityPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelSmileIdentityPlugin].
  static SmileIdentityPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SmileIdentityPluginPlatform] when
  /// they register themselves.
  static set instance(SmileIdentityPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
