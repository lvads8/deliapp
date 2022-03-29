import 'dart:convert';

import 'package:deliapp/api/checkin.dart';
import 'package:deliapp/api/checkout.dart';
import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/constants.dart';
import 'package:deliapp/api/payment.dart';
import 'package:deliapp/api/pickedup.dart';
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
  final String address;
  final String? apartment;
  final String? streetName;
  final String? city;
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
    this.address,
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
      DateTime.fromMillisecondsSinceEpoch(json['endTimeWindow']),
      DateTime.fromMillisecondsSinceEpoch(json['calculatedEndDt']),
      json['orderType'] == 'PICKUP' ? OrderType.pickup : OrderType.deliver,
      json['paymentType'] == 'COD' ? PaymentType.cash : PaymentType.prepaid,
      (json['cashAmount'] as double).floor(),
      json['latitude'],
      json['longitude'],
      json['clientNodePhone'],
      json['clientNodeName'],
      json['address'],
      json['apartment'],
      json['streetName'],
      json['city'],
      json['shipmentNotes'],
    );
  }
}

class RawOrderItem {
  final int detailsId;
  final int count;
  final int cashAmount;
  final String name;

  const RawOrderItem(
    this.detailsId,
    this.count,
    this.cashAmount,
    this.name,
  );

  factory RawOrderItem.fromJson(Map<String, dynamic> json) {
    return RawOrderItem(
      json['shipmentDetailsId'],
      (json['noOfUnits'] as double).floor(),
      (json['crateAmount'] as double).floor(),
      json['crateCd'],
    );
  }
}

class Order {
  final bool pickedUp;
  final int locationId;
  final int shipmentId;
  final DateTime originalEta;
  final DateTime revisedEta;
  final PaymentType paymentType;
  final int cashAmount;
  final double latitude;
  final double longitude;
  final String clientPhone;
  final String clientName;
  final String address;
  final String? apartment;
  final String? streetName;
  final String? city;
  final String? notes;
  final List<OrderItem> items;

  const Order(
    this.pickedUp,
    this.locationId,
    this.shipmentId,
    this.originalEta,
    this.revisedEta,
    this.paymentType,
    this.cashAmount,
    this.latitude,
    this.longitude,
    this.clientPhone,
    this.clientName,
    this.address,
    this.apartment,
    this.streetName,
    this.city,
    this.notes,
    this.items,
  );

  bool get hasShake => items.any((item) => item.isShake);

  Future<void> pickedup(Authentication auth) {
    return Pickedup.pickedUp(
      PickedupRequest(
        auth,
        shipmentId,
        locationId,
        latitude,
        longitude,
      ),
    );
  }

  Future<void> checkin(Authentication auth) {
    return Checkin.checkin(
      CheckinRequest(
        auth,
        locationId,
        latitude,
        longitude,
      ),
    );
  }

  Future<void> collectCash(Authentication auth) {
    if (paymentType != PaymentType.cash) {
      throw "Can't collect cash for prepaid order";
    }

    return Payment.payment(
      PaymentRequest(
        auth,
        cashAmount,
        locationId,
        latitude,
        longitude,
      ),
    );
  }

  Future<void> checkout(Authentication auth) {
    return Checkout.checkout(
      CheckoutRequest(
        auth,
        shipmentId,
        locationId,
        latitude,
        longitude,
        'DELIVERED',
      ),
    );
  }
}

class OrderItem {
  final String name;
  final int count;
  final int cashAmount;

  const OrderItem(this.name, this.count, this.cashAmount);

  bool get isShake => name.contains(RegExp('shake', caseSensitive: false));
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

    final rawOrders =
        ordersSource.map<RawOrder>((e) => RawOrder.fromJson(e)).toList();
    final rawItems =
        itemsSource.map<RawOrderItem>((e) => RawOrderItem.fromJson(e)).toList();

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
            rawOrders.lastWhere((d) => p.detailsId == d.detailsId),
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
          pickup.detailsId,
          pickup.originalEta,
          pickup.revisedEta,
          deliver.paymentType,
          deliver.cashAmount,
          deliver.latitude,
          deliver.longitude,
          deliver.clientPhone,
          _sanitizeClientName(deliver.clientName),
          _sanitizeAddress(deliver.address),
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
          remains.locationId,
          remains.detailsId,
          remains.originalEta,
          remains.revisedEta,
          remains.paymentType,
          remains.cashAmount,
          remains.latitude,
          remains.longitude,
          remains.clientPhone,
          _sanitizeClientName(remains.clientName),
          _sanitizeAddress(remains.address),
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
    String fixName(String name) {
      return name.replaceAll(RegExp('^\\d+\\. '), '');
    }

    return rawItems
        .where((e) => e.detailsId == id)
        .map((e) => OrderItem(fixName(e.name), e.count, e.cashAmount))
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

  static String _sanitizeAddress(String address) {
    final countryAndZipCode = RegExp(',\\w+,\\d{4}\$');
    final uglyCommas = RegExp('(.),(.)');
    return address
        .replaceAll(countryAndZipCode, '')
        .replaceAllMapped(
          uglyCommas,
          (match) => '${match.group(1)}, ${match.group(2)}',
        )
        .split(', ')
        .map((s) => s.toTitleCase())
        .join(', ');
  }
}

extension StringCasingExtension on String {
  String toCapitalized() {
    if (length == 0) {
      return '';
    }

    final lower = toLowerCase().trim();
    if (['u.', 'u', 'utca', 'ut', 'út', 'krt.', 'krt'].contains(lower)) {
      return lower;
    }

    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
