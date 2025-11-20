import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/presentation/providers/auth_notifier.dart';
import 'package:shuttlebee/routes/app_router.dart';

/// Splash Screen - شاشة البداية
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // انتظر قليلاً لعرض الشاشة
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);

    if (!mounted) return;

    if (authState.isAuthenticated && authState.user != null) {
      // الانتقال للصفحة الرئيسية حسب الدور
      final homeRoute = _getHomeRouteForUser(authState.user!.role);
      context.go(homeRoute);
    } else {
      // الانتقال لصفحة تسجيل الدخول
      context.go(AppRoutes.login);
    }
  }

  String _getHomeRouteForUser(role) {
    switch (role) {
      case UserRole.driver:
        return AppRoutes.driverHome;
      case UserRole.dispatcher:
        return AppRoutes.dispatcherHome;
      case UserRole.passenger:
        return AppRoutes.passengerHome;
      case UserRole.manager:
        return AppRoutes.managerHome;
      default:
        return AppRoutes.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                ),
                child: const Icon(
                  Icons.directions_bus,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // App Name
              const Text(
                'ShuttleBee',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: AppTextStyles.fontFamilyArabic,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              const Text(
                'نظام إدارة النقل المدرسي والشركات',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontFamily: AppTextStyles.fontFamilyArabic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
