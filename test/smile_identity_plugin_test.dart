import 'package:flutter_test/flutter_test.dart';
import 'package:smile_identity_plugin/smile_identity_plugin.dart';
import 'package:smile_identity_plugin/smile_identity_plugin_platform_interface.dart';
import 'package:smile_identity_plugin/smile_identity_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSmileIdentityPluginPlatform
    with MockPlatformInterfaceMixin
    implements SmileIdentityPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SmileIdentityPluginPlatform initialPlatform = SmileIdentityPluginPlatform.instance;

  test('$MethodChannelSmileIdentityPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSmileIdentityPlugin>());
  });

  test('getPlatformVersion', () async {
    SmileIdentityPlugin smileIdentityPlugin = SmileIdentityPlugin();
    MockSmileIdentityPluginPlatform fakePlatform = MockSmileIdentityPluginPlatform();
    SmileIdentityPluginPlatform.instance = fakePlatform;

    expect(await smileIdentityPlugin.getPlatformVersion(), '42');
  });
}
