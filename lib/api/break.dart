import 'dart:convert';

import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/constants.dart';
import 'package:http/http.dart';

class BreakRequest {
  final Authentication auth;
  final bool value;

  BreakRequest(this.auth, this.value);
}

class Break extends ResponseObjectFactory<bool> {
  static final Uri _breakUri = Uri.parse(breakUrl);
  static final Break _instance = Break();

  static Future<bool> setBreak(BreakRequest request) {
    final body = jsonEncode({
      "isOnBreakFl": request.value,
    });

    return ApiRequest.putJson(
      _breakUri,
      _instance,
      auth: request.auth,
      body: body,
    );
  }

  @override
  bool fromResponse(Response res) {
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 401 || body['status'] == 401) {
      throw UnauthorizedException();
    }

    return res.statusCode == 200 && body['status'] == 200;
  }
}
