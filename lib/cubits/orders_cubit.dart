import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/orders.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersCubit extends Cubit<OrdersResponse?> {
  OrdersCubit() : super(null);

  Future<void> refresh(Authentication auth) async {
    emit(await Orders.getOrders(OrdersRequest(auth)));
  }
}
