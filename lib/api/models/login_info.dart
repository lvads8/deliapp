import 'api_auth.dart';

class LoginInfo {
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
}
