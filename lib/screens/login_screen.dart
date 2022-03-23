import 'dart:developer';

import 'package:deliapp/api/login.dart';
import 'package:deliapp/cubits/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _usernameKey = 'remember-username';
  static const String _passwordKey = 'remember-password';

  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _enabled = true;
  bool _rememberMe = true;

  _LoginScreenState() {
    Utils.readString(_usernameKey)
        .then((value) => _username.text = value ?? '');
    Utils.readString(_passwordKey)
        .then((value) => _password.text = value ?? '');
  }

  Future<bool> login(String username, String password) {
    return Utils.tryRequest(context, () async {
      log('Logging in with credentials: $username:$password');

      final request = LoginRequest(username, password);
      final result = await Login.login(request);
      log('Login result: $result');

      if (result is Success) {
        context.read<AuthCubit>().login(
              AuthCubitData(
                result.auth,
                result.name,
                result.username,
                result.isOnBreak,
              ),
            );
        await Navigator.pushReplacementNamed(context, '/main');

        return true;
      } else if (result is Failure) {
        Utils.alertUser(context, 'Helytelen felhasználónév vagy jelszó');
      }

      setState(() {
        _enabled = true;
      });
      return false;
    }, false);
  }

  void _loginPressed() {
    if (!_enabled) return;

    setState(() {
      _enabled = false;
    });

    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _enabled = true;
      });
      return;
    }

    final username = _username.text.trim();
    final password = _password.text.trim();

    if (_rememberMe) {
      Utils.writeString(_usernameKey, username);
      Utils.writeString(_passwordKey, password);
    } else {
      Utils.deleteString(_usernameKey);
      Utils.deleteString(_passwordKey);
    }

    login(username, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'res/kfc_logo.png',
                  height: 100,
                ),
                _buildLoginCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 64),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextFormField(
                enabled: _enabled,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    fontSize: 14,
                  ),
                  labelText: 'Felhasználónév',
                ),
                controller: _username,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Add meg a felhasználónevet';
                  }

                  return null;
                },
              ),
            ),
            TextFormField(
              enabled: _enabled,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(
                  fontSize: 14,
                ),
                labelText: 'Jelszó',
              ),
              controller: _password,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              autocorrect: false,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Add meg a jelszót';
                }

                return null;
              },
              textInputAction: TextInputAction.done,
            ),
            GestureDetector(
              child: Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (val) => setState(() {
                      _rememberMe = val!;
                    }),
                  ),
                  const Text('Emlékezz rám')
                ],
              ),
              onTap: () => setState(() {
                _rememberMe = !_rememberMe;
              }),
            ),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Center _buildLoginButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loginPressed,
          child: const Text('Bejelentkezés'),
        ),
      ),
    );
  }
}
