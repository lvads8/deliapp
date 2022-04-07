import 'dart:async';

import 'package:deliapp/api/api.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  LoginInfo? _loginInfo;

  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.unknown;
    yield* _controller.stream;
  }

  LoginInfo? get loginInfo => _loginInfo;

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

  Future<void> logout() async {
    if (_loginInfo != null) return;

    Logout.logout(_loginInfo!.auth).ignore();
    _loginInfo = null;
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
