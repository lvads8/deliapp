part of 'login_bloc.dart';

class LoginState extends Equatable {
  final FormzStatus status;
  final Username username;
  final Password password;
  final bool rememberMe;

  const LoginState({
    this.status = FormzStatus.pure,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
    this.rememberMe = true,
  });

  LoginState copyWith({
    FormzStatus? status,
    Username? username,
    Password? password,
    bool? rememberMe,
  }) {
    return LoginState(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  bool get isSubmittable => status.isValid || status.isSubmissionFailure;

  @override
  List<Object> get props => [status, username, password, rememberMe];
}
