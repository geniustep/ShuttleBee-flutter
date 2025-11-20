import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/domain/entities/trip_line_entity.dart';
import 'package:shuttlebee/presentation/providers/active_trip_notifier.dart';
import 'package:shuttlebee/routes/app_router.dart';

/// Active Trip Screen - شاشة الرحلة الجارية
class ActiveTripScreen extends ConsumerStatefulWidget {
  const ActiveTripScreen({
    required this.tripId,
    super.key,
  });

  final int tripId;

  @override
  ConsumerState<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends ConsumerState<ActiveTripScreen> {
  final MapController _mapController = MapController();
  bool _showPassengerList = false;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    final notifier = ref.read(activeTripNotifierProvider.notifier);
    await notifier.loadTrip(widget.tripId);

    // Start GPS tracking if not already tracking
    final state = ref.read(activeTripNotifierProvider);
    if (state.trip?.isOngoing == true && !state.isTracking) {
      notifier.startGPSTracking();
    }
  }

  Future<void> _handleCompleteTrip() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إنهاء الرحلة'),
        content: const Text('هل أنت متأكد من إنهاء هذه الرحلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('إنهاء الرحلة'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref.read(activeTripNotifierProvider.notifier).completeTrip();

    if (!mounted) return;

    if (success) {
      // Navigate back to home
      context.go(AppRoutes.driverHome);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنهاء الرحلة بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeTripNotifierProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الرحلة الجارية')),
        body: const Center(child: Text('لم يتم العثور على الرحلة')),
      );
    }

    final trip = state.trip!;
    final currentPosition = state.currentPosition;

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition != null
                  ? LatLng(currentPosition.latitude, currentPosition.longitude)
                  : const LatLng(24.7136, 46.6753), // Riyadh default
              initialZoom: 15.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              // Tile Layer (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.shuttlebee',
              ),

              // Markers Layer
              MarkerLayer(
                markers: [
                  // Current Position Marker
                  if (currentPosition != null)
                    Marker(
                      point: LatLng(
                        currentPosition.latitude,
                        currentPosition.longitude,
                      ),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                  // Passenger Markers
                  ...state.passengers.map((passenger) {
                    final lat = passenger.pickupLatitude;
                    final lng = passenger.pickupLongitude;

                    if (lat == null || lng == null) {
                      return null;
                    }

                    return Marker(
                      point: LatLng(lat, lng),
                      width: 30,
                      height: 30,
                      child: GestureDetector(
                        onTap: () => _showPassengerInfo(passenger),
                        child: Container(
                          decoration: BoxDecoration(
                            color: passenger.status.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            passenger.status == TripLineStatus.boarded
                                ? Icons.check
                                : passenger.status == TripLineStatus.absent
                                    ? Icons.close
                                    : passenger.status == TripLineStatus.dropped
                                        ? Icons.logout
                                        : Icons.person,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    );
                  }).whereType<Marker>(),
                ],
              ),
            ],
          ),

          // Top Info Card
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildTopInfoCard(trip, state),
            ),
          ),

          // Bottom Action Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(trip, state),
          ),

          // Floating Passenger List Button
          Positioned(
            right: AppSpacing.md,
            bottom: _showPassengerList ? null : AppSpacing.xxl + 80,
            top: _showPassengerList ? AppSpacing.xxl + 120 : null,
            child: FloatingActionButton(
              heroTag: 'passengers',
              onPressed: () {
                setState(() {
                  _showPassengerList = !_showPassengerList;
                });
              },
              backgroundColor: AppColors.primary,
              child: Icon(
                _showPassengerList ? Icons.map : Icons.people,
              ),
            ),
          ),

          // Passenger List Overlay
          if (_showPassengerList)
            Positioned(
              top: AppSpacing.xxl + 170,
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.xxl + 200,
              child: _buildPassengerList(state.passengers),
            ),
        ],
      ),
    );
  }

  Widget _buildTopInfoCard(trip, state) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.name,
                      style: AppTextStyles.heading4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          trip.tripType == TripType.pickup
                              ? Icons.arrow_circle_up
                              : Icons.arrow_circle_down,
                          size: 14,
                          color: trip.tripType == TripType.pickup
                              ? AppColors.primary
                              : AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip.tripType.arabicLabel,
                          style: AppTextStyles.caption,
                        ),
                        if (state.isTracking) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'GPS نشط',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  '${trip.boardedCount}/${trip.totalPassengers}',
                  'صعد',
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _buildStatChip(
                  '${trip.absentCount}',
                  'غائب',
                  AppColors.error,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _buildStatChip(
                  '${trip.droppedCount}',
                  'نزل',
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(trip, state) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'بدء الرحلة',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.actualStartTime != null
                        ? DateFormat('HH:mm').format(trip.actualStartTime!)
                        : '--:--',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey[300],
              ),
              Column(
                children: [
                  const Text(
                    'الوقت الحالي',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(DateTime.now()),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey[300],
              ),
              Column(
                children: [
                  const Text(
                    'الوصول المتوقع',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.plannedArrivalTime != null
                        ? DateFormat('HH:mm').format(trip.plannedArrivalTime!)
                        : '--:--',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Complete Trip Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleCompleteTrip,
              icon: const Icon(Icons.check_circle),
              label: const Text('إنهاء الرحلة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerList(List<TripLineEntity> passengers) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'الركاب (${passengers.length})',
                  style: AppTextStyles.heading4.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              itemCount: passengers.length,
              itemBuilder: (context, index) {
                final passenger = passengers[index];
                return _buildPassengerItem(passenger);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerItem(TripLineEntity passenger) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: passenger.status.color.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  color: passenger.status.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passenger.passengerName ?? 'راكب',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'التسلسل: ${passenger.sequence ?? "-"}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: passenger.status.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  passenger.status.arabicLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: passenger.status.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Action Buttons
          if (passenger.status == TripLineStatus.pending ||
              passenger.status == TripLineStatus.boarded) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (passenger.status == TripLineStatus.pending) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _markBoarded(passenger.id),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('صعد'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _markAbsent(passenger.id),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('غائب'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
                if (passenger.status == TripLineStatus.boarded)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _markDropped(passenger.id),
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('نزل'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: const BorderSide(color: AppColors.warning),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _markBoarded(int tripLineId) async {
    final success = await ref
        .read(activeTripNotifierProvider.notifier)
        .markPassengerBoarded(tripLineId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل صعود الراكب'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _markAbsent(int tripLineId) async {
    final success = await ref
        .read(activeTripNotifierProvider.notifier)
        .markPassengerAbsent(tripLineId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل غياب الراكب'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _markDropped(int tripLineId) async {
    final success = await ref
        .read(activeTripNotifierProvider.notifier)
        .markPassengerDropped(tripLineId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل نزول الراكب'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _showPassengerInfo(TripLineEntity passenger) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              passenger.passengerName ?? 'راكب',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(
              Icons.numbers,
              'التسلسل',
              '${passenger.sequence ?? "-"}',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(
              Icons.info,
              'الحالة',
              passenger.status.arabicLabel,
            ),
            if (passenger.pickupLatitude != null &&
                passenger.pickupLongitude != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(
                Icons.location_on,
                'الموقع',
                '${passenger.pickupLatitude!.toStringAsFixed(6)}, ${passenger.pickupLongitude!.toStringAsFixed(6)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
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
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
