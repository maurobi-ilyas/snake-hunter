import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/services/firestore_service.dart';
import 'core/services/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to landscape & full screen
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Init local storage cache (enables sync getters)
  await LocalStorageService.init();

  // Firebase init — graceful degradation
  try {
    await Firebase.initializeApp();
    FirestoreService.markAvailable(); // ✅ Mark safe to use
  } catch (e) {
    debugPrint('[Firebase] Not configured yet: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Escape Evolution',
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
