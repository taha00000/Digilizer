/// The app-level view of "who is signed in".
///
/// This lives in `core/` rather than in the auth feature on purpose: the
/// dashboard (and later Team, Reports, Call Reporting) need the signed-in
/// user's identity, and features must not import each other (HANDOFF.md §5.7).
/// The auth feature maps its own `AuthSession` entity into this type.
class AppSession {
  const AppSession({
    required this.userId,
    required this.displayName,
    required this.company,
    required this.accountCode,
  });

  final String userId;
  final String displayName;
  final String company;
  final String accountCode;

  /// "Demo Support" → "DS". Used for the dashboard avatar.
  String get initials {
    final parts =
        displayName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// "Demo Support · HILAL · ACC 999903"
  String get descriptor => '$displayName · $company · ACC $accountCode';
}
