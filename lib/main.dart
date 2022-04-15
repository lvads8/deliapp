import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'repositories/repositories.dart';
import 'app.dart';

void main() {
  EquatableConfig.stringify = true;
  WidgetsFlutterBinding.ensureInitialized();
  final authRepo = AuthenticationRepository();
  authRepo.loadInitialState().ignore();

  runApp(
    App(
      authRepo: authRepo,
    ),
  );
}
