import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Outcome of a biometric prompt, so callers can tell "user said no" apart
/// from "this device can't do biometrics at all".
enum BiometricResult {
  /// The user passed Face ID / Touch ID / fingerprint.
  success,

  /// Prompt shown, user cancelled or failed.
  failed,

  /// No hardware, nothing enrolled, or an unsupported platform (desktop/web).
  /// Callers fall back to password sign-in.
  unavailable,
}

/// Thin wrapper over `local_auth`. Keeping the plugin behind this interface
/// means the auth repository stays testable — tests inject a fake.
abstract interface class BiometricService {
  Future<bool> get isAvailable;
  Future<BiometricResult> authenticate({required String reason});
}

class LocalAuthBiometricService implements BiometricService {
  LocalAuthBiometricService([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> get isAvailable async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      // Desktop / web, where local_auth has no implementation.
      return false;
    }
  }

  @override
  Future<BiometricResult> authenticate({required String reason}) async {
    if (!await isAvailable) return BiometricResult.unavailable;

    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return ok ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException {
      return BiometricResult.unavailable;
    } on MissingPluginException {
      return BiometricResult.unavailable;
    }
  }
}

final biometricServiceProvider = Provider<BiometricService>(
  (ref) => LocalAuthBiometricService(),
);
