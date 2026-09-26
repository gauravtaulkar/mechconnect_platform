import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:io' show Platform;

// FIX: baseUrl used to be a hardcoded `http://127.0.0.1:8080` inside
// api_service.dart. That only works when the app and the backend run on
// literally the same machine (e.g. Flutter web/desktop during development).
// It silently breaks on:
//   - an Android emulator (127.0.0.1 there means "the emulator itself")
//   - a real phone/tablet (127.0.0.1 there means "the phone itself")
// which is the single most common reason "everything just times out and
// the screen stays blank" during local testing.
class AppConfig {
  /// Set this to your machine's LAN IP when testing on a REAL device, e.g.
  /// 'http://192.168.1.23:8080'. Leave blank to use the automatic defaults
  /// below (correct for emulators/simulators/desktop/web).
  static const String manualOverride = 'http://10.75.72.42:8080';

  static String get baseUrl {
    if (manualOverride.isNotEmpty) return manualOverride;
    if (kIsWeb) return 'http://127.0.0.1:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {
      // Platform isn't available on some targets (e.g. web) — kIsWeb above
      // already handles that case, this catch just protects against
      // anything unexpected.
    }
    return 'http://127.0.0.1:8080'; // iOS simulator, desktop
  }
}
