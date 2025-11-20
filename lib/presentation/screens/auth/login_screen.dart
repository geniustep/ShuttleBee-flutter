import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/config/app_config.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/core/utils/logger.dart';

/// شاشة تسجيل الدخول
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _databaseController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill from .env for development
    _urlController.text = AppConfig.odooUrl;
    _databaseController.text = AppConfig.odooDatabase;
    _usernameController.text = AppConfig.odooUsername;
    _passwordController.text = AppConfig.odooPassword;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _databaseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // استخدام AuthNotifier بدلاً من Repository مباشرة
    await ref.read(authNotifierProvider.notifier).login(
      url: _urlController.text.trim(),
      database: _databaseController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    // التحقق من حالة المصادقة بعد المحاولة
    final authState = ref.read(authNotifierProvider);

    if (authState.error != null) {
      // عرض الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.error!),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (authState.isAuthenticated) {
      // النجاح - سيتم التوجيه تلقائياً عبر GoRouter
      AppLogger.info('Login successful - redirecting...');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  const Text(
                    'مرحباً بك',
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  const Text(
                    'قم بتسجيل الدخول للمتابعة',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // URL Field
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط Odoo',
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    textDirection: TextDirection.ltr,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رابط Odoo';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Database Field
                  TextFormField(
                    controller: _databaseController,
                    decoration: const InputDecoration(
                      labelText: 'قاعدة البيانات',
                      prefixIcon: Icon(Icons.storage),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم قاعدة البيانات';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال اسم المستخدم';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Login Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('تسجيل الدخول'),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Version Info
                  Text(
                    'الإصدار ${AppConfig.appVersion}',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
