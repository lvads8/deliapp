import 'dart:convert';

import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/constants.dart';
import 'package:http/src/response.dart';

class HistoryRequest {
  final Authentication auth;
  final DateTime from;
  final DateTime to;

  const HistoryRequest(this.auth, this.from, this.to);
}

class HistoryTrip {
  final DateTime start;
  final DateTime end;
  final int orderCount;
  final String name;

  const HistoryTrip(this.start, this.end, this.orderCount, this.name);
}

class HistoryResponse {
  final int cashCollected;
  final List<HistoryTrip> trips;

  const HistoryResponse(this.cashCollected, this.trips);
}

class History extends ResponseObjectFactory<HistoryResponse> {
  static final History _instance = History();

  static Future<HistoryResponse> getHistory(HistoryRequest request) {
    final uri = Uri.parse(getHistoryUrl +
        '&startDt=' +
        request.from.toString() +
        '&endDt=' +
        request.to.toString());

    return ApiRequest.getJson(uri, _instance, auth: request.auth);
  }

  @override
  HistoryResponse fromResponse(Response res) {
    if (res.statusCode == 401) throw UnauthorizedException();

    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode != 200 || body["status"] != 200) throw body["message"];

    final data = body["data"][0];
    final cash = (data["totalAmountCollected"] as double) as int;
    final trips = (data["deliveryMediumTripHistoryDTOs"] as List<dynamic>)
        .map(
          (e) => HistoryTrip(
            // start,
            // end,
            // orderCount,
            // name,
            DateTime.now(),
            DateTime.now(),
            0,
            "",
          ),
        )
        .toList(growable: false);

    return HistoryResponse(cash, trips);
  }
}
