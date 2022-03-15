import 'dart:developer';

import 'package:deliapp/cubits/auth_cubit.dart';
import 'package:deliapp/screens/login_screen.dart';
import 'package:deliapp/screens/main_screen.dart';
import 'package:deliapp/screens/summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoggerObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log("${bloc.runtimeType} $change");
  }
}

void main() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  WidgetsFlutterBinding.ensureInitialized();

  final auth = await AuthCubit.getInstance();

  BlocOverrides.runZoned(
    () => runApp(DeliApp(auth)),
    blocObserver: LoggerObserver(),
  );
}

class DeliApp extends StatelessWidget {
  final AuthCubit auth;

  const DeliApp(this.auth, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return BlocProvider(
      create: (_) => auth,
      lazy: false,
      child: const DeliAppView(),
    );
  }
}

class DeliAppView extends StatelessWidget {
  const DeliAppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.system,
      title: 'DeliApp',
      initialRoute:
          context.read<AuthCubit>().isAuthenticated ? '/main' : 'login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/main': (_) => const MainScreen(),
        '/summary': (_) => const SummaryScreen(),
      },
    );
  }
}

// class CounterPage extends StatelessWidget {
//   const CounterPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => CounterCubit(),
//       child: const CounterView(),
//     );
//   }
// }

// class CounterView extends StatelessWidget {
//   const CounterView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Counter"),
//       ),
//       body: Center(
//         child: BlocBuilder<CounterCubit, int>(
//           builder: (context, state) {
//             return Text(
//               '$state',
//               style: const TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//               ),
//             );
//           },
//         ),
//       ),
//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             child: const Icon(Icons.add),
//             onPressed: () => context.read<CounterCubit>().increment(),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           FloatingActionButton(
//             child: const Icon(Icons.remove),
//             onPressed: () => context.read<CounterCubit>().decrement(),
//           ),
//         ],
//       ),
//     );
//   }
// }
