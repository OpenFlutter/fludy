part of 'arguments.dart';

class DouYinOpenSDKConfig with _Argument {
  final String clientKey;

  DouYinOpenSDKConfig({required this.clientKey});

  @override
  Map<String, dynamic> get arguments => {"clientKey": clientKey};
}
