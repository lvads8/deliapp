part of 'authentication_bloc.dart';

class AuthenticationState extends Equatable {
  final LoginInfo loginInfo;
  final AuthenticationStatus status;

  const AuthenticationState._({
    this.loginInfo = LoginInfo.empty,
    this.status = AuthenticationStatus.unknown,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(LoginInfo loginInfo)
      : this._(
            loginInfo: loginInfo, status: AuthenticationStatus.authenticated);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  ApiAuth get auth => loginInfo.auth;

  @override
  List<Object?> get props => [status, loginInfo];
}
