import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/presentation/providers/active_trip_notifier.dart';

/// Trip Tracking Screen - شاشة تتبع الرحلة للراكب
class TripTrackingScreen extends ConsumerStatefulWidget {
  const TripTrackingScreen({
    required this.tripId,
    super.key,
  });

  final int tripId;

  @override
  ConsumerState<TripTrackingScreen> createState() =>
      _TripTrackingScreenState();
}

class _TripTrackingScreenState extends ConsumerState<TripTrackingScreen> {
  final MapController _mapController = MapController();
  Timer? _refreshTimer;
  bool _autoRefreshEnabled = true;
  static const _refreshInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _loadTrip();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    if (_autoRefreshEnabled) {
      _refreshTimer = Timer.periodic(_refreshInterval, (_) {
        if (mounted) {
          _loadTrip();
        }
      });
    }
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefreshEnabled = !_autoRefreshEnabled;
    });
    if (_autoRefreshEnabled) {
      _startAutoRefresh();
    } else {
      _refreshTimer?.cancel();
    }
  }

  Future<void> _loadTrip() async {
    await ref.read(activeTripNotifierProvider.notifier).loadTrip(widget.tripId);
  }

  /// حساب المسافة بين نقطتين (بالكيلومترات)
  double _calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }

  /// حساب الوقت المتوقع للوصول (ETA)
  String _calculateETA(double distanceKm) {
    // متوسط سرعة 40 كم/ساعة في المدينة
    const averageSpeedKmh = 40.0;
    final hours = distanceKm / averageSpeedKmh;
    final minutes = (hours * 60).round();
    
    if (minutes < 1) {
      return 'أقل من دقيقة';
    } else if (minutes == 1) {
      return 'دقيقة واحدة';
    } else if (minutes < 60) {
      return '$minutes دقيقة';
    } else {
      final hrs = (minutes / 60).floor();
      final mins = minutes % 60;
      return '$hrs ساعة و $mins دقيقة';
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
        appBar: AppBar(title: const Text('تتبع الرحلة')),
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
                  // Driver Position Marker
                  if (currentPosition != null)
                    Marker(
                      point: LatLng(
                        currentPosition.latitude,
                        currentPosition.longitude,
                      ),
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
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

          // Bottom Info Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(trip, state),
          ),
        ],
      ),
    );
  }

  Widget _buildTopInfoCard(trip, state) {
    final currentPosition = state.currentPosition;
    // حساب المسافة والـ ETA (مثال: إلى أول نقطة توقف)
    double? distanceKm;
    String? eta;
    
    if (currentPosition != null && trip.tripLines.isNotEmpty) {
      final firstStop = trip.tripLines.first;
      if (firstStop.latitude != null && firstStop.longitude != null) {
        final stopLocation = LatLng(firstStop.latitude!, firstStop.longitude!);
        final driverLocation = LatLng(currentPosition.latitude, currentPosition.longitude);
        distanceKm = _calculateDistance(driverLocation, stopLocation);
        eta = _calculateETA(distanceKm);
      }
    }

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                onPressed: () => Navigator.pop(context),
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
                            'نشط',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Auto-refresh toggle
              IconButton(
                icon: Icon(
                  _autoRefreshEnabled ? Icons.sync : Icons.sync_disabled,
                  color: _autoRefreshEnabled ? AppColors.primary : AppColors.textSecondary,
                ),
                onPressed: _toggleAutoRefresh,
                tooltip: _autoRefreshEnabled ? 'إيقاف التحديث التلقائي' : 'تفعيل التحديث التلقائي',
              ),
            ],
          ),
          
          // ETA و المسافة
          if (distanceKm != null && eta != null) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.access_time,
                    label: 'الوقت المتوقع',
                    value: eta,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.social_distance,
                    label: 'المسافة',
                    value: '${distanceKm.toStringAsFixed(1)} كم',
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripProgress(trip) {
    final totalStops = trip.tripLines.length;
    final completedStops = trip.tripLines.where((line) => line.isCompleted).length;
    final progress = totalStops > 0 ? completedStops / totalStops : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تقدم الرحلة',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$completedStops / $totalStops نقاط',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% مكتمل',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: trip.isOngoing
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  trip.isOngoing ? Icons.navigation : Icons.schedule,
                  color: trip.isOngoing ? AppColors.success : AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  trip.isOngoing ? 'الرحلة جارية' : 'الرحلة مجدولة',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: trip.isOngoing ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Trip Progress (if ongoing)
          if (trip.isOngoing && trip.tripLines.isNotEmpty) ...[
            _buildTripProgress(trip),
            const SizedBox(height: AppSpacing.md),
          ],

          // Vehicle and Driver Info
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.directions_bus,
                  'المركبة',
                  trip.vehicleName ?? 'غير محدد',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildInfoItem(
                  Icons.person,
                  'السائق',
                  trip.driverName ?? 'غير محدد',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Time Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'الوقت المخطط',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.plannedStartTime != null
                        ? DateFormat('HH:mm').format(trip.plannedStartTime!)
                        : '--:--',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (trip.actualStartTime != null) ...[
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey[300],
                ),
                Column(
                  children: [
                    const Text(
                      'وقت البدء',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(trip.actualStartTime!),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Message
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, size: 20, color: Colors.blue[700]),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    trip.isOngoing
                        ? 'يمكنك تتبع موقع المركبة على الخريطة'
                        : 'ستتمكن من تتبع الرحلة عند بدئها',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

}
