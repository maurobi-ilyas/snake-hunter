import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class ErrorService {
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exceptionAsString(), details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error.toString(), stack);
      return true;
    };
  }

  static void _logError(String error, StackTrace? stack) {
    dev.log('CRITICAL ERROR: $error', name: 'AntiCrash', stackTrace: stack);
    // In production, we would send this to a service like Sentry or Firebase Crashlytics
  }

  static T safeRun<T>(T Function() action, T fallback) {
    try {
      return action();
    } catch (e, stack) {
      _logError(e.toString(), stack);
      return fallback;
    }
  }
}
