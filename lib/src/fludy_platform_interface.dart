import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fludy_method_channel.dart';

abstract class FludyPlatform extends PlatformInterface {
  /// Constructs a FludyPlatform.
  FludyPlatform() : super(token: _token);

  static final Object _token = Object();

  static FludyPlatform _instance = MethodChannelFludy();

  /// The default instance of [FludyPlatform] to use.
  ///
  /// Defaults to [MethodChannelFludy].
  static FludyPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FludyPlatform] when
  /// they register themselves.
  static set instance(FludyPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
