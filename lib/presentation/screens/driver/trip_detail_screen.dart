import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/presentation/providers/active_trip_notifier.dart';
import 'package:shuttlebee/routes/app_router.dart';

/// Trip Detail Screen - عرض تفاصيل الرحلة
class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({
    required this.tripId,
    super.key,
  });

  final int tripId;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadTripDetails();
  }

  Future<void> _loadTripDetails() async {
    await ref.read(activeTripNotifierProvider.notifier).loadTrip(widget.tripId);
  }

  Future<void> _handleStartTrip() async {
    final success = await ref.read(activeTripNotifierProvider.notifier).startTrip();

    if (!mounted) return;

    if (success) {
      // Navigate to Active Trip Screen
      context.go('${AppRoutes.driverHome}/trip/${widget.tripId}/active');
    } else {
      // Show error
      final state = ref.read(activeTripNotifierProvider);
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleCancelTrip() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الرحلة'),
        content: const Text('هل أنت متأكد من إلغاء هذه الرحلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('إلغاء الرحلة'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref.read(activeTripNotifierProvider.notifier).cancelTrip();

    if (!mounted) return;

    if (success) {
      // Navigate back to home
      context.go(AppRoutes.driverHome);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء الرحلة بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeTripNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تفاصيل الرحلة'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildErrorState(state.error!)
              : state.trip == null
                  ? const Center(child: Text('لم يتم العثور على الرحلة'))
                  : _buildTripDetails(state),
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
            onPressed: _loadTripDetails,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails(state) {
    final trip = state.trip!;
    final passengers = state.passengers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Trip Header Card
          _buildHeaderCard(trip),

          const SizedBox(height: AppSpacing.md),

          // Trip Information Card
          _buildInfoCard(trip),

          const SizedBox(height: AppSpacing.md),

          // Passenger Statistics Card
          _buildPassengerStatsCard(trip, passengers),

          const SizedBox(height: AppSpacing.md),

          // Action Buttons
          _buildActionButtons(trip),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Name
            Text(
              trip.name,
              style: AppTextStyles.heading3,
            ),

            const SizedBox(height: AppSpacing.sm),

            // State and Type Badges
            Row(
              children: [
                // State Badge
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

                const SizedBox(width: AppSpacing.sm),

                // Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (trip.tripType == TripType.pickup
                            ? AppColors.primary
                            : AppColors.success)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trip.tripType == TripType.pickup
                            ? Icons.arrow_circle_up
                            : Icons.arrow_circle_down,
                        color: trip.tripType == TripType.pickup
                            ? AppColors.primary
                            : AppColors.success,
                        size: 16,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الرحلة',
              style: AppTextStyles.heading4,
            ),

            const SizedBox(height: AppSpacing.md),

            // Group
            if (trip.groupName != null) ...[
              _buildInfoRow(
                Icons.group,
                'المجموعة',
                trip.groupName!,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Vehicle
            if (trip.vehicleName != null) ...[
              _buildInfoRow(
                Icons.directions_bus,
                'المركبة',
                trip.vehicleName!,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Date
            _buildInfoRow(
              Icons.calendar_today,
              'التاريخ',
              DateFormat('EEEE، d MMMM yyyy', 'ar').format(trip.date),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Planned Time
            _buildInfoRow(
              Icons.access_time,
              'الوقت المخطط',
              '${trip.plannedStartTime != null ? DateFormat('HH:mm').format(trip.plannedStartTime!) : '--:--'} - ${trip.plannedArrivalTime != null ? DateFormat('HH:mm').format(trip.plannedArrivalTime!) : '--:--'}',
            ),

            // Actual Times (if trip started)
            if (trip.actualStartTime != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(
                Icons.play_circle,
                'وقت البدء الفعلي',
                DateFormat('HH:mm').format(trip.actualStartTime!),
                valueColor: AppColors.success,
              ),
            ],

            if (trip.actualArrivalTime != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(
                Icons.check_circle,
                'وقت الوصول الفعلي',
                DateFormat('HH:mm').format(trip.actualArrivalTime!),
                valueColor: AppColors.success,
              ),
            ],

            // Distance
            if (trip.plannedDistance != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(
                Icons.route,
                'المسافة المخططة',
                '${trip.plannedDistance!.toStringAsFixed(1)} كم',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Row(
            children: [
              Text(
                '$label: ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerStatsCard(trip, passengers) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات الركاب',
              style: AppTextStyles.heading4,
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'المجموع',
                    '${trip.totalPassengers}',
                    Icons.people,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatItem(
                    'صعد',
                    '${trip.boardedCount}',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'غائب',
                    '${trip.absentCount}',
                    Icons.cancel,
                    AppColors.error,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatItem(
                    'نزل',
                    '${trip.droppedCount}',
                    Icons.logout,
                    AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Passenger List Preview
            if (passengers.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'الركاب (${passengers.length})',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...passengers.take(3).map((passenger) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          passenger.passengerName ?? 'راكب',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: passenger.status.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          passenger.status.arabicLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: passenger.status.color,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (passengers.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    'و ${passengers.length - 3} آخرين...',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.heading4.copyWith(color: color),
          ),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(trip) {
    return Column(
      children: [
        // Start Trip Button
        if (trip.canStart)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleStartTrip,
              icon: const Icon(Icons.play_circle),
              label: const Text('بدء الرحلة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),

        // View Active Trip Button
        if (trip.isOngoing) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('${AppRoutes.driverHome}/trip/${widget.tripId}/active');
              },
              icon: const Icon(Icons.navigation),
              label: const Text('إدارة الرحلة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Cancel Trip Button
        if (trip.state == TripState.planned || trip.state == TripState.ongoing)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _handleCancelTrip,
              icon: const Icon(Icons.cancel),
              label: const Text('إلغاء الرحلة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
      ],
    );
  }
}
