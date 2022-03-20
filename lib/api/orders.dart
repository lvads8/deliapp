import 'dart:convert';

import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/constants.dart';
import 'package:http/http.dart';

enum OrderType {
  pickup,
  deliver,
}

enum PaymentType {
  prepaid,
  cash,
}

class Order {
  final int locationId;
  final int detailsId;
  final int sortBy;
  final DateTime originalEta;
  final DateTime revisedEta;
  final OrderType orderType;
  final PaymentType paymentType;
  final int cashAmount;
  final double latitude;
  final double longitude;
  final String clientPhone;
  final String clientName;
  final String apartment;
  final String streetName;
  final String city;
  final String? notes;

  const Order(
    this.locationId,
    this.detailsId,
    this.sortBy,
    this.originalEta,
    this.revisedEta,
    this.orderType,
    this.paymentType,
    this.cashAmount,
    this.latitude,
    this.longitude,
    this.clientPhone,
    this.clientName,
    this.apartment,
    this.streetName,
    this.city,
    this.notes,
  );

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      json['shipmentLocationId'],
      json['shipmentDetailsId'],
      json['deliveryOrder'],
      DateTime.fromMillisecondsSinceEpoch(json['calculatedEndDt']),
      DateTime.fromMillisecondsSinceEpoch(json['revisedEta']),
      json['orderType'] == 'PICKUP' ? OrderType.pickup : OrderType.deliver,
      json['paymentType'] == 'COD' ? PaymentType.cash : PaymentType.prepaid,
      (json['cashAmount'] as double).floor(),
      json['latitude'],
      json['longitude'],
      json['clientNodePhone'],
      json['clientNodeName'],
      json['apartment'],
      json['streetName'],
      json['city'],
      json.containsKey('shipmentNotes') ? json['shipmentNotes'] : null,
    );
  }
}

class OrderItem {
  final int detailsId;
  final int cashAmount;
  final String name;

  const OrderItem(
    this.detailsId,
    this.cashAmount,
    this.name,
  );

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      json['shipmentDetailsId'],
      (json['crateAmount'] as double).floor(),
      json['crateCd'],
    );
  }
}

class OrdersRequest {
  final Authentication auth;

  const OrdersRequest(this.auth);
}

class OrdersResponse {
  final List<Order> orders;
  final List<OrderItem> items;

  const OrdersResponse(
    this.orders,
    this.items,
  );
}

class Orders extends ResponseObjectFactory<OrdersResponse> {
  static final Uri _ordersUri = Uri.parse(ordersUrl);
  static final Orders _instance = Orders();

  static Future<OrdersResponse> getOrders(OrdersRequest request) async {
    final response = ApiRequest.getJson(
      _ordersUri,
      _instance,
      auth: request.auth,
    );

    return response;
  }

  @override
  OrdersResponse fromResponse(Response res) {
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode == 401 || body['status'] == 401) {
      throw UnauthorizedException();
    }
    if (res.statusCode != 200 || body['status'] != 200) {
      throw body['message'];
    }

    if (!body.containsKey('data') ||
        body['data']['shipmentLocationDTOs'].isEmpty) {
      return const OrdersResponse([], []);
    }

    final data = body['data'];
    final ordersSource = data['shipmentLocationDTOs'];
    final itemsSource = data['shipmentCrateMobileDTOs'];

    final orders = ordersSource.map((e) => Order.fromJson(e));
    final items = itemsSource.map((e) => OrderItem.fromJson(e));

    return OrdersResponse(orders, items);
  }
}
