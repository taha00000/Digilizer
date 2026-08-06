import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../session/session_controller.dart';

/// App routes. Start at login; on success the session guard below sends the
/// user to /dashboard. Add /modules, /team, /reports as those screens land.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = SessionRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(sessionControllerProvider) != null;
      final atLogin = state.matchedLocation == '/login';

      if (!signedIn && !atLogin) return '/login';
      if (signedIn && atLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
    ],
  );
});
