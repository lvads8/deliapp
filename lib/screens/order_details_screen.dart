import 'package:deliapp/api/orders.dart';
import 'package:deliapp/cubits/auth_cubit.dart';
import 'package:deliapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments! as Order;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendelés részletek'),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Név: ' + order.clientName),
              Text('Teljes cím: ' + order.address),
              TextButton(
                onPressed: () async =>
                    await FlutterPhoneDirectCaller.callNumber(
                  order.clientPhone,
                ),
                child: Text(order.clientPhone),
              ),
              Text('Város: ${order.city ?? "-"}'),
              Text('Utca: ${order.streetName ?? "-"}'),
              Text('Házszám: ${order.apartment ?? "-"}'),
              Text('Megjegyzés: ' + (order.notes ?? '<nincs megjegyzés>')),
              Text('Fizetés: ${order.paymentType.name}'),
              Text('Lóvé della: ${order.cashAmount}'),
              Text('Eredeti ETA ${order.originalEta}'),
              Text('Revised ETA ${order.revisedEta}'),
              ElevatedButton(
                onPressed: () async {
                  if (!await Utils.promptUser(
                      context, 'Biztosan tovább akarsz lépni?')) {
                    return;
                  }

                  if (order.pickedUp) {
                    await Utils.tryRequest(
                      context,
                      () async {
                        final auth = context.read<AuthCubit>().state!.auth;
                        await order.checkin(auth);
                        if (order.paymentType == PaymentType.cash) {
                          await order.collectCash(auth);
                        }
                        await order.checkout(auth);
                      },
                      null,
                    );
                  } else {
                    await Utils.tryRequest(
                      context,
                      () async {
                        final auth = context.read<AuthCubit>().state!.auth;
                        await order.checkin(auth);
                        await order.pickedup(auth);
                      },
                      null,
                    );
                  }

                  Navigator.pop(context, true);
                },
                child: Text(order.pickedUp ? 'Leadás' : 'Felvétel'),
              ),
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, idx) {
                    final item = order.items[idx];
                    // return Text('${item.name}, ${item.cashAmount} Ft');
                    return Card(
                      child: ListTile(
                        minLeadingWidth: 10,
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${item.count} db'),
                          ],
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            color: item.isShake
                                ? Colors.red
                                : Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        subtitle: Text('${item.cashAmount} Ft'),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => Container(height: 2),
                  itemCount: order.items.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
