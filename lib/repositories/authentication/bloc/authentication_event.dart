part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

class AuthenticationStatusChanged extends AuthenticationEvent {
  final AuthenticationStatus status;

  const AuthenticationStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class AuthenticationLogOutRequested extends AuthenticationEvent {
  const AuthenticationLogOutRequested();
}

class AuthenticationUnauthorizedError extends AuthenticationEvent {
  const AuthenticationUnauthorizedError();
}
