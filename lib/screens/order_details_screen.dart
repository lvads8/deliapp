import 'package:deliapp/api/orders.dart';
import 'package:flutter/material.dart';

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
              Text(order.clientName),
              Text(order.clientPhone),
            ],
          ),
        ),
      ),
    );
  }
}
