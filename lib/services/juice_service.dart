import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/performance_monitor.dart';

class JuiceService {
  static void buttonTap() {
    HapticFeedback.lightImpact();
  }

  static void success() {
    HapticFeedback.mediumImpact();
  }

  static double get particleCountMultiplier {
    if (PerformanceMonitor.isLowPerformance) return 0.3;
    return 1.0;
  }

  static bool get enableHeavyEffects {
    return !PerformanceMonitor.isLowPerformance;
  }
}
