import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'data/services/storage_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/network_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // App Check
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    );
  } catch (e) {
    debugPrint('AppCheck activation notice: $e');
  }
  
  // Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await StorageService.instance.init();
  await StorageService.instance.ensureNotificationsDefaultEnabled();
  await NotificationService.instance.init();
  await NetworkService.instance.init();

  runApp(
    const ProviderScope(
      child: MindSparkApp(),
    ),
  );
}
