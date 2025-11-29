import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';
import 'package:shuttlebee/presentation/providers/dispatcher/trip_management_notifier.dart';
import 'package:shuttlebee/routes/app_router.dart';

/// Dispatcher Trip Detail Screen - شاشة تفاصيل الرحلة للمرسل
class DispatcherTripDetailScreen extends ConsumerStatefulWidget {
  final int tripId;

  const DispatcherTripDetailScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<DispatcherTripDetailScreen> createState() =>
      _DispatcherTripDetailScreenState();
}

class _DispatcherTripDetailScreenState
    extends ConsumerState<DispatcherTripDetailScreen> {
  TripEntity? _trip;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  void _loadTrip() {
    final state = ref.read(tripManagementNotifierProvider);
    _trip = state.selectedTrip ??
        state.trips.firstWhere(
          (t) => t.id == widget.tripId,
          orElse: () => throw Exception('Trip not found'),
        );
  }

  Future<void> _handleEdit() async {
    ref.read(tripManagementNotifierProvider.notifier).selectTrip(_trip!);
    if (mounted) {
      context.go('${AppRoutes.dispatcherHome}/trips/${widget.tripId}/edit');
    }
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الرحلة'),
        content: Text('هل أنت متأكد من إلغاء رحلة "${_trip!.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('إلغاء الرحلة'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(tripManagementNotifierProvider.notifier)
        .cancelTrip(widget.tripId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء الرحلة بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(AppRoutes.dispatcherTrips);
    } else {
      final state = ref.read(tripManagementNotifierProvider);
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

  @override
  Widget build(BuildContext context) {
    if (_trip == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final trip = _trip!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تفاصيل الرحلة'),
        actions: [
          if (trip.state == TripState.planned)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _handleEdit,
              tooltip: 'تعديل',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trip.name,
                            style: AppTextStyles.heading3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: trip.state.color.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
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
                        Icon(
                          trip.tripType == TripType.pickup
                              ? Icons.arrow_circle_up
                              : Icons.arrow_circle_down,
                          size: 20,
                          color: trip.tripType == TripType.pickup
                              ? AppColors.primary
                              : AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          trip.tripType.arabicLabel,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Trip Info Card
            Card(
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
                    _buildInfoRow(
                      'التاريخ',
                      DateFormat('EEEE، d MMMM yyyy', 'ar').format(trip.date),
                      Icons.calendar_today,
                    ),
                    if (trip.plannedStartTime != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(
                        'وقت البدء المخطط',
                        DateFormat('HH:mm').format(trip.plannedStartTime!),
                        Icons.access_time,
                      ),
                    ],
                    if (trip.plannedArrivalTime != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(
                        'وقت الوصول المخطط',
                        DateFormat('HH:mm').format(trip.plannedArrivalTime!),
                        Icons.access_time,
                      ),
                    ],
                    if (trip.actualStartTime != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(
                        'وقت البدء الفعلي',
                        DateFormat('HH:mm').format(trip.actualStartTime!),
                        Icons.play_circle,
                        color: AppColors.success,
                      ),
                    ],
                    if (trip.actualArrivalTime != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(
                        'وقت الوصول الفعلي',
                        DateFormat('HH:mm').format(trip.actualArrivalTime!),
                        Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ],
                    if (trip.groupName != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(
                        'مجموعة الركاب',
                        trip.groupName!,
                        Icons.group,
                      ),
                    ],
                    if (trip.vehicleName != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(
                        'المركبة',
                        trip.vehicleName!,
                        Icons.directions_bus,
                      ),
                    ],
                    if (trip.driverName != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _buildInfoRow(
                        'السائق',
                        trip.driverName!,
                        Icons.person,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Passenger Statistics
            Card(
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
                            AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildStatItem(
                            'نزل',
                            '${trip.droppedCount}',
                            Icons.exit_to_app,
                            AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Action Buttons
            if (trip.state == TripState.planned) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('تعديل'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleCancel,
                      icon: const Icon(Icons.cancel),
                      label: const Text('إلغاء'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
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
          Icon(icon, size: 24, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

