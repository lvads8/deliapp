import 'package:deliapp/api/client.dart';
import 'package:deliapp/api/models/models.dart';

abstract class Logout {
  static const _endpoint = 'LoginApp/login/mobile/logout';

  static Future<void> logout(ApiAuth auth) async {
    final request = ApiRequest(
      _endpoint,
      apiAuth: auth,
    );

    final client = ApiClient();
    final response = await client.post(request);

    response.throwOnError();
  }
}
