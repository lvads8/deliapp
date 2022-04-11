import 'dart:developer';

import 'package:deliapp/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repositories/repositories.dart';

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
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            log('New auth state: $state', level: 1000);
            final status = state.status;

            // Fall through to onGenerateRoute.
            // (just show the splash screen here)
            if (status == AuthenticationStatus.unknown) return;

            // Cancel splash screen here.
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => Splash.route(),
    );
  }
}
