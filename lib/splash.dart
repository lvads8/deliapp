import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(
      builder: (_) => const Splash(),
    );
  }

  const Splash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.center,
        child: Image.asset('res/kfc_logo.png'),
      ),
    );
  }
}
