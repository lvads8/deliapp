import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../components/components.dart';
import '../../repositories/repositories.dart';
import '../bloc/login_bloc.dart';
import 'login_form.dart';

class LoginPage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => const LoginPage());
  }

  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'res/kfc_logo.png',
              height: 150,
            ),
            MyCard(
              child: BlocProvider(
                create: (context) {
                  return LoginBloc(
                    authenticationRepository:
                        RepositoryProvider.of<AuthenticationRepository>(
                            context),
                  );
                },
                child: const LoginForm(),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 52)),
            const Text(
              'Deliapp v0.0.1',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w200,
              ),
            )
          ],
        ),
      ),
    );
  }
}
