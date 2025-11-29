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
import 'package:shuttlebee/presentation/providers/passenger/passenger_trips_notifier.dart';
import 'package:shuttlebee/routes/app_router.dart';

/// Passenger Home Screen - الصفحة الرئيسية للراكب
class PassengerHomeScreen extends ConsumerStatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  ConsumerState<PassengerHomeScreen> createState() =>
      _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends ConsumerState<PassengerHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Defer loading until after first frame to avoid modifying providers during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrips();
    });
  }

  Future<void> _loadTrips() async {
    await ref.read(passengerTripsNotifierProvider.notifier).loadMyTrips();
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
    final tripsState = ref.watch(passengerTripsNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('رحلاتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'تسجيل خروج',
          ),
        ],
      ),
      body: tripsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tripsState.error != null
              ? _buildErrorState(tripsState.error!)
              : RefreshIndicator(
                  onRefresh: _loadTrips,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Header
                        _buildUserHeader(user),

                        const SizedBox(height: AppSpacing.lg),

                        // Active Trip (if any)
                        if (tripsState.hasActiveTrip) ...[
                          Text(
                            'الرحلة النشطة',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildActiveTripCard(tripsState.activeTrip!),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // Today's Trips
                        if (tripsState.todayTrips.isNotEmpty) ...[
                          Text(
                            'رحلات اليوم',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...tripsState.todayTrips
                              .map((trip) => _buildTripCard(trip)),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // Upcoming Trips
                        if (tripsState.upcomingTrips.isNotEmpty) ...[
                          Text(
                            'الرحلات القادمة',
                            style: AppTextStyles.heading3,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...tripsState.upcomingTrips
                              .take(5)
                              .map((trip) => _buildTripCard(trip)),
                        ],

                        // Empty State
                        if (tripsState.todayTrips.isEmpty &&
                            tripsState.upcomingTrips.isEmpty) ...[
                          const SizedBox(height: AppSpacing.xxl),
                          _buildEmptyState(),
                        ],
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
            onPressed: _loadTrips,
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
              backgroundColor: AppColors.success,
              child: Text(
                user?.name?.substring(0, 1).toUpperCase() ?? 'P',
                style: AppTextStyles.heading2.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'راكب',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'راكب',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.person, size: 32, color: AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTripCard(TripEntity trip) {
    return Card(
      color: AppColors.primary.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          context.go('${AppRoutes.passengerHome}/track/${trip.id}');
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.navigation,
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
                          trip.name,
                          style: AppTextStyles.heading4,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الرحلة جارية',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_left,
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      trip.tripType == TripType.pickup
                          ? Icons.arrow_circle_up
                          : Icons.arrow_circle_down,
                      size: 20,
                      color: trip.tripType == TripType.pickup
                          ? AppColors.primary
                          : AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      trip.tripType.arabicLabel,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const Spacer(),
                    if (trip.vehicleName != null) ...[
                      const Icon(Icons.directions_bus, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        trip.vehicleName!,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('${AppRoutes.passengerHome}/track/${trip.id}');
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('تتبع الرحلة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(TripEntity trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  trip.tripType == TripType.pickup
                      ? Icons.arrow_circle_up
                      : Icons.arrow_circle_down,
                  size: 24,
                  color: trip.tripType == TripType.pickup
                      ? AppColors.primary
                      : AppColors.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    trip.name,
                    style: AppTextStyles.heading4,
                  ),
                ),
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
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('EEEE، d MMMM yyyy', 'ar').format(trip.date),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            if (trip.plannedStartTime != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('HH:mm').format(trip.plannedStartTime!),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
            if (trip.vehicleName != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Icon(Icons.directions_bus, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    trip.vehicleName!,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'لا توجد رحلات مجدولة',
            style: AppTextStyles.heading3.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'سيتم عرض رحلاتك هنا عندما تكون متاحة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
