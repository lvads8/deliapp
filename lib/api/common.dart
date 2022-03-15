import 'dart:convert';
import 'dart:developer';

import 'package:deliapp/api/constants.dart';
import 'package:http/http.dart';

class UnauthorizedException {}

class Authentication {
  Authentication(this.auth, this.secret);

  final String auth;
  final String secret;

  @override
  String toString() {
    return "Authentication(auth: $auth, secret: $secret)";
  }
}

abstract class ResponseObjectFactory<T> {
  T fromResponse(Response res);
}

abstract class ApiRequest {
  static Future<T> getJson<T>(
    Uri url,
    ResponseObjectFactory<T> fac, {
    String? body,
    Authentication? auth,
  }) async {
    final response = await get(url,
        headers: auth != null
            ? {
                "Host": "products.loginextsolutions.com",
                "Content-Type": "application/json; charset=utf-8",
                "User-Agent": "LogiNextApps",
                "x-app-version": "5.0.99",
                "x-platform": "Hmmm",
                "www-authenticate": auth.auth,
                "client_secret_key": auth.secret
              }
            : {
                "Host": "products.loginextsolutions.com",
                "Content-Type": "application/json; charset=utf-8",
                "User-Agent": "LogiNextApps",
                "x-app-version": "5.0.99",
                "x-platform": "Hmmm"
              });

    log('GET($url) => ${serializeResponse(response)}');
    return fac.fromResponse(response);
  }

  static Future<T> postJson<T>(
    Uri url,
    ResponseObjectFactory<T> fac, {
    String? body,
    Authentication? auth,
  }) async {
    final response = await post(url,
        headers: auth != null
            ? {
                "Host": "products.loginextsolutions.com",
                "Content-Type": "application/json; charset=utf-8",
                "User-Agent": userAgent,
                "x-app-version": version,
                "x-platform": platform,
                "www-authenticate": auth.auth,
                "client_secret_key": auth.secret
              }
            : {
                "Host": "products.loginextsolutions.com",
                "Content-Type": "application/json; charset=utf-8",
                "User-Agent": userAgent,
                "x-app-version": version,
                "x-platform": platform,
              },
        body: body ?? "{}");

    log('POST($url) with body ${body ?? "{}"} => ${serializeResponse(response)}');
    return fac.fromResponse(response);
  }

  static Future<T> putJson<T>(
    Uri url,
    ResponseObjectFactory<T> fac, {
    Authentication? auth,
    String? body,
  }) async {
    final response = await put(
      url,
      headers: auth != null
          ? {
              "Host": "products.loginextsolutions.com",
              "Content-Type": "application/json; charset=utf-8",
              "User-Agent": userAgent,
              "x-app-version": version,
              "x-platform": platform,
              "www-authenticate": auth.auth,
              "client_secret_key": auth.secret
            }
          : {
              "Host": "products.loginextsolutions.com",
              "Content-Type": "application/json; charset=utf-8",
              "User-Agent": userAgent,
              "x-app-version": version,
              "x-platform": platform,
            },
      body: body ?? "{}",
    );

    log('PUT($url) with body ${body ?? "{}"} => ${serializeResponse(response)}');
    return fac.fromResponse(response);
  }

  static String serializeResponse(Response response) {
    final obj = {
      "code": response.statusCode,
      "headers": response.headers,
      "body": utf8.decode(response.bodyBytes),
    };

    return jsonEncode(obj);
  }
}
