/// A signed-in session. Pure domain entity — no Flutter, no packages.
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.displayName,
    required this.company,
    required this.accountCode,
    required this.token,
  });

  final String userId;
  final String displayName;
  final String company;
  final String accountCode;
  final String token;
}
