/// The app-level view of "who is signed in".
///
/// This lives in `core/` rather than in the auth feature on purpose: the
/// dashboard (and later Team, Reports, Call Reporting) need the signed-in
/// user's identity, and features must not import each other (HANDOFF.md §5.7).
/// The auth feature maps its own `AuthSession` entity into this type.
/// What the signed-in user is allowed to see.
///
/// The prototype implies two audiences — a field rep logging their own visits,
/// and a manager who can also see their team's numbers — but never specifies
/// the role model.
///
/// TODO(real-api): this is PROVISIONAL. Replace with whatever the client
/// actually returns (they may have ZSM / ASM / NSM tiers rather than a flat
/// two-role split). Everything gates on [AppSession.canViewTeam], so widening
/// this is a one-file change.
enum UserRole {
  /// Field rep: own dashboard, calls and reports only.
  rep,

  /// Manager: additionally sees My Team and per-rep breakdowns.
  manager,
}

class AppSession {
  const AppSession({
    required this.userId,
    required this.displayName,
    required this.company,
    required this.accountCode,
    required this.role,
  });

  final String userId;
  final String displayName;
  final String company;
  final String accountCode;
  final UserRole role;

  /// A rep must not see the zone's or their colleagues' performance.
  bool get canViewTeam => role == UserRole.manager;

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
