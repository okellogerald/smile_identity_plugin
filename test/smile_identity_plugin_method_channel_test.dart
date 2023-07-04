import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smile_identity_plugin/smile_identity_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSmileIdentityPlugin platform = MethodChannelSmileIdentityPlugin();
  const MethodChannel channel = MethodChannel('smile_identity_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
