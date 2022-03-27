import 'package:deliapp/api/common.dart';
import 'package:deliapp/api/logout.dart';
import 'package:deliapp/cubits/auth_cubit.dart';
import 'package:deliapp/cubits/break_cubit.dart';
import 'package:deliapp/cubits/history_cubit.dart';
import 'package:deliapp/cubits/orders_cubit.dart';
import 'package:deliapp/cubits/selected_index_cubit.dart';
import 'package:deliapp/cubits/timespan_cubit.dart';
import 'package:deliapp/screens/orders_screen.dart';
import 'package:deliapp/screens/summary_screen.dart';
import 'package:deliapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_loader/screen_loader.dart';

mixin MainScreenComponent on Widget {
  String get title;
  Icon get icon;
  List<WidgetBuilder> get actions;
}

final List<MainScreenComponent> _subScreens = [
  OrdersScreen(),
  const SummaryScreen(),
];

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
      child: BlocProvider(
        create: (_) => SelectedIndexCubit(),
        child: BlocProvider(
          create: (_) => BreakCubit(authState.isOnBreak),
          child: BlocProvider(
            create: (_) => TimespanCubit(),
            child: BlocProvider(
              create: (_) => HistoryCubit(),
              child: BlocProvider(
                create: (_) => OrdersCubit(),
                child: MainScreenView(_logout),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    if (!await Utils.promptUser(
      context,
      'Biztosan kilépsz?',
    )) {
      return;
    }

    final request = LogoutRequest(context.read<AuthCubit>().state!.auth);
    await performFuture(() => Logout.logout(request));
    context.read<AuthCubit>().logout();
    Navigator.of(context).pop();
    await Navigator.pushReplacementNamed(context, '/login');
  }
}

class MainScreenView extends StatelessWidget {
  final Function(BuildContext) _logoutCallback;

  const MainScreenView(this._logoutCallback, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedIndexCubit, int>(
      builder: (context, state) {
        final current = _subScreens[state];
        return Scaffold(
          appBar: AppBar(
            title: Text(current.title),
            actions: current.actions.map((e) => e.call(context)).toList(),
          ),
          drawer: _buildDrawer(context.read<AuthCubit>().state!, context),
          body: SafeArea(
            child: current,
          ),
        );
      },
    );
  }

  Drawer _buildDrawer(AuthCubitData authState, BuildContext context) {
    return Drawer(
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
              title: const Text('Szünet'),
              leading: const Icon(Icons.coffee),
              trailing: Switch(
                activeColor: Theme.of(context).colorScheme.primary,
                value: state,
                onChanged: (v) => _setBreakStatus(context, authState.auth, v),
              ),
              onTap: () => _setBreakStatus(context, authState.auth, !state),
            ),
          ),
          const Divider(),
          Column(
            children: _subScreens.asMap().entries.map((e) {
              final idx = e.key;
              final screen = e.value;

              return ListTile(
                title: Text(screen.title),
                leading: screen.icon,
                onTap: () {
                  context.read<SelectedIndexCubit>().index = idx;
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          const Divider(),
          ListTile(
            title: const Text('Kijelentkezés'),
            leading: const Icon(Icons.logout),
            onTap: () => _logoutCallback(context),
          ),
        ],
      ),
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
    );
  }
}
