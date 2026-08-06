import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Matches the app's font policy inside tests, and makes icons reviewable.
///
/// Inter is bundled under `assets/google_fonts/`, so google_fonts resolves it
/// from the asset bundle — which `flutter test` serves. Refusing runtime
/// fetching mirrors `main()` and makes a missing font a loud failure rather
/// than a silent fallback that would quietly change every golden.
///
/// MaterialIcons is a different problem: the test binding ships no icon font,
/// so every `Icon` renders as a filled box. Loading it from the Flutter SDK
/// keeps goldens readable. This is test-only — the real app gets the icon font
/// from `uses-material-design: true`.
Future<void> loadTestFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await _loadMaterialIcons();
}

Future<void> _loadMaterialIcons() async {
  final flutterRoot = _flutterRoot();
  if (flutterRoot == null) return;

  final icons = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (!icons.existsSync()) return;

  final loader = FontLoader('MaterialIcons')
    ..addFont(
      icons
          .readAsBytes()
          .then((b) => ByteData.view(Uint8List.fromList(b).buffer)),
    );
  await loader.load();
}

/// Derives the SDK root from the running Dart executable so this works on any
/// machine and in CI, rather than hard-coding a local path.
String? _flutterRoot() {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

  // …/flutter/bin/cache/dart-sdk/bin/dart.exe → …/flutter
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 6; i++) {
    if (Directory('${dir.path}/bin/cache/artifacts/material_fonts')
        .existsSync()) {
      return dir.path;
    }
    dir = dir.parent;
  }
  return null;
}
