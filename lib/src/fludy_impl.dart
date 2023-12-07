
import 'fludy_platform_interface.dart';

class Fludy {
  Future<String?> getPlatformVersion() {
    return FludyPlatform.instance.getPlatformVersion();
  }
}
