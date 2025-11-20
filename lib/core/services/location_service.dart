import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:shuttlebee/core/config/app_config.dart';
import 'package:shuttlebee/core/errors/failures.dart';
import 'package:shuttlebee/core/utils/logger.dart';

/// خدمة تتبع الموقع GPS
class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;

  /// الموقع الحالي
  Position? get currentPosition => _currentPosition;

  /// التحقق من صلاحيات الموقع
  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق من تفعيل خدمة الموقع
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger.warning('Location services are disabled');
      return false;
    }

    // التحقق من الصلاحيات
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.warning('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppLogger.error('Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  /// الحصول على الموقع الحالي
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;
      AppLogger.info(
        'Current position: ${position.latitude}, ${position.longitude}',
      );

      return position;
    } catch (e) {
      AppLogger.error('Failed to get current position', e);
      return null;
    }
  }

  /// بدء تتبع الموقع
  Stream<Position> startTracking() {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: AppConfig.gpsDistanceFilterMeters.toInt(),
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  /// بدء تتبع الموقع مع callback
  void startTrackingWithCallback(
    Function(Position position) onPositionUpdate,
  ) {
    _positionSubscription?.cancel();

    _positionSubscription = startTracking().listen(
      (position) {
        _currentPosition = position;
        onPositionUpdate(position);
      },
      onError: (error) {
        AppLogger.error('Position stream error', error);
      },
    );
  }

  /// إيقاف تتبع الموقع
  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    AppLogger.info('GPS tracking stopped');
  }

  /// حساب المسافة بين نقطتين (بالأمتار)
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// حساب السرعة من Position (km/h)
  double getSpeedInKmh(Position position) {
    return position.speed * 3.6; // m/s to km/h
  }

  /// التحقق من إمكانية الوصول لخدمة الموقع
  Future<LocationFailure?> validateLocationService() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationFailure.serviceDisabled();
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const LocationFailure.permissionDenied();
    }

    return null;
  }

  /// تنظيف الموارد
  void dispose() {
    stopTracking();
  }
}
