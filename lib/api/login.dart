import 'dart:convert';

import 'package:deliapp/api/common.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'common.dart';
import 'constants.dart';

import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart';

class LoginRequest {
  const LoginRequest(this.username, this.password);

  final String username;
  final String password;
}

abstract class LoginResponse {
  const LoginResponse(this.success);

  final bool success;
}

class Success extends LoginResponse {
  const Success(
    this.auth,
    this.name,
    this.username,
    this.isOnBreak,
  ) : super(true);

  final Authentication auth;
  final String name;
  final String username;
  final bool isOnBreak;

  @override
  String toString() {
    return 'Success(auth: $auth)';
  }
}

class Failure extends LoginResponse {
  Failure(this.message) : super(false);

  final String message;

  @override
  String toString() {
    return 'Failure(message: $message)';
  }
}

class Login extends ResponseObjectFactory<LoginResponse> {
  static final Uri _loginUri = Uri.parse(loginUrl);

  static Future<LoginResponse> login(LoginRequest request) async {
    final encodedRequest = await _createRequest(request);

    return await ApiRequest.postJson<LoginResponse>(
      _loginUri,
      _instance,
      body: jsonEncode(encodedRequest),
    );
  }

  static Future<Map<String, Object>> _createRequest(
    LoginRequest request,
  ) async {
    final encodedRequest = {
      'userName': request.username,
      'password': await _hashPassword(request.username, request.password),
      'imei': await _getUniqueId()
    };
    return encodedRequest;
  }

  static Future<String> _hashPassword(String username, String password) async {
    final mac = Hmac(Sha1());
    final pbkdf2 = Pbkdf2(macAlgorithm: mac, iterations: 128, bits: 512);
    final hash = utf8.encode(username.toLowerCase() + password + 'MOBILE');
    final passBytes = SecretKey(utf8.encode(password));
    final derived = await pbkdf2.deriveKey(secretKey: passBytes, nonce: hash);
    final bytes = await derived.extractBytes();

    final encodedHash = _toHexString(hash);
    final encodedBytes = _toHexString(bytes);

    return '128:$encodedHash:$encodedBytes';
  }

  static Future<String> _getUniqueId() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('uuid')) return prefs.getString('uuid')!;

    final uuid = const Uuid().v4();
    prefs.setString('uuid', uuid);

    return uuid;
  }

  static String _toHexString(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      final str = byte.toRadixString(16);
      if (str.length < 2) buffer.write('0');

      buffer.write(str);
    }

    return buffer.toString();
  }

  @override
  LoginResponse fromResponse(Response res) {
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (body['status'] == 200) {
      final data = body['data'];

      return Success(
        Authentication(
          res.headers['www-authenticate']!,
          res.headers['client_secret_key']!,
        ),
        data['deliveryMediumName'],
        data['userName'],
        data['isOnBreakFl'] == 'Y',
      );
    } else {
      return Failure(
        res.statusCode == 200 ? body['message'] : body['error'],
      );
    }
  }

  static final Login _instance = Login();
}
