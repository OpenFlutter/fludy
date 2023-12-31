import 'dart:convert';

typedef _DouYinResponseInvoker = DouYinResponse Function(Map argument);

Map<String, _DouYinResponseInvoker> _nameAndResponseMapper = {
  "onAuthResponse": (Map argument) => DouYinAuthResponse.fromMap(argument)
};

const String _errorCodeKey = "errorCode";
const String _errorMsgKey = "errorMsg";

sealed class DouYinResponse {
  final int errorCode;
  final String? errorMsg;

  bool get isSuccessful => errorCode == 0;

  DouYinResponse._(this.errorCode, this.errorMsg);

  /// Create response from the response pool.
  factory DouYinResponse.create(String name, Map argument) {
    var result = _nameAndResponseMapper[name];
    if (result == null) {
      throw ArgumentError("Can't found instance of $name");
    }
    return result(argument);
  }

  Record toRecord() {
    return ();
  }
}

class DouYinAuthResponse extends DouYinResponse {
  DouYinAuthResponse.fromMap(Map map)
      : authCode = map['authCode'],
        grantedPermissions = (() {
          List<String> result = [];
          (map["grantedPermissions"] as List<Object?>?)?.forEach((element) {
            if (element is String) {
              result.add(element);
            }
          });
          return result;
        }).call(),
        state = map['state'],
        super._(map[_errorCodeKey], map[_errorMsgKey]);

  final String? authCode;
  final List<String> grantedPermissions;
  final String? state;

  @override
  bool operator ==(other) {
    return other is DouYinAuthResponse &&
        authCode == other.authCode &&
        grantedPermissions == other.grantedPermissions &&
        state == other.state;
  }

  @override
  int get hashCode =>
      super.hashCode + errorCode.hashCode & 1345 + errorMsg.hashCode & 15;

  @override
  String toString() {
    return jsonEncode({
      _errorCodeKey: errorCode,
      _errorMsgKey: errorMsg,
      "authCode": authCode,
      "state": state,
      "grantedPermissions": grantedPermissions
    });
  }

  @override
  Record toRecord() {
    return (
      errorCode: errorCode,
      errorMsg: errorMsg,
      authCode: authCode,
      state: state,
      grantedPermissions: grantedPermissions
    );
  }
}
