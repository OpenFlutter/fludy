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
}

class DouYinAuthResponse extends DouYinResponse {
  DouYinAuthResponse.fromMap(Map map)
      : authCode = map['authCode'],
        grantedPermissions = map['grantedPermissions'] ?? [],
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
}
