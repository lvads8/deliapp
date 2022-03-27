import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/orders.dart';
import 'package:deliapp/cubits/auth_cubit.dart';
import 'package:deliapp/cubits/orders_cubit.dart';
import 'package:deliapp/screens/main_screen.dart';
import 'package:deliapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersScreen extends StatelessWidget with MainScreenComponent {
  final GlobalKey<RefreshIndicatorState> _refresher = GlobalKey();

  OrdersScreen({Key? key}) : super(key: key);

  @override
  List<WidgetBuilder> get actions => [];

  @override
  Icon get icon => const Icon(Icons.directions_car);

  @override
  String get title => 'Rendelések';

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthCubit>().state!.auth;

    return RefreshIndicator(
      key: _refresher,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: Scrollbar(
        child: BlocBuilder<OrdersCubit, OrdersResponse?>(
          builder: (context, state) {
            if (state == null) {
              return ListView(
                children: [
                  Container(
                    height: 150,
                  ),
                  Text(
                    'Húzd le a frissítéshez',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              );
            }

            if (state.orders.isEmpty) {
              return ListView(
                children: [
                  Container(
                    height: 150,
                  ),
                  Text(
                    'Nincs rendelés',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(4),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: _buildOrderCardBody(context, state.orders[index]),
                  ),
                );
              },
              separatorBuilder: (_, __) => Container(height: 2),
              itemCount: state.orders.length,
            );
          },
        ),
      ),
      onRefresh: () => _onRefresh(context, auth),
    );
  }

  Widget _buildOrderCardBody(BuildContext context, Order order) {
    return ListTile(
      title: Text(order.clientName),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            order.pickedUp ? Icons.directions_car : Icons.archive,
          ),
        ],
      ),
      subtitle: Text('${order.city}, ${order.streetName}, ${order.apartment}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            order.paymentType == PaymentType.cash
                ? Icons.attach_money
                : Icons.credit_score,
          ),
          const SizedBox(
            height: 4,
          ),
          Text('${order.revisedEta.hour}:${order.revisedEta.minute}')
        ],
      ),
      onTap: () async {
        // if (await Navigator.pushNamed(
        //       context,
        //       '/order',
        //       arguments: order,
        //     ) ??
        //     false) {
        //   await _refresher.currentState!.show();
        // }

        await Navigator.pushNamed(
          context,
          '/order',
          arguments: order,
        );
      },
    );
  }

  Future<void> _onRefresh(BuildContext context, Authentication auth) async {
    await Utils.tryRequest(
      context,
      () => context.read<OrdersCubit>().refresh(auth),
      null,
    );
  }
}
