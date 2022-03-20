import 'dart:convert';

import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/constants.dart';
import 'package:http/http.dart';

class CheckinRequest {
  final Authentication auth;
  final int locationId;
  final double latitude;
  final double longitude;

  const CheckinRequest(
    this.auth,
    this.locationId,
    this.latitude,
    this.longitude,
  );
}

class Checkin extends ResponseObjectFactory<void> {
  static final Uri _checkinUri = Uri.parse(checkinUrl);
  static final Checkin _instance = Checkin();

  static Future<void> checkin(CheckinRequest request) {
    final body = jsonEncode({
      'shipmentLocationId': request.locationId,
      'checkInTime': DateTime.now().toIso8601String(),
      'checkinLatitude': request.latitude,
      'checkinLongitude': request.longitude,
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
