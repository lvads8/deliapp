import 'dart:convert';

import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/constants.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

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
        _formatDate(request.from) +
        '&endDt=' +
        _formatDate(request.to));

    return ApiRequest.getJson(uri, _instance, auth: request.auth);
  }

  static String _formatDate(DateTime date) {
    final f = NumberFormat('00');
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final buf = StringBuffer();

    buf.write(date.day);
    buf.write(' ');
    buf.write(months[date.month - 1]);
    buf.write(', ');
    buf.write(date.year);
    buf.write(' ');
    buf.write(f.format(date.hour));
    buf.write(':');
    buf.write(f.format(date.minute));
    buf.write(':59');

    return buf.toString();
  }

  @override
  HistoryResponse fromResponse(Response res) {
    if (res.statusCode == 401) throw UnauthorizedException();

    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode != 200 || body["status"] != 200) throw body["message"];

    if (!body.containsKey("data")) return const HistoryResponse(0, []);

    final data = body["data"][0];
    final cash = (data["totalAmountCollected"] as double).floor();
    final trips = (data["deliveryMediumTripHistoryDTOs"] as List<dynamic>)
        .map(
          (e) => HistoryTrip(
            DateTime.fromMillisecondsSinceEpoch(e["tripStartDt"]),
            DateTime.fromMillisecondsSinceEpoch(e["tripEndDt"]),
            e["orderCount"],
            e["tripName"],
          ),
        )
        .toList(growable: false)
        .reversed
        .toList(growable: false);

    return HistoryResponse(cash, trips);
  }
}
