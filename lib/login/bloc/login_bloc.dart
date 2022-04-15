import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../repositories/repositories.dart';
import '../models/models.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  static const _usernameKey = 'loginform_username';
  static const _passwordKey = 'loginform_password';

  final AuthenticationRepository _authenticationRepository;

  LoginBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginRememberMeChanged>(_onRememberMeChanged);
    on<LoginSubmitted>(_onSubmitted);

    _tryReadFromSharedPrefs().ignore();
  }

  void _onUsernameChanged(
    LoginUsernameChanged event,
    Emitter<LoginState> emit,
  ) {
    final username = Username.dirty(event.value);
    emit(state.copyWith(
      username: username,
      status: Formz.validate([username, state.password]),
    ));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final password = Password.dirty(event.value);
    emit(state.copyWith(
      password: password,
      status: Formz.validate([state.username, password]),
    ));
  }

  void _onRememberMeChanged(
    LoginRememberMeChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      rememberMe: event.value,
      status: Formz.validate([state.username, state.password]),
    ));
  }

  void _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isSubmittable) return;

    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    final result = await _authenticationRepository.login(
      username: state.username.value.trim(),
      password: state.password.value.trim(),
      rememberMe: state.rememberMe,
    );

    if (result && state.rememberMe) {
      _writeToSharedPrefs().ignore();
    } else {
      _clearSharedPrefs().ignore();
    }

    emit(state.copyWith(
      status: result
          ? FormzStatus.submissionSuccess
          : FormzStatus.submissionFailure,
    ));
  }

  Future _tryReadFromSharedPrefs() async {
    final instance = await SharedPreferences.getInstance();
    if (!instance.containsKey(_usernameKey)) return;

    final username = instance.getString(_usernameKey)!;
    final password = instance.getString(_passwordKey)!;

    add(LoginUsernameChanged(username));
    add(LoginPasswordChanged(password));
  }

  Future _writeToSharedPrefs() async {
    final instance = await SharedPreferences.getInstance();

    instance.setString(_usernameKey, state.username.value);
    instance.setString(_passwordKey, state.password.value);
  }

  Future _clearSharedPrefs() async {
    final instance = await SharedPreferences.getInstance();

    instance.remove(_usernameKey);
    instance.remove(_passwordKey);
  }
}
