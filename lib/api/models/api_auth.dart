class ApiAuth {
  final String authorization;
  final String secret;

  const ApiAuth._(this.authorization, this.secret);

  factory ApiAuth.fromHeaders(Map<String, String> headers) {
    return ApiAuth._(
      headers['www-authenticate']!,
      headers['client_secret_key']!,
    );
  }

  Map<String, String> toHeader() {
    return {
      'www-auth': authorization,
      'client_secret_key': secret,
    };
  }
}
