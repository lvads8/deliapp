import 'package:shared_preferences/shared_preferences.dart';

class ApiAuth {
  static const _authKey = 'www-authenticate';
  static const _secretKey = 'client_secret_key';

  final String authorization;
  final String secret;

  const ApiAuth._(this.authorization, this.secret);

  factory ApiAuth.fromHeaders(Map<String, String> headers) {
    return ApiAuth._(
      headers[_authKey]!,
      headers[_secretKey]!,
    );
  }

  factory ApiAuth.fromSharedPreferences(SharedPreferences instance) {
    return ApiAuth._(
      instance.getString(_authKey)!,
      instance.getString(_secretKey)!,
    );
  }

  Map<String, String> toHeader() {
    return {
      _authKey: authorization,
      _secretKey: secret,
    };
  }

  Future toSharedPreferences(SharedPreferences instance) async {
    await instance.setString(_authKey, authorization);
    await instance.setString(_secretKey, secret);
  }

  Future clearSharedPreferences(SharedPreferences instance) async {
    await instance.remove(_authKey);
    await instance.remove(_secretKey);
  }
}
