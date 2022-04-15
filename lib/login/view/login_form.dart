import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../bloc/login_bloc.dart';
import '../../components/components.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        log('New login state: $state');
        if (!state.status.isSubmissionFailure) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Authentication failure'),
            ),
          );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UsernameInput(),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          _PasswordInput(),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _RememberMeCheckbox(),
              _SubmitButton(),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  final _controller = TextEditingController();

  _UsernameInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        final value = state.username.value;
        _controller.value = _controller.value.copyWith(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );

        return MyTextField(
          key: const Key('loginform_username'),
          controller: _controller,
          label: 'Felhasználónév',
          errorText:
              state.username.validOrPure ? null : 'Érvénytelen felhasználónév',
          onChanged: (value) {
            context.read<LoginBloc>().add(LoginUsernameChanged(value));
          },
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final _controller = TextEditingController();

  _PasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        final value = state.password.value;
        _controller.value = _controller.value.copyWith(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );

        return MyTextField(
          key: const Key('loginform_password'),
          controller: _controller,
          label: 'Jelszó',
          hideInput: true,
          errorText: state.password.validOrPure ? null : 'Érvénytelen jelszó',
          onChanged: (value) {
            context.read<LoginBloc>().add(LoginPasswordChanged(value));
          },
        );
      },
    );
  }
}

class _RememberMeCheckbox extends StatelessWidget {
  const _RememberMeCheckbox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) =>
          previous.rememberMe != current.rememberMe,
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Emlékezz rám'),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
            MySwitch(
              value: state.rememberMe,
              onChanged: (value) {
                context.read<LoginBloc>().add(LoginRememberMeChanged(value));
              },
            ),
          ],
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return MyElevatedButton(
          key: const Key('loginform_submit'),
          onPressed: state.status.isValid
              ? () {
                  context.read<LoginBloc>().add(const LoginSubmitted());
                }
              : null,
          label: 'Bejelentkezés',
        );
      },
    );
  }
}
