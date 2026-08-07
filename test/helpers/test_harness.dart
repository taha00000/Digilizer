import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eway/core/services/biometric_service.dart';
import 'package:eway/core/services/prefs.dart';
import 'package:eway/core/database/response_cache.dart';
import 'package:eway/core/services/token_store.dart';
import 'package:eway/core/session/app_session.dart';
import 'package:eway/core/session/session_controller.dart';
import 'package:eway/core/theme/app_theme.dart';

/// The demo session from the approved prototype.
const demoSession = AppSession(
  userId: 'demo-1',
  displayName: 'Demo Support',
  company: 'HILAL',
  accountCode: '999903',
);

/// Biometric stub for widget tests — the real plugin has no implementation in
/// the test binding.
class FakeBiometricService implements BiometricService {
  FakeBiometricService({
    this.available = false,
    this.result = BiometricResult.unavailable,
  });

  final bool available;
  final BiometricResult result;

  @override
  Future<bool> get isAvailable async => available;

  @override
  Future<BiometricResult> authenticate({required String reason}) async =>
      result;
}

/// Pumps [child] inside the full app shell: a ProviderScope with the platform
/// dependencies stubbed, and a MaterialApp carrying the [AppTokens] theme
/// extension every widget reads from.
///
/// Without the theme, `context.tokens` throws — which is exactly what a bare
/// `MaterialApp(home: ...)` in a test would do.
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  AppThemeId theme = AppThemeId.aurora,
  List<Override> overrides = const [],
  FakeBiometricService? biometrics,
  AppSession? session,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        biometricServiceProvider
            .overrideWithValue(biometrics ?? FakeBiometricService()),
        tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
        // The real cache opens a Drift database via path_provider, which has
        // no implementation in the test binding.
        responseCacheProvider.overrideWithValue(const NoopResponseCache()),
        if (session != null)
          sessionControllerProvider.overrideWith(
            (ref) => SessionController()..signIn(session),
          ),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.themeFor(theme),
        home: child,
      ),
    ),
  );
}
