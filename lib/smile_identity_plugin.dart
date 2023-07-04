
import 'smile_identity_plugin_platform_interface.dart';

class SmileIdentityPlugin {
  Future<String?> getPlatformVersion() {
    return SmileIdentityPluginPlatform.instance.getPlatformVersion();
  }
}
