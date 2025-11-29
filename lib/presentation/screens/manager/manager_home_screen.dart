import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/presentation/providers/auth_notifier.dart';
import 'package:shuttlebee/presentation/providers/manager/manager_analytics_notifier.dart';
import 'package:shuttlebee/routes/app_router.dart';

/// Manager Home Screen - الصفحة الرئيسية للمدير
class ManagerHomeScreen extends ConsumerStatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  ConsumerState<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends ConsumerState<ManagerHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule after first frame so provider changes don't happen during build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAnalytics());
  }

  Future<void> _loadAnalytics() async {
    await ref.read(managerAnalyticsNotifierProvider.notifier).loadAnalytics();
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
              if (mounted) {
                context.go(AppRoutes.login);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(managerAnalyticsNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة تحكم المدير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'تحديث',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'تسجيل خروج',
          ),
        ],
      ),
      body: analyticsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : analyticsState.error != null
              ? _buildErrorState(analyticsState.error!)
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Header
                        _buildUserHeader(user),

                        const SizedBox(height: AppSpacing.lg),

                        // Quick Navigation
                        _buildQuickNavigation(),

                        const SizedBox(height: AppSpacing.lg),

                        // Key Metrics
                        Text(
                          'المقاييس الرئيسية - ${DateFormat('MMMM yyyy', 'ar').format(DateTime.now())}',
                          style: AppTextStyles.heading3,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _buildKeyMetrics(analyticsState),

                        const SizedBox(height: AppSpacing.lg),

                        // Performance Metrics
                        Text(
                          'مقاييس الأداء',
                          style: AppTextStyles.heading3,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _buildPerformanceMetrics(analyticsState),

                        const SizedBox(height: AppSpacing.lg),

                        // Resource Utilization
                        Text(
                          'استخدام الموارد',
                          style: AppTextStyles.heading3,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _buildResourceUtilization(analyticsState),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text(error, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _loadAnalytics,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.error,
              child: Text(
                user?.name?.substring(0, 1).toUpperCase() ?? 'M',
                style: AppTextStyles.heading2.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'مدير',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مدير النقل',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.admin_panel_settings, size: 32, color: AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickNavigation() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _buildNavCard(
          icon: Icons.bar_chart,
          label: 'التحليلات المتقدمة',
          color: AppColors.primary,
          onTap: () {
            context.go('${AppRoutes.managerHome}/analytics');
          },
        ),
        _buildNavCard(
          icon: Icons.description,
          label: 'التقارير',
          color: AppColors.success,
          onTap: () {
            context.go('${AppRoutes.managerHome}/reports');
          },
        ),
        _buildNavCard(
          icon: Icons.dashboard,
          label: 'نظرة عامة',
          color: AppColors.warning,
          onTap: () {
            context.go('${AppRoutes.managerHome}/overview');
          },
        ),
        _buildNavCard(
          icon: Icons.settings,
          label: 'الإعدادات',
          color: AppColors.error,
          onTap: () {
            // TODO: Navigate to settings
          },
        ),
      ],
    );
  }

  Widget _buildNavCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'إجمالي الرحلات',
                '${state.totalTripsThisMonth}',
                Icons.route,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMetricCard(
                'منتهية',
                '${state.completedTripsThisMonth}',
                Icons.check_circle,
                AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'معدل الإنجاز',
                '${state.completionRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMetricCard(
                'معدل الإلغاء',
                '${state.cancellationRate.toStringAsFixed(1)}%',
                Icons.trending_down,
                state.cancellationRate > 10 ? AppColors.error : AppColors.warning,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics(state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'الركاب',
                '${state.totalPassengersTransported}',
                Icons.people,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMetricCard(
                'معدل الإشغال',
                '${state.averageOccupancyRate.toStringAsFixed(1)}%',
                Icons.event_seat,
                AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'في الموعد',
                '${state.onTimePercentage.toStringAsFixed(1)}%',
                Icons.schedule,
                state.onTimePercentage >= 80
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMetricCard(
                'متوسط التأخير',
                '${state.averageDelayMinutes.toStringAsFixed(0)} د',
                Icons.timer,
                state.averageDelayMinutes <= 5
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResourceUtilization(state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'المسافة الكلية',
                '${state.totalDistanceKm.toStringAsFixed(0)} كم',
                Icons.map,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMetricCard(
                'متوسط المسافة',
                '${state.averageDistancePerTrip.toStringAsFixed(1)} كم',
                Icons.straighten,
                AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.warning.withOpacity(0.1), AppColors.warning.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.local_gas_station,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تكلفة الوقود المقدرة',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.estimatedFuelCost.toStringAsFixed(0)} ريال',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
