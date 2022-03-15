import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/constants.dart';
import 'package:http/http.dart';

class LogoutRequest {
  const LogoutRequest(this.auth);

  final Authentication auth;
}

class Logout extends ResponseObjectFactory<void> {
  static final Uri _logoutUri = Uri.parse(logoutUrl);

  static Future<void> logout(LogoutRequest request) async {
    await ApiRequest.postJson(_logoutUri, _instance, auth: request.auth);
  }

  @override
  void fromResponse(Response res) {}

  static final Logout _instance = Logout();
}
