import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';
import 'package:shuttlebee/presentation/providers/auth_notifier.dart';
import 'package:shuttlebee/presentation/providers/trip_list_notifier.dart';
import 'package:shuttlebee/routes/app_router.dart';

/// صفحة السائق الرئيسية
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadTodayTrips();
  }

  Future<void> _loadTodayTrips() async {
    final authState = ref.read(authNotifierProvider);
    if (authState.user != null && authState.user!.partnerId != null) {
      final driverId = authState.user!.partnerId!;
      await ref.read(tripListNotifierProvider.notifier).loadDriverDailyTrips(
            driverId,
            DateTime.now(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final tripListState = ref.watch(tripListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('رحلاتي اليومية'),
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTodayTrips,
        child: Column(
          children: [
            // User Info Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً، ${authState.user?.name ?? "السائق"}',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now()),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Statistics Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'مجموع الرحلات',
                      '${tripListState.trips.length}',
                      Icons.route,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildStatCard(
                      'الرحلات الجارية',
                      '${tripListState.trips.where((t) => t.isOngoing).length}',
                      Icons.directions_bus,
                      AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _buildStatCard(
                      'منتهية',
                      '${tripListState.trips.where((t) => t.isCompleted).length}',
                      Icons.check_circle,
                      AppColors.success,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Trips List
            Expanded(
              child: _buildTripsList(tripListState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            title,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(tripListState) {
    if (tripListState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tripListState.error != null) {
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
              tripListState.error!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _loadTodayTrips,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (tripListState.trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'لا توجد رحلات اليوم',
              style: AppTextStyles.heading4.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'ستظهر رحلاتك هنا',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: tripListState.trips.length,
      itemBuilder: (context, index) {
        final trip = tripListState.trips[index];
        return _buildTripCard(trip);
      },
    );
  }

  Widget _buildTripCard(TripEntity trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          context.go('${AppRoutes.driverHome}/trip/${trip.id}');
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Trip State Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: trip.state.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      trip.state.arabicLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: trip.state.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Trip Type Icon
                  Icon(
                    trip.tripType == TripType.pickup
                        ? Icons.arrow_circle_up
                        : Icons.arrow_circle_down,
                    color: trip.tripType == TripType.pickup
                        ? AppColors.primary
                        : AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    trip.tripType.arabicLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: trip.tripType == TripType.pickup
                          ? AppColors.primary
                          : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Trip Name
              Text(
                trip.name,
                style: AppTextStyles.heading4,
              ),

              const SizedBox(height: AppSpacing.xs),

              // Group Name
              if (trip.groupName != null)
                Row(
                  children: [
                    const Icon(
                      Icons.group,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      trip.groupName!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: AppSpacing.sm),

              // Time Info
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    trip.plannedStartTime != null
                        ? DateFormat('HH:mm').format(trip.plannedStartTime!)
                        : '--:--',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    trip.plannedArrivalTime != null
                        ? DateFormat('HH:mm').format(trip.plannedArrivalTime!)
                        : '--:--',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Passengers Info
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${trip.totalPassengers} راكب',
                    style: AppTextStyles.bodySmall,
                  ),
                  if (trip.isOngoing) ...[
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'صعد: ${trip.boardedCount}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'غائب: ${trip.absentCount}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),

              // Action Button
              if (trip.canStart || trip.isOngoing) ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('${AppRoutes.driverHome}/trip/${trip.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          trip.canStart ? AppColors.primary : AppColors.warning,
                    ),
                    child: Text(
                      trip.canStart ? 'بدء الرحلة' : 'إدارة الرحلة',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
