import 'package:flutter/material.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';

/// Error Boundary Widget - للتعامل مع الأخطاء بشكل أنيق
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    required this.child,
    this.onError,
    this.errorWidget,
    super.key,
  });

  final Widget child;
  final void Function(Object error, StackTrace stackTrace)? onError;
  final Widget Function(Object error, StackTrace stackTrace)? errorWidget;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
        widget.onError?.call(details.exception, details.stack ?? StackTrace.empty);
      }
    };
  }

  void _reset() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorWidget?.call(_error!, _stackTrace!) ??
          _DefaultErrorWidget(
            error: _error!,
            stackTrace: _stackTrace!,
            onReset: _reset,
          );
    }

    return widget.child;
  }
}

/// Default Error Widget
class _DefaultErrorWidget extends StatelessWidget {
  const _DefaultErrorWidget({
    required this.error,
    required this.stackTrace,
    required this.onReset,
  });

  final Object error;
  final StackTrace stackTrace;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'حدث خطأ غير متوقع',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'نعتذر عن هذا الإزعاج. يرجى المحاولة مرة أخرى.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Error details (in debug mode)
                if (const bool.fromEnvironment('dart.vm.product') == false)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل الخطأ (Debug Mode):',
                          style: AppTextStyles.captionBold,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          error.toString(),
                          style: AppTextStyles.caption.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Error View Widget - لعرض الأخطاء داخل الشاشات
class ErrorView extends StatelessWidget {
  const ErrorView({
    required this.message,
    this.onRetry,
    this.showIcon = true,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon) ...[
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty State Widget - لعرض حالة فارغة
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.message,
    this.icon = Icons.inbox,
    this.action,
    this.actionLabel,
    super.key,
  });

  final String message;
  final IconData icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: action,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

