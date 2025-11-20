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

/// Trip List Screen - شاشة قائمة الرحلات
class TripListScreen extends ConsumerStatefulWidget {
  const TripListScreen({super.key});

  @override
  ConsumerState<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends ConsumerState<TripListScreen> {
  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    await ref.read(tripManagementNotifierProvider.notifier).loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tripManagementNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة الرحلات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'تصفية',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('${AppRoutes.dispatcherHome}/trips/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('رحلة جديدة'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildErrorState(state.error!)
              : RefreshIndicator(
                  onRefresh: _loadTrips,
                  child: Column(
                    children: [
                      // Filter Chips
                      _buildFilterChips(state),

                      // Trip List
                      Expanded(
                        child: state.filteredTrips.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: state.filteredTrips.length,
                                itemBuilder: (context, index) {
                                  final trip = state.filteredTrips[index];
                                  return _buildTripCard(trip);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFilterChips(state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('الكل', 'all', state.filterStatus),
            _buildFilterChip('مخطط', 'planned', state.filterStatus),
            _buildFilterChip('جارية', 'ongoing', state.filterStatus),
            _buildFilterChip('منتهية', 'done', state.filterStatus),
            _buildFilterChip('ملغاة', 'cancelled', state.filterStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String currentFilter) {
    final isSelected = currentFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          ref
              .read(tripManagementNotifierProvider.notifier)
              .setFilterStatus(value);
        },
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
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

  Widget _buildEmptyState() {
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
            'لا توجد رحلات',
            style: AppTextStyles.heading3.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'اضغط على زر "رحلة جديدة" لإضافة رحلة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripEntity trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          ref.read(tripManagementNotifierProvider.notifier).selectTrip(trip);
          context.go('${AppRoutes.dispatcherHome}/trips/${trip.id}');
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

              // Trip Type
              Row(
                children: [
                  Icon(
                    trip.tripType == TripType.pickup
                        ? Icons.arrow_circle_up
                        : Icons.arrow_circle_down,
                    size: 16,
                    color: trip.tripType == TripType.pickup
                        ? AppColors.primary
                        : AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trip.tripType.arabicLabel,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('yyyy-MM-dd').format(trip.date),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Info
              Row(
                children: [
                  if (trip.vehicleName != null) ...[
                    const Icon(Icons.directions_bus, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      trip.vehicleName!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  if (trip.driverName != null) ...[
                    const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      trip.driverName!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Passengers
              Row(
                children: [
                  const Icon(Icons.people, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'الركاب: ${trip.totalPassengers}',
                    style: AppTextStyles.bodySmall,
                  ),
                  if (trip.boardedCount > 0) ...[
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'صعد: ${trip.boardedCount}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ],
              ),

              // Action Buttons
              if (trip.canStart || trip.isOngoing) ...[
                const SizedBox(height: AppSpacing.sm),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (trip.state == TripState.planned)
                      TextButton.icon(
                        onPressed: () => _handleCancelTrip(trip),
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('إلغاء'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: () {
                        context.go('${AppRoutes.dispatcherHome}/trips/${trip.id}/edit');
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('تعديل'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCancelTrip(TripEntity trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الرحلة'),
        content: Text('هل أنت متأكد من إلغاء رحلة "${trip.name}"؟'),
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
        .cancelTrip(trip.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إلغاء الرحلة بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية الرحلات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ستتوفر خيارات تصفية متقدمة قريباً'),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      ),
    );
  }
}
