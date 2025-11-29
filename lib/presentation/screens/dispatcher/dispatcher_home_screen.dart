import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/presentation/providers/auth_notifier.dart';
import 'package:shuttlebee/presentation/providers/dispatcher/dispatcher_dashboard_notifier.dart';
import 'package:shuttlebee/presentation/providers/dispatcher/dispatcher_dashboard_state.dart';
import 'package:shuttlebee/routes/app_router.dart';
import 'package:shuttlebee/domain/entities/user_entity.dart';

/// Dispatcher Home Screen - الصفحة الرئيسية للمرسل
class DispatcherHomeScreen extends ConsumerStatefulWidget {
  const DispatcherHomeScreen({super.key});

  @override
  ConsumerState<DispatcherHomeScreen> createState() =>
      _DispatcherHomeScreenState();
}

class _DispatcherHomeScreenState extends ConsumerState<DispatcherHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Avoid mutating providers during build by deferring to the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboard());
  }

  Future<void> _loadDashboard() async {
    await ref
        .read(dispatcherDashboardNotifierProvider.notifier)
        .loadDashboardStats();
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
    final dashboardState = ref.watch(dispatcherDashboardNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة تحكم المرسل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
            tooltip: 'تحديث',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'تسجيل خروج',
          ),
        ],
      ),
      body: dashboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardState.error != null
              ? _buildErrorState(dashboardState.error!)
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info Header
                        _buildUserHeader(user),

                        const SizedBox(height: AppSpacing.lg),

                        // Quick Actions
                        Text(
                          'الإجراءات السريعة',
                          style: AppTextStyles.heading3,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _buildQuickActions(),

                        const SizedBox(height: AppSpacing.lg),

                        // Statistics
                        const Text(
                          'إحصائيات اليوم',
                          style: AppTextStyles.heading3,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _buildTripStatistics(dashboardState),

                        const SizedBox(height: AppSpacing.lg),

                        // Resources Statistics
                        Text(
                          'الموارد',
                          style: AppTextStyles.heading3,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _buildResourceStatistics(dashboardState),
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
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            error,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _loadDashboard,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(UserEntity? user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary,
              child: Text(
                user?.name != null ? user!.name.substring(0, 1).toUpperCase() : 'D',
                style: AppTextStyles.heading2.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'مرسل',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مرسل النقل المدرسي',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _buildQuickActionCard(
          icon: Icons.add_road,
          label: 'إنشاء رحلة جديدة',
          color: AppColors.primary,
          onTap: () {
            context.go('${AppRoutes.dispatcherHome}/trips/create');
          },
        ),
        _buildQuickActionCard(
          icon: Icons.list_alt,
          label: 'إدارة الرحلات',
          color: AppColors.success,
          onTap: () {
            context.go('${AppRoutes.dispatcherHome}/trips');
          },
        ),
        _buildQuickActionCard(
          icon: Icons.directions_bus,
          label: 'إدارة المركبات',
          color: AppColors.warning,
          onTap: () {
            context.go('${AppRoutes.dispatcherHome}/vehicles');
          },
        ),
        _buildQuickActionCard(
          icon: Icons.map,
          label: 'المراقبة الحية',
          color: AppColors.error,
          onTap: () {
            context.go('${AppRoutes.dispatcherHome}/monitor');
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
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
              Icon(
                icon,
                size: 36,
                color: color,
              ),
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

  Widget _buildTripStatistics(DispatcherDashboardState dashboardState) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'المجموع',
            '${dashboardState.totalTripsToday}',
            Icons.calendar_today,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            'جارية',
            '${dashboardState.ongoingTrips}',
            Icons.play_circle,
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceStatistics(DispatcherDashboardState dashboardState) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'منتهية',
                '${dashboardState.completedTrips}',
                Icons.check_circle,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                'ملغاة',
                '${dashboardState.cancelledTrips}',
                Icons.cancel,
                AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'المركبات',
                '${dashboardState.activeVehicles}/${dashboardState.totalVehicles}',
                Icons.directions_bus,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                'السائقين',
                '${dashboardState.activeDrivers}/${dashboardState.totalDrivers}',
                Icons.person,
                AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
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
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
