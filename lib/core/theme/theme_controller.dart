import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/prefs.dart';
import 'app_theme.dart';

/// Holds the currently-selected theme and persists it to SharedPreferences,
/// mirroring the in-app theme switcher in the prototype's profile sheet.
class ThemeController extends StateNotifier<AppThemeId> {
  ThemeController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;
  static const _key = 'app_theme_id';

  static AppThemeId _load(SharedPreferences prefs) {
    final name = prefs.getString(_key);
    return AppThemeId.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AppThemeId.aurora, // Aurora is the default (client-approved)
    );
  }

  void setTheme(AppThemeId id) {
    if (id == state) return;
    state = id;
    _prefs.setString(_key, id.name);
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, AppThemeId>((ref) {
  return ThemeController(ref.watch(sharedPrefsProvider));
});
