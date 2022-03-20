import 'dart:convert';

import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/constants.dart';
import 'package:http/http.dart';

class PaymentRequest {
  final Authentication auth;
  final int cashAmount;
  final int locationId;
  final double latitude;
  final double longitude;

  const PaymentRequest(
    this.auth,
    this.cashAmount,
    this.locationId,
    this.latitude,
    this.longitude,
  );
}

class Payment extends ResponseObjectFactory<void> {
  static final Uri _checkinUri = Uri.parse(paymentUrl);
  static final Payment _instance = Payment();

  static Future<void> payment(PaymentRequest request) {
    final body = jsonEncode({
      'shipmentLocationId': request.locationId,
      'actualCashAmount': request.cashAmount,
      'path_param_url': '1729',
      'mismatchReasonId': 0,
      'mismatchReason': '',
      'paymentSubType': 'CASH',
      'latestLatitude': request.latitude,
      'latestLongitude': request.longitude,
      'updatedOnDt': DateTime.now().toIso8601String(),
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
