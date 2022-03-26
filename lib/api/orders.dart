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

class RawOrder {
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

  const RawOrder(
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

  factory RawOrder.fromJson(Map<String, dynamic> json) {
    return RawOrder(
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

class RawOrderItem {
  final int detailsId;
  final int cashAmount;
  final String name;

  const RawOrderItem(
    this.detailsId,
    this.cashAmount,
    this.name,
  );

  factory RawOrderItem.fromJson(Map<String, dynamic> json) {
    return RawOrderItem(
      json['shipmentDetailsId'],
      (json['crateAmount'] as double).floor(),
      json['crateCd'],
    );
  }
}

class Order {
  final bool pickedUp;
  final int pickupLocationId;
  final int deliverLocationId;
  final DateTime originalEta;
  final DateTime revisedEta;
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
  final List<OrderItem> items;

  const Order(
    this.pickedUp,
    this.pickupLocationId,
    this.deliverLocationId,
    this.originalEta,
    this.revisedEta,
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
    this.items,
  );
}

class OrderItem {
  final String name;
  final int cashAmount;

  const OrderItem(this.name, this.cashAmount);
}

class OrdersRequest {
  final Authentication auth;

  const OrdersRequest(this.auth);
}

class OrdersResponse {
  final List<Order> orders;

  const OrdersResponse(this.orders);
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

    if (!body.containsKey('data') || body['data']['totalCount'] == 0) {
      return const OrdersResponse([]);
    }

    final data = body['data'];
    final ordersSource = data['shipmentLocationDTOs'];
    final itemsSource = data['shipmentCrateMobileDTOs'];

    final rawOrders = ordersSource.map((e) => RawOrder.fromJson(e));
    final rawItems = itemsSource.map((e) => RawOrderItem.fromJson(e));

    final orders = _sanitizeRawOrderData(rawOrders, rawItems);

    return OrdersResponse(orders);
  }

  static List<Order> _sanitizeRawOrderData(
    List<RawOrder> rawOrders,
    List<RawOrderItem> rawItems,
  ) {
    rawOrders.sort((l, r) => l.sortBy.compareTo(r.sortBy));
    final orders = List<Order>.empty(growable: true);

    final notPickedUp = rawOrders
        .where(
          (p) => p.orderType == OrderType.pickup,
        )
        .map(
          (p) => [
            p,
            rawOrders.firstWhere((d) => p.detailsId == d.detailsId),
          ],
        )
        .toList();

    for (final pair in notPickedUp) {
      final pickup = pair[0];
      final deliver = pair[1];

      orders.add(
        Order(
          false,
          pickup.locationId,
          deliver.locationId,
          pickup.originalEta,
          pickup.revisedEta,
          deliver.paymentType,
          deliver.cashAmount,
          deliver.latitude,
          deliver.longitude,
          deliver.clientPhone,
          _sanitizeClientName(deliver.clientName),
          deliver.apartment,
          deliver.streetName,
          deliver.city,
          deliver.notes,
          _sanitizeOrderItems(rawItems, deliver.detailsId),
        ),
      );

      rawOrders.remove(pickup);
      rawOrders.remove(deliver);
    }

    for (final remains in rawOrders) {
      orders.add(
        Order(
          true,
          0,
          remains.locationId,
          remains.originalEta,
          remains.revisedEta,
          remains.paymentType,
          remains.cashAmount,
          remains.latitude,
          remains.longitude,
          remains.clientPhone,
          _sanitizeClientName(remains.clientName),
          remains.apartment,
          remains.streetName,
          remains.city,
          remains.notes,
          _sanitizeOrderItems(rawItems, remains.detailsId),
        ),
      );
    }

    return orders;
  }

  static List<OrderItem> _sanitizeOrderItems(
    List<RawOrderItem> rawItems,
    int id,
  ) {
    return rawItems
        .where((e) => e.detailsId == id)
        .map((e) => OrderItem(e.name, e.cashAmount))
        .toList();
  }

  static String _sanitizeClientName(String clientName) {
    if (clientName.isEmpty) {
      return '<nincs név>';
    }
    if (!clientName.contains(':')) {
      return clientName;
    }

    return clientName.split(':')[1];
  }
}
