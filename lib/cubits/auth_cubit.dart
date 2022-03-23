import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:deliapp/api/common.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthCubitData {
  final Authentication auth;
  final String name;
  final String username;
  final bool isOnBreak;

  AuthCubitData(this.auth, this.name, this.username, this.isOnBreak);

  @override
  String toString() {
    return 'AuthCubitData(auth: $auth, name: $name, username: $username, isOnBreak: $isOnBreak)';
  }
}

class AuthCubit extends Cubit<AuthCubitData?> {
  AuthCubit() : super(null) {
    log('AuthCubit created');
    _readFromPrefs().ignore();
  }

  bool get isAuthenticated => state != null;

  void login(AuthCubitData data) {
    emit(data);
    _writeToPrefs();
  }

  void logout() {
    emit(null);
    _writeToPrefs();
  }

  Future<void> _writeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (state != null) {
      prefs.setString('www', state!.auth.auth);
      prefs.setString('secret', state!.auth.secret);
      prefs.setString('name', state!.name);
      prefs.setString('username', state!.username);
      prefs.setBool('isOnBreak', state!.isOnBreak);
    } else {
      prefs.remove('www');
      prefs.remove('secret');
      prefs.remove('name');
      prefs.remove('username');
      prefs.remove('isOnBreak');
    }
  }

  Future<void> _readFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('www')) {
      emit(AuthCubitData(
        Authentication(
          prefs.getString('www')!,
          prefs.getString('secret')!,
        ),
        prefs.getString('name')!,
        prefs.getString('username')!,
        prefs.getBool('isOnBreak')!,
      ));
    }
  }

  static Future<AuthCubit> getInstance() async {
    final instance = AuthCubit();
    await instance._readFromPrefs();

    return instance;
  }
}
