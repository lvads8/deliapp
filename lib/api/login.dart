import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

import 'models/models.dart';
import 'client.dart';

abstract class Login {
  static const _endpoint = 'LoginApp/login/mobile/authenticate';

  static Future<LoginInfo?> login({
    required String username,
    required String password,
  }) async {
    final request = ApiRequest(
      _endpoint,
      body: await _createBody(username, password),
    );

    final client = ApiClient();
    final response = await client.post(request);
    if (response.isUnauthorized) return null;
    if (!response.isSuccess) throw response.error;

    final data = response.bodyJson['data'];
    final auth = ApiAuth.fromHeaders(response.headers);

    return LoginInfo(
      auth,
      data['userName']!,
      data['deliveryMediumName']!,
      data['isOnBreakFl']! == 'Y',
    );
  }

  static Future<String> _createBody(String username, String password) async {
    final id = await _getId() ?? const Uuid().v4();
    final hash = await _PasswordHasher(username, password).hashPassword();

    return jsonEncode({
      'userName': username,
      'password': hash,
      'imei': id,
    });
  }

  static Future<String?> _getId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosInfo = await info.iosInfo;
      return iosInfo.identifierForVendor;
    } else {
      final androidInfo = await info.androidInfo;
      return androidInfo.androidId;
    }
  }
}

class _PasswordHasher {
  final String _username;
  final String _password;

  const _PasswordHasher(this._username, this._password);

  Future<String> hashPassword() async {
    final mac = Hmac(Sha1());
    final pbkdf2 = Pbkdf2(macAlgorithm: mac, iterations: 128, bits: 512);
    final hash = utf8.encode(_username.toLowerCase() + _password + 'MOBILE');
    final passBytes = SecretKey(utf8.encode(_password));
    final derived = await pbkdf2.deriveKey(secretKey: passBytes, nonce: hash);
    final bytes = await derived.extractBytes();

    final encodedHash = _toHexString(hash);
    final encodedBytes = _toHexString(bytes);

    return '128:$encodedHash:$encodedBytes';
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
}
