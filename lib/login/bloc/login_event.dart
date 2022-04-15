part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginUsernameChanged extends LoginEvent {
  final String value;

  const LoginUsernameChanged(this.value);

  @override
  List<Object> get props => [value];
}

class LoginPasswordChanged extends LoginEvent {
  final String value;

  const LoginPasswordChanged(this.value);

  @override
  List<Object> get props => [value];
}

class LoginRememberMeChanged extends LoginEvent {
  final bool value;

  const LoginRememberMeChanged(this.value);

  @override
  List<Object> get props => [value];
}

class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}
