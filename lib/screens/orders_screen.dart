import 'package:declarative_refresh_indicator/declarative_refresh_indicator.dart';
import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/orders.dart';
import 'package:deliapp/cubits/auth_cubit.dart';
import 'package:deliapp/cubits/orders_cubit.dart';
import 'package:deliapp/cubits/refreshing_cubit.dart';
import 'package:deliapp/screens/main_screen.dart';
import 'package:deliapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersScreen extends StatelessWidget with MainScreenComponent {
  final GlobalKey<RefreshIndicatorState> _refresher = GlobalKey();

  OrdersScreen({Key? key}) : super(key: key);

  @override
  String get title => 'Rendelések';

  @override
  Icon get icon => const Icon(Icons.directions_car);

  @override
  List<WidgetBuilder> get actions {
    return [
      (context) => BlocBuilder<OrdersCubit, OrdersResponse?>(
            builder: (context, state) {
              final orders = state?.orders;
              if (orders == null || orders.isEmpty) {
                return Container();
              }

              final pickups = orders.where((o) => !o.pickedUp).toList();
              if (pickups.isEmpty) {
                return Container();
              }

              final auth = context.read<AuthCubit>().state!.auth;

              return IconButton(
                icon: const Icon(Icons.archive),
                onPressed: () async {
                  if (!await Utils.promptUser(
                    context,
                    'Biztosan felveszed az összes rendelést?',
                  )) {
                    return;
                  }

                  context.read<RefreshingCubit>().refresh();

                  await Future.forEach<Order>(
                    pickups,
                    (pickup) => Utils.tryRequest(
                      context,
                      () async {
                        await pickup.checkin(auth);
                        await pickup.pickedup(auth);
                      },
                      null,
                    ),
                  );

                  _onRefresh(context, auth);
                },
              );
            },
          ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthCubit>().state!.auth;

    return BlocBuilder<RefreshingCubit, bool>(
      builder: (context, state) => DeclarativeRefreshIndicator(
        key: _refresher,
        refreshing: state,
        onRefresh: () => _onRefresh(context, auth),
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

              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return Card(
                      margin: const EdgeInsets.all(4),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: _buildOrderCardBody(context, order),
                      ),
                    );
                  },
                  // separatorBuilder: (_, __) => Container(height: 2),
                  itemCount: state.orders.length,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCardBody(BuildContext context, Order order) {
    return ListTile(
      title: Text(order.clientName),
      minLeadingWidth: 20,
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            order.pickedUp ? Icons.directions_car : Icons.archive,
            color: order.pickedUp ? Colors.blue : Colors.amber,
          ),
        ],
      ),
      subtitle: Text(order.city != null
          ? '${order.city}, ${order.streetName}, ${order.apartment}'
          : order.address),
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
        final result = await Navigator.pushNamed(
          context,
          '/order',
          arguments: order,
        ) as bool?;

        if (result ?? false) {
          _onRefresh(context, context.read<AuthCubit>().state!.auth);
        }
      },
    );
  }

  Future<void> _onRefresh(BuildContext context, Authentication auth) async {
    context.read<RefreshingCubit>().refresh();

    await Utils.tryRequest(
      context,
      () => context.read<OrdersCubit>().refresh(auth),
      null,
    );

    context.read<RefreshingCubit>().finish();
  }
}
