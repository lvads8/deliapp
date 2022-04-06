import 'package:flutter/material.dart';

class Deliapp extends StatelessWidget {
  const Deliapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: key,
      routes: {
        '/': (_) => const Text('Hello'),
      },
    );
  }
}
