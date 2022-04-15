import 'package:deliapp/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => const HomePage());
  }

  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (context) {
                  final user = context.select(
                      (AuthenticationBloc auth) => auth.state.loginInfo);

                  return Text('Name: ${user.fullName}');
                },
              ),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<AuthenticationBloc>()
                      .add(const AuthenticationLogOutRequested());
                },
                child: const Text('logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
