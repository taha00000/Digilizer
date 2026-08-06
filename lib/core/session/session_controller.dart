import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/token_store.dart';
import 'app_session.dart';

/// Holds the current [AppSession], or null when signed out.
///
/// The auth feature writes to this after a successful sign-in; everything else
/// only reads. The router listens to it to gate `/dashboard`.
class SessionController extends StateNotifier<AppSession?> {
  SessionController() : super(null);

  void signIn(AppSession session) => state = session;

  void signOut() => state = null;
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, AppSession?>(
  (ref) => SessionController(),
);

/// Convenience for widgets that need the user and can assume one is present.
final currentSessionProvider = Provider<AppSession?>(
  (ref) => ref.watch(sessionControllerProvider),
);

/// App-wide sign-out: clears the stored token and drops the session, which the
/// router picks up and redirects to /login.
///
/// This lives in core rather than the auth feature so any screen can call it
/// without a cross-feature import (HANDOFF.md §5.7).
/// This is the single sign-out path in the app — do not add a second one in a
/// feature, or the two will drift apart.
///
/// TODO(real-api): also drop the Drift cache here once it exists, so the next
/// user cannot see the previous user's data.
final signOutProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await ref.read(tokenStoreProvider).clear();
    ref.read(sessionControllerProvider.notifier).signOut();
  };
});

/// A [Listenable] view of the session, for `GoRouter.refreshListenable`.
class SessionRefreshNotifier extends ChangeNotifier {
  SessionRefreshNotifier(this._ref) {
    _ref.listen<AppSession?>(
      sessionControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  // ignore: unused_field
  final Ref _ref;
}
