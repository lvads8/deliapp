import 'dart:convert';

import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/constants.dart';
import 'package:http/http.dart';

class PickedupRequest {
  final Authentication auth;
  final int shipmentId;
  final int locationId;
  final double latitude;
  final double longitude;

  PickedupRequest(
    this.auth,
    this.shipmentId,
    this.locationId,
    this.latitude,
    this.longitude,
  );
}

class Pickedup extends ResponseObjectFactory<void> {
  static final Uri _uri = Uri.parse(pickedUpUrl);
  static final Pickedup _instance = Pickedup();

  static Future<void> pickedUp(PickedupRequest request) {
    final body = jsonEncode({
      'shipmentId': request.shipmentId,
      'shipmentLocationId': request.locationId,
      'path_param_url': '1729',
      'transactionId': '',
      'checkOutLatitude': request.latitude,
      'checkOutLongitude': request.longitude,
      'checkOutTime': DateTime.now().toIso8601String(),
    });

    return ApiRequest.putJson(
      _uri,
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
