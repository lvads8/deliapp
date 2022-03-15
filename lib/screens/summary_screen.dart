import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Összegzés'),
      ),
      body: Column(
        children: [
          const Text('Hello'),
        ],
      ),
    );
  }
}
