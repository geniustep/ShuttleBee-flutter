import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/config/app_config.dart';
import 'package:shuttlebee/core/theme/app_theme.dart';
import 'package:shuttlebee/core/utils/logger.dart';
import 'package:shuttlebee/presentation/providers/auth_notifier.dart';
import 'package:shuttlebee/routes/app_router.dart';

// hbiba bayan
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
class ShuttleBeeApp extends ConsumerWidget {
  const ShuttleBeeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final router = createRouter(authState);

    return MaterialApp.router(
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Router
      routerConfig: router,

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
