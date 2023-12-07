// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'fludy_platform_interface.dart';

/// A web implementation of the FludyPlatform of the Fludy plugin.
class FludyWeb extends FludyPlatform {
  /// Constructs a FludyWeb
  FludyWeb();

  static void registerWith(Registrar registrar) {
    FludyPlatform.instance = FludyWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }
}
