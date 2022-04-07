part of 'authentication_bloc.dart';

class AuthenticationState extends Equatable {
  final ApiAuth? auth;
  final AuthenticationStatus status;

  const AuthenticationState._({
    this.auth,
    this.status = AuthenticationStatus.unknown,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(ApiAuth auth)
      : this._(auth: auth, status: AuthenticationStatus.authenticated);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  @override
  List<Object?> get props => [status, auth];
}
