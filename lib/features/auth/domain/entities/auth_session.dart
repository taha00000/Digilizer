/// What the server says this user is allowed to be.
///
/// Mirrored into `core/session/UserRole` when the session is published, so
/// other features can gate on it without importing the auth feature.
///
/// TODO(real-api): map this from whatever the client returns.
enum AuthRole { rep, manager }

/// A signed-in session. Pure domain entity — no Flutter, no packages.
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.displayName,
    required this.company,
    required this.accountCode,
    required this.token,
    required this.role,
  });

  final String userId;
  final String displayName;
  final String company;
  final String accountCode;
  final String token;
  final AuthRole role;
}
