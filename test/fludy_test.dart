import 'package:flutter_test/flutter_test.dart';
import 'package:fludy/fludy.dart';
import 'package:fludy/fludy_platform_interface.dart';
import 'package:fludy/src/fludy_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFludyPlatform
    with MockPlatformInterfaceMixin
    implements FludyPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FludyPlatform initialPlatform = FludyPlatform.instance;

  test('$MethodChannelFludy is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFludy>());
  });

  test('getPlatformVersion', () async {
    Fludy fludyPlugin = Fludy();
    MockFludyPlatform fakePlatform = MockFludyPlatform();
    FludyPlatform.instance = fakePlatform;

    expect(await fludyPlugin.getPlatformVersion(), '42');
  });
}
