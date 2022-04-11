import 'package:shared_preferences/shared_preferences.dart';

import 'api_auth.dart';

class LoginInfo {
  static const _usernameKey = 'username';
  static const _fullNameKey = 'fullName';
  static const _isOnBreakKey = 'isOnBreak';

  final ApiAuth auth;
  final String username;
  final String fullName;
  final bool isOnBreak;

  const LoginInfo(
    this.auth,
    this.username,
    this.fullName,
    this.isOnBreak,
  );

  factory LoginInfo.fromSharedPreferences(SharedPreferences instance) {
    return LoginInfo(
      ApiAuth.fromSharedPreferences(instance),
      instance.getString(_usernameKey)!,
      instance.getString(_fullNameKey)!,
      instance.getBool(_isOnBreakKey)!,
    );
  }

  Future toSharedPreferences(SharedPreferences instance) async {
    await auth.toSharedPreferences(instance);
    await instance.setString(_usernameKey, username);
    await instance.setString(_fullNameKey, fullName);
    await instance.setBool(_isOnBreakKey, isOnBreak);
  }

  Future clearSharedPreferences(SharedPreferences instance) async {
    await auth.clearSharedPreferences(instance);
    await instance.remove(_usernameKey);
    await instance.remove(_fullNameKey);
    await instance.remove(_isOnBreakKey);
  }
}
