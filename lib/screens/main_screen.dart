import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/logout.dart';
import 'package:deliapp/cubits/auth_cubit.dart';
import 'package:deliapp/cubits/break_cubit.dart';
// import 'package:deliapp/cubits/selected_index_cubit.dart';
import 'package:deliapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:screen_loader/screen_loader.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with ScreenLoader {
  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state!;
    return loadableWidget(
      // child: BlocProvider(
      //   create: (_) => SelectedIndexCubit(0),
      child: BlocProvider(
        create: (_) => BreakCubit(authState.isOnBreak),
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Rendelések'),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(authState.name),
                    accountEmail: Text(authState.username),
                    currentAccountPicture: const CircleAvatar(
                      backgroundImage: AssetImage('res/profile.png'),
                    ),
                  ),
                  BlocBuilder<BreakCubit, bool>(
                    builder: (context, state) => ListTile(
                      title: const Text("Szünet"),
                      leading: const Icon(Icons.coffee),
                      trailing: Switch(
                        activeColor: Theme.of(context).colorScheme.primary,
                        value: state,
                        onChanged: (v) =>
                            _setBreakStatus(context, authState.auth, v),
                      ),
                      onTap: () =>
                          _setBreakStatus(context, authState.auth, !state),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Rendelések'),
                    leading: const Icon(Icons.directions_car),
                    onTap: () => Navigator.pop(context),
                  ),
                  ListTile(
                    title: const Text('Összegzés'),
                    leading: const Icon(Icons.attach_money),
                    onTap: () async {
                      await Navigator.of(context).popAndPushNamed('/summary');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("Kijelentkezés"),
                    leading: const Icon(Icons.logout),
                    onTap: () async {
                      if (!await Utils.promptUser(
                        context,
                        'Biztosan kilépsz?',
                      )) {
                        return;
                      }

                      final request = LogoutRequest(authState.auth);
                      await performFuture(() => Logout.logout(request));
                      context.read<AuthCubit>().logout();
                      Navigator.pop(context);
                      await Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
            body: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Lűűőőogged in as ${authState.name}!"),
                ],
              ),
            ),
          ),
        ),
      ),
      // ),
    );
  }

  void _setBreakStatus(
    BuildContext context,
    Authentication auth,
    bool value,
  ) {
    Utils.tryRequest(
      context,
      () => context.read<BreakCubit>().setBreak(auth, value),
      null,
      snackbar: false,
      errorCallback: (e) async {
        if (e is UnauthorizedException) {
          final nav = Navigator.of(context);
          await Fluttertoast.showToast(
            msg: 'Megszakadt a kapcsolat, kérlek jelentkezz be újra',
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            textColor: Theme.of(context).colorScheme.inversePrimary,
          );

          nav.pop();
          await nav.pushReplacementNamed('/login');
        }
      },
    );
  }
}
