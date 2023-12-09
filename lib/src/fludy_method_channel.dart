import 'dart:async';

import 'foundation/arguments.dart';
import 'response/response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fludy_platform_interface.dart';

/// An implementation of [FludyPlatform] that uses method channels.
class MethodChannelFludy extends FludyPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('club.openflutter/fludy');

  final StreamController<DouYinResponse> _responseEventHandler =
      StreamController.broadcast();

  MethodChannelFludy() {
    methodChannel.setMethodCallHandler(_methodHandler);
  }

  /// Response answers from WeChat after sharing, payment etc.
  @override
  Stream<DouYinResponse> get responseEventHandler =>
      _responseEventHandler.stream;

  Future _methodHandler(MethodCall methodCall) {
    final response = DouYinResponse.create(
      methodCall.method,
      methodCall.arguments,
    );
    _responseEventHandler.add(response);

    return Future.value();
  }

  @override
  Future<void> initializeApi({required DouYinOpenSDKConfig config}) async {
    return await methodChannel
        .invokeMethod("initializeApi", config.arguments);
  }

  @override
  Future<bool> authorization({required AuthType which}) async {
    return await methodChannel.invokeMethod("authorization", which.arguments) ??
        false;
  }

  @override
  Future<bool> get isDouYinInstalled async =>
      await methodChannel.invokeMethod("isDouYinInstalled") ?? false;
}
