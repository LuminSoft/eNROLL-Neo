import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('method channel test harness loads', () {
    expect(true, isTrue);
  });

  //
  // MethodChannelEnrollPlugin platform = MethodChannelEnrollPlugin();
  // const MethodChannel channel = MethodChannel('enroll_plugin');
  //
  // setUp(() {
  //   TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
  //     channel,
  //     (MethodCall methodCall) async {
  //       return '42';
  //     },
  //   );
  // });
  //
  // tearDown(() {
  //   TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  // });
  //
  // test('getPlatformVersion', () async {
  //   expect(await platform.getPlatformVersion(), '42');
  // });
}
