import 'dart:async';

import 'package:deliapp/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  LoginInfo? _loginInfo;

  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.unknown;
    yield* _controller.stream;
  }

  LoginInfo? get loginInfo => _loginInfo;

  Future loadInitialState() async {
    final stored = await _tryReadFromSharedPrefs();
    if (stored == null) return;

    // TODO: Verify login
    _loginInfo = stored;
    _controller.add(AuthenticationStatus.authenticated);
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final response = await Login.login(
      username: username,
      password: password,
    );

    if (response != null) {
      _loginInfo = response;
      _controller.add(AuthenticationStatus.authenticated);
      return true;
    }

    return false;
  }

  Future logout() async {
    if (_loginInfo != null) return;

    await Logout.logout(_loginInfo!.auth);
    _controller.add(AuthenticationStatus.unauthenticated);

    final instance = await SharedPreferences.getInstance();
    _loginInfo!.clearSharedPreferences(instance).ignore();
    _loginInfo = null;
  }

  void dispose() => _controller.close();

  Future<LoginInfo?> _tryReadFromSharedPrefs() async {
    final instance = await SharedPreferences.getInstance();
    if (!instance.containsKey('www-authenticate')) return null;

    return LoginInfo.fromSharedPreferences(instance);
  }
}
