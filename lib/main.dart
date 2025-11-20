import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/config/app_config.dart';
import 'package:shuttlebee/core/theme/app_theme.dart';
import 'package:shuttlebee/core/utils/logger.dart';
import 'package:shuttlebee/presentation/screens/splash/splash_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await AppConfig.load();

  // Print config (development only)
  AppConfig.printConfig();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  AppLogger.info('ShuttleBee App Starting...');

  // Run app with Riverpod
  runApp(
    const ProviderScope(
      child: ShuttleBeeApp(),
    ),
  );
}

/// ShuttleBee App Widget
class ShuttleBeeApp extends StatelessWidget {
  const ShuttleBeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // TODO: Make this dynamic

      // Localization
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],

      // Home
      home: const SplashScreen(),

      // Builder for overlay widgets
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // RTL for Arabic
          child: child!,
        );
      },
    );
  }
}
