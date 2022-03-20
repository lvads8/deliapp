import 'dart:convert';

import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/constants.dart';
import 'package:http/http.dart';

class CheckoutRequest {
  final Authentication auth;
  final int shipmentId;
  final int locationId;
  final double latitude;
  final double longitude;

  const CheckoutRequest(
    this.auth,
    this.shipmentId,
    this.locationId,
    this.latitude,
    this.longitude,
  );
}

class Checkout extends ResponseObjectFactory<void> {
  static final Uri _checkinUri = Uri.parse(checkoutUrl);
  static final Checkout _instance = Checkout();

  static Future<void> checkout(CheckoutRequest request) {
    final body = jsonEncode({
      'shipmentId': request.shipmentId,
      'shipmentLocationId': request.locationId,
      'checkOutTime': DateTime.now().toIso8601String(),
      'checkOutLatitude': request.latitude,
      'checkOutLongitude': request.longitude,
      'path_param_url': '1729',
      'transactionId': '',
    });

    return ApiRequest.putJson(
      _checkinUri,
      _instance,
      auth: request.auth,
      body: '[$body]',
    );
  }

  @override
  void fromResponse(Response res) {
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 401 || body['status'] == 401) {
      throw UnauthorizedException();
    }

    if (res.statusCode != 200 || body['status'] != 200) {
      throw body['message'];
    }
  }
}
