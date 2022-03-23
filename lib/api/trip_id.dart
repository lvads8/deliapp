import 'dart:convert';

import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/constants.dart';
import 'package:http/http.dart';

class TripIdRequest {
  final Authentication auth;

  const TripIdRequest(this.auth);
}

class TripIdResponse {
  final int id;
  final String name;

  const TripIdResponse(this.id, this.name);
}

class TripId extends ResponseObjectFactory<TripIdResponse?> {
  static final Uri _tripIdUri = Uri.parse(tripIdUrl);
  static final TripId _instance = TripId();

  Future<TripIdResponse?> getTripId(TripIdRequest request) {
    return ApiRequest.getJson(_tripIdUri, _instance);
  }

  @override
  TripIdResponse? fromResponse(Response res) {
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 401 || body['status'] == 401) {
      throw UnauthorizedException();
    }
    if (res.statusCode != 200 || body['status'] != 200) {
      throw body['message'];
    }

    if (!body.containsKey('data')) return null;
    final data = body['data'];

    return TripIdResponse(data['tripId'], data['tripName']);
  }
}
