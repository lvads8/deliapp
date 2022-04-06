class ApiAuth {
  final String authorization;
  final String secret;

  const ApiAuth(this.authorization, this.secret);

  Map<String, String> toHeader() {
    return {
      'www-auth': authorization,
      'client_secret_key': secret,
    };
  }
}
