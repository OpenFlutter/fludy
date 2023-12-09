part of 'arguments.dart';

sealed class AuthType with _Argument {}

/// [optionalScope0] and [optionalScope1] only works on Android
/// [additionalPermissions] only works on iOS.
class NormalAuth extends AuthType {
  final List<String> scope;
  final String? state;
  final String? optionalScope0;
  final String? optionalScope1;
  final Map<String, String> additionalPermissions;

  NormalAuth(
      {this.scope = const ["user_info"],
      this.state,
      this.optionalScope0,
      this.optionalScope1,
      this.additionalPermissions = const {"permission": "mobile"}})
      : assert(scope.isNotEmpty);

  @override
  Map<String, dynamic> get arguments => {
        'scope': scope,
        'state': state,
        'optionalScope0': optionalScope0,
        'optionalScope1': optionalScope1,
        'additionalPermissions': additionalPermissions
      };
}
