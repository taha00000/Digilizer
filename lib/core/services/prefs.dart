import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive preferences (selected theme, remembered username).
/// Anything secret belongs in `TokenStore`, never here.
///
/// Overridden in `main()` once the instance has been awaited.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPrefsProvider must be overridden in main()',
  ),
);
