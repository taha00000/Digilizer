import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inter ships in assets/google_fonts/. Refusing runtime fetching makes that
  // guarantee explicit: a rep in the field with no signal still gets correct
  // type instead of a silent fallback, and we never make a startup HTTP call.
  GoogleFonts.config.allowRuntimeFetching = false;

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const EwayApp(),
    ),
  );
}
