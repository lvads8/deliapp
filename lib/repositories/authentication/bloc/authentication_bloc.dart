import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../api/models/models.dart';
import '../authentication_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;

  late final StreamSubscription<AuthenticationStatus>
      _authenticationSubscription;

  AuthenticationBloc(this._authenticationRepository)
      : super(const AuthenticationState.unknown()) {
    on<AuthenticationStatusChanged>(_onStatusChanged);
    on<AuthenticationLogOutRequested>(_onLogoutRequested);
    on<AuthenticationUnauthorizedError>(_onUnauthorizedError);
    _authenticationSubscription = _authenticationRepository.status.listen(
      (status) {
        add(AuthenticationStatusChanged(status));
      },
    );
  }

  @override
  Future<void> close() {
    _authenticationSubscription.cancel();
    _authenticationRepository.dispose();
    return super.close();
  }

  void _onStatusChanged(
    AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) {
    switch (event.status) {
      case AuthenticationStatus.authenticated:
        final loginInfo = _authenticationRepository.loginInfo;
        if (loginInfo != null) {
          return emit(AuthenticationState.authenticated(loginInfo));
        } else {
          return emit(const AuthenticationState.unauthenticated());
        }
      case AuthenticationStatus.unauthenticated:
        return emit(const AuthenticationState.unauthenticated());
      default:
        return emit(const AuthenticationState.unknown());
    }
  }

  void _onLogoutRequested(
    AuthenticationLogOutRequested event,
    Emitter<AuthenticationState> emit,
  ) {
    _authenticationRepository.logout();
  }

  void _onUnauthorizedError(
    AuthenticationUnauthorizedError event,
    Emitter<AuthenticationState> emit,
  ) {
    add(const AuthenticationLogOutRequested());
  }
}
