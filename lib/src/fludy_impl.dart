import 'package:fludy/src/foundation/arguments.dart';
import 'package:fludy/src/foundation/cancelable.dart';
import 'package:fludy/src/response/response.dart';

import 'fludy_platform_interface.dart';

class Fludy {
  late final WeakReference<void Function(DouYinResponse event)>
      responseListener;

  final List<DouYinResponseSubscriber> _responseListeners = [];

  Fludy() {
    responseListener = WeakReference((event) {
      for (var listener in _responseListeners) {
        listener(event);
      }
    });
    final target = responseListener.target;
    if (target != null) {
      FludyPlatform.instance.responseEventHandler.listen(target);
    }
  }

  Future<void> initializeApi({required DouYinOpenSDKConfig config}) {
    return FludyPlatform.instance.initializeApi(config: config);
  }

  /// Check if DouYin is installed.
  /// Must be called after [initializeApi]
  Future<bool> get isDouYinInstalled =>
      FludyPlatform.instance.isDouYinInstalled;

  Future<bool> authBy({required AuthType which}) {
    return FludyPlatform.instance.authorization(which: which);
  }

  /// Add a subscriber to subscribe responses from DouYin
  FludyCancelable addSubscriber(DouYinResponseSubscriber listener) {
    _responseListeners.add(listener);
    return FludyCancelableImpl(onCancel: () {
      removeSubscriber(listener);
    });
  }

  /// remove your subscriber from DouYin
  removeSubscriber(DouYinResponseSubscriber listener) {
    _responseListeners.remove(listener);
  }
}
