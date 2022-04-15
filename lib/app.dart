import 'dart:developer';

import 'package:deliapp/home/view/home_page.dart';
import 'package:deliapp/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repositories/repositories.dart';
import 'login/view/view.dart';

class App extends StatelessWidget {
  final AuthenticationRepository authRepo;

  const App({
    Key? key,
    required this.authRepo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authRepo,
      child: BlocProvider(
        create: (_) => AuthenticationBloc(authRepo),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        buttonTheme: const ButtonThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xFFFB6376),
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFB6376),
        ),
      ),
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            log('New auth state: $state');
            final status = state.status;

            // Fall through to onGenerateRoute.
            // (just show the splash screen here)
            if (status == AuthenticationStatus.unknown) return;

            // TODO: Cancel splash screen here.
            if (status == AuthenticationStatus.unauthenticated) {
              _navigator.pushAndRemoveUntil(
                LoginPage.route(),
                (_) => false,
              );
            }

            if (status == AuthenticationStatus.authenticated) {
              _navigator.pushAndRemoveUntil(
                HomePage.route(),
                (route) => false,
              );
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => Splash.route(),
    );
  }
}
