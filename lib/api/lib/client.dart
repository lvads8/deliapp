import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'api_auth.dart';

const String _baseUrl = 'https://products.loginextsolutions.com/';
const String _appVersion = '5.0.99';
const String _userAgent = 'KFCDeliapp';
const String _contentType = 'application/json; charset=utf-8';

class UrlQueryParameter {
  final String key;
  final String value;

  const UrlQueryParameter({
    required this.key,
    required this.value,
  });

  String toUrlQuery() => '$key=$value';
}

class ApiRequest {
  final String endpoint;
  final ApiAuth? apiAuth;
  final List<UrlQueryParameter> queryParameters;
  final String body;

  const ApiRequest(
    this.endpoint, {
    this.apiAuth,
    this.queryParameters = const [],
    this.body = '',
  });

  Uri craftUri() {
    final url = _baseUrl + endpoint;
    if (queryParameters.isEmpty) return Uri.parse(url);

    final params = queryParameters.map((e) => e.toUrlQuery());
    final withParams = url + params.join('&');
    return Uri.parse(withParams);
  }
}

class ApiResponse {
  final int statusCode;
  final Map<String, String> headers;
  final List<int> bodyBytes;

  late final String bodyText = utf8.decode(bodyBytes);
  late final dynamic bodyJson = jsonDecode(bodyText);

  ApiResponse._(
    this.statusCode,
    this.headers,
    this.bodyBytes,
  );

  factory ApiResponse._fromResponse(Response response) {
    return ApiResponse._(
      response.statusCode,
      response.headers,
      response.bodyBytes,
    );
  }
}

class ApiClient {
  static final String _platform = Platform.isIOS ? 'iOS' : 'Android';

  final Client _client = Client();

  Future<ApiResponse> get(ApiRequest request) async {
    final uri = request.craftUri();
    final headers = _craftHeaders(request);

    final response = await _client.get(
      uri,
      headers: headers,
    );

    return ApiResponse._fromResponse(response);
  }

  Future<ApiResponse> post(ApiRequest request) async {
    final uri = request.craftUri();
    final headers = _craftHeaders(request);

    final response = await _client.post(
      uri,
      headers: headers,
      body: request.body,
      encoding: utf8,
    );

    return ApiResponse._fromResponse(response);
  }

  Future<ApiResponse> put(ApiRequest request) async {
    final uri = request.craftUri();
    final headers = _craftHeaders(request);

    final response = await _client.put(
      uri,
      headers: headers,
      body: request.body,
      encoding: utf8,
    );

    return ApiResponse._fromResponse(response);
  }

  Map<String, String> _craftHeaders(ApiRequest request) {
    final headers = {
      'Content-Type': _contentType,
      'User-Agent': _userAgent,
      'x-app-version': _appVersion,
      'x-platform': _platform,
    };
    headers.addAll(request.apiAuth?.toHeader() ?? {});

    return headers;
  }
}
