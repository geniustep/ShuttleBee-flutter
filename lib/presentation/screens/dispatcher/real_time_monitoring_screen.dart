import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shuttlebee/core/theme/app_colors.dart';
import 'package:shuttlebee/core/theme/app_spacing.dart';
import 'package:shuttlebee/core/theme/app_text_styles.dart';
import 'package:shuttlebee/presentation/providers/trip_list_notifier.dart';

/// Real-time Monitoring Screen - شاشة المراقبة الحية
class RealTimeMonitoringScreen extends ConsumerStatefulWidget {
  const RealTimeMonitoringScreen({super.key});

  @override
  ConsumerState<RealTimeMonitoringScreen> createState() =>
      _RealTimeMonitoringScreenState();
}

class _RealTimeMonitoringScreenState
    extends ConsumerState<RealTimeMonitoringScreen> {
  final MapController _mapController = MapController();
  Timer? _refreshTimer;
  bool _autoRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    // تأجيل تحميل الرحلات حتى ينتهي بناء الـ widget tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOngoingTrips();
      _startAutoRefresh();
    });
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    if (_autoRefreshEnabled) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _loadOngoingTrips();
      });
    }
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefreshEnabled = !_autoRefreshEnabled;
      if (_autoRefreshEnabled) {
        _startAutoRefresh();
      } else {
        _refreshTimer?.cancel();
      }
    });
  }

  Future<void> _loadOngoingTrips() async {
    // Load only ongoing trips
    await ref.read(tripListNotifierProvider.notifier).loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    final tripListState = ref.watch(tripListNotifierProvider);
    final ongoingTrips =
        tripListState.trips.where((trip) => trip.isOngoing).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('المراقبة الحية'),
        actions: [
          IconButton(
            icon: Icon(_autoRefreshEnabled ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAutoRefresh,
            tooltip: _autoRefreshEnabled ? 'إيقاف التحديث التلقائي' : 'تفعيل التحديث التلقائي',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOngoingTrips,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(24.7136, 46.6753), // Riyadh
              initialZoom: 12.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              // Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.shuttlebee',
              ),

              // Vehicle Markers (ongoing trips)
              MarkerLayer(
                markers: ongoingTrips.map((trip) {
                  // For demo purposes, generate random positions near Riyadh
                  // In production, use real GPS coordinates from trip
                  return Marker(
                    point: const LatLng(24.7136, 46.6753),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _showTripInfo(trip),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Top Info Panel
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoChip(
                      Icons.directions_bus,
                      'رحلات جارية',
                      '${ongoingTrips.length}',
                      AppColors.primary,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey[300],
                    ),
                    _buildInfoChip(
                      Icons.people,
                      'ركاب',
                      '${ongoingTrips.fold<int>(0, (sum, trip) => sum + trip.totalPassengers)}',
                      AppColors.success,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Trip List
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
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
              child: ongoingTrips.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'لا توجد رحلات جارية حالياً',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Handle bar
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الرحلات الجارية',
                                style: AppTextStyles.heading3,
                              ),
                              Text(
                                '${ongoingTrips.length}',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            itemCount: ongoingTrips.length,
                            itemBuilder: (context, index) {
                              final trip = ongoingTrips[index];
                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary,
                                    child: const Icon(
                                      Icons.directions_bus,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(trip.name),
                                  subtitle: Text(
                                    '${trip.driverName ?? "غير محدد"} • ${trip.boardedCount}/${trip.totalPassengers} راكب',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () => _showTripInfo(trip),
                                  ),
                                  onTap: () => _showTripInfo(trip),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(color: color),
        ),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  void _showTripInfo(trip) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trip.name, style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.directions_bus, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(trip.vehicleName ?? 'غير محدد'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(trip.driverName ?? 'غير محدد'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('الركاب: ${trip.boardedCount}/${trip.totalPassengers}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }
}
