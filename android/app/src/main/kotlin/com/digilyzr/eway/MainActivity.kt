package com.digilyzr.eway

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * Must extend FlutterFragmentActivity, not FlutterActivity.
 *
 * local_auth shows the Android biometric prompt as a Fragment. On a plain
 * FlutterActivity it fails at runtime with `no_fragment_activity`, so the
 * Face ID / fingerprint button would never work on Android.
 */
class MainActivity : FlutterFragmentActivity()
