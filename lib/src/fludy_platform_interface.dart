import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fludy_method_channel.dart';
import 'foundation/arguments.dart';
import 'response/response.dart';

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

  Stream<DouYinResponse> get responseEventHandler {
    throw UnimplementedError('responseEventHandler has not been implemented.');
  }

  Future<void> initializeApi({required DouYinOpenSDKConfig config}) {
    throw UnimplementedError('initializeApi() has not been implemented.');
  }

  Future<bool> authorization({required AuthType which}) {
    throw UnimplementedError('authorization() has not been implemented.');
  }

  Future<bool> get isDouYinInstalled {
    throw UnimplementedError('isDouYinInstalled has not been implemented.');
  }
}
