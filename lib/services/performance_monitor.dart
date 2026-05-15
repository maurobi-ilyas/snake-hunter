import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static double _lastFrameTime = 0;
  static int _frameCount = 0;
  static double _fps = 60;
  static final List<double> _fpsHistory = [];

  static void recordFrame(double dt) {
    _frameCount++;
    _lastFrameTime += dt;
    
    if (_lastFrameTime >= 1.0) {
      _fps = _frameCount / _lastFrameTime;
      _fpsHistory.add(_fps);
      if (_fpsHistory.length > 60) _fpsHistory.removeAt(0);
      
      if (_fps < 50 && kDebugMode) {
        dev.log('PERF WARNING: Low FPS detected: ${_fps.toStringAsFixed(1)}', name: 'AntiLag');
      }
      
      _frameCount = 0;
      _lastFrameTime = 0;
    }
  }

  static double get currentFps => _fps;
  static bool get isLowPerformance => _fps < 45;
}
