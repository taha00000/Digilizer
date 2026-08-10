import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/calls/presentation/screens/calls_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/modules/presentation/screens/modules_screen.dart';
import '../../features/reports/presentation/screens/report_output_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/team/presentation/screens/rep_detail_screen.dart';
import '../../features/team/presentation/screens/team_screen.dart';
import '../session/session_controller.dart';

/// App routes. Start at login; on success the session guard below sends the
/// user to /dashboard.
///
/// Sub-screens highlight their parent bottom tab, the way TABMAP does in the
/// prototype: /calls maps to Modules, /team/rep to Team, /reports/activity to
/// Reports. That mapping lives on each screen's `AppShell(tab: …)`.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = SessionRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final signedIn = session != null;
      final atLogin = state.matchedLocation == '/login';

      if (!signedIn && !atLogin) return '/login';
      if (signedIn && atLogin) return '/dashboard';

      // Hiding the Team tab is presentation. This is the actual gate: a rep
      // must not reach team routes by deep link, back-stack or a stale
      // location restored on launch.
      if (signedIn &&
          !session.canViewTeam &&
          state.matchedLocation.startsWith('/team')) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/modules', builder: (_, __) => const ModulesScreen()),
      GoRoute(path: '/calls', builder: (_, __) => const CallsScreen()),
      GoRoute(path: '/team', builder: (_, __) => const TeamScreen()),
      GoRoute(
        path: '/team/rep/:code',
        builder: (_, state) =>
            RepDetailScreen(code: state.pathParameters['code'] ?? ''),
      ),
      GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
      GoRoute(
        path: '/reports/activity',
        builder: (_, __) => const ReportOutputScreen(),
      ),
    ],
  );
});
