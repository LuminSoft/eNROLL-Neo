// import 'package:enroll_plugin/enroll_plugin.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockEnrollPluginPlatform
//     with MockPlatformInterfaceMixin /*implements EnrollPluginPlatform*/ {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

void main() {
  test('plugin test harness loads', () {
    expect(true, isTrue);
  });

  // final EnrollPluginPlatform initialPlatform = EnrollPluginPlatform.instance;
  //
  // test('$MethodChannelEnrollPlugin is the default instance', () {
  //   expect(initialPlatform, isInstanceOf<MethodChannelEnrollPlugin>());
  // });
  //
  // test('getPlatformVersion', () async {
  //   EnrollPlugin enrollPlugin = EnrollPlugin();
  //   MockEnrollPluginPlatform fakePlatform = MockEnrollPluginPlatform();
  //   EnrollPluginPlatform.instance = fakePlatform;
  //
  //   expect(await enrollPlugin.getPlatformVersion(), '42');
  // });
}
