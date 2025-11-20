import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/presentation/screens/auth/login_screen.dart';

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

    // تحقق من حالة المصادقة
    final authRepository = ref.read(authRepositoryProvider);
    final isAuthenticated = await authRepository.isAuthenticated();

    if (!mounted) return;

    if (isAuthenticated) {
      // TODO: Navigate to home screen based on user role
      // For now, go to login
      _navigateToLogin();
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
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
