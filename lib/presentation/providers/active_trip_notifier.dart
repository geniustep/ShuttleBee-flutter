import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/core/services/location_service.dart';
import 'package:shuttlebee/core/utils/logger.dart';
import 'package:shuttlebee/domain/entities/trip_line_entity.dart';
import 'package:shuttlebee/domain/repositories/trip_line_repository.dart';
import 'package:shuttlebee/domain/repositories/trip_repository.dart';
import 'package:shuttlebee/presentation/providers/active_trip_state.dart';

/// Active Trip Notifier
class ActiveTripNotifier extends StateNotifier<ActiveTripState> {
  ActiveTripNotifier(
    this._tripRepository,
    this._tripLineRepository,
  ) : super(ActiveTripState.initial());

  final TripRepository _tripRepository;
  final TripLineRepository _tripLineRepository;
  final LocationService _locationService = LocationService.instance;

  Timer? _gpsUpdateTimer;

  /// جلب تفاصيل الرحلة والركاب
  Future<void> loadTrip(int tripId) async {
    state = ActiveTripState.loading();

    try {
      // جلب الرحلة
      final tripResult = await _tripRepository.getTripById(tripId);

      await tripResult.fold(
        (failure) async {
          state = ActiveTripState.error(failure.message);
        },
        (trip) async {
          // جلب الركاب
          final passengersResult = await _tripRepository.getTripLines(tripId);

          passengersResult.fold(
            (failure) {
              state = ActiveTripState.error(failure.message);
            },
            (passengers) {
              state = ActiveTripState.loaded(
                trip: trip,
                passengers: passengers,
              );
            },
          );
        },
      );
    } catch (e) {
      AppLogger.error('Failed to load trip', e);
      state = ActiveTripState.error('حدث خطأ في تحميل الرحلة');
    }
  }

  /// بدء الرحلة
  Future<bool> startTrip() async {
    if (state.trip == null) return false;

    final result = await _tripRepository.startTrip(state.trip!.id);

    return result.fold(
      (failure) {
        AppLogger.error('Failed to start trip', failure.message);
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedTrip) {
        AppLogger.info('Trip started successfully');
        state = state.copyWith(trip: updatedTrip, error: null);
        // بدء تتبع GPS
        startGPSTracking();
        return true;
      },
    );
  }

  /// إنهاء الرحلة
  Future<bool> completeTrip() async {
    if (state.trip == null) return false;

    final result = await _tripRepository.completeTrip(state.trip!.id);

    return result.fold(
      (failure) {
        AppLogger.error('Failed to complete trip', failure.message);
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedTrip) {
        AppLogger.info('Trip completed successfully');
        state = state.copyWith(trip: updatedTrip, error: null);
        // إيقاف تتبع GPS
        stopGPSTracking();
        return true;
      },
    );
  }

  /// إلغاء الرحلة
  Future<bool> cancelTrip() async {
    if (state.trip == null) return false;

    final result = await _tripRepository.cancelTrip(state.trip!.id);

    return result.fold(
      (failure) {
        AppLogger.error('Failed to cancel trip', failure.message);
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedTrip) {
        AppLogger.info('Trip cancelled successfully');
        state = state.copyWith(trip: updatedTrip, error: null);
        // إيقاف تتبع GPS
        stopGPSTracking();
        return true;
      },
    );
  }

  /// وضع علامة "صعد" للراكب
  Future<bool> markPassengerBoarded(int tripLineId) async {
    final result = await _tripLineRepository.markAsBoarded(tripLineId);

    return result.fold(
      (failure) {
        AppLogger.error('Failed to mark passenger boarded', failure.message);
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedTripLine) {
        AppLogger.info('Passenger marked as boarded');
        _updatePassengerInList(updatedTripLine);
        return true;
      },
    );
  }

  /// وضع علامة "غائب" للراكب
  Future<bool> markPassengerAbsent(
    int tripLineId, {
    String? reason,
  }) async {
    final result = await _tripLineRepository.markAsAbsent(
      tripLineId,
      absenceReason: reason,
    );

    return result.fold(
      (failure) {
        AppLogger.error('Failed to mark passenger absent', failure.message);
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedTripLine) {
        AppLogger.info('Passenger marked as absent');
        _updatePassengerInList(updatedTripLine);
        return true;
      },
    );
  }

  /// وضع علامة "نزل" للراكب
  Future<bool> markPassengerDropped(int tripLineId) async {
    final result = await _tripLineRepository.markAsDropped(tripLineId);

    return result.fold(
      (failure) {
        AppLogger.error('Failed to mark passenger dropped', failure.message);
        state = state.copyWith(error: failure.message);
        return false;
      },
      (updatedTripLine) {
        AppLogger.info('Passenger marked as dropped');
        _updatePassengerInList(updatedTripLine);
        return true;
      },
    );
  }

  /// تحديث راكب في القائمة
  void _updatePassengerInList(TripLineEntity updatedTripLine) {
    final updatedPassengers = state.passengers.map((passenger) {
      if (passenger.id == updatedTripLine.id) {
        return updatedTripLine;
      }
      return passenger;
    }).toList();

    state = state.copyWith(passengers: updatedPassengers);

    // إعادة تحميل الرحلة لتحديث العدادات
    if (state.trip != null) {
      loadTrip(state.trip!.id);
    }
  }

  /// بدء تتبع GPS
  void startGPSTracking() {
    if (state.isTracking) return;

    state = state.copyWith(isTracking: true);

    // تحديث الموقع كل 5 ثواني
    _gpsUpdateTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        await _updateGPSPosition();
      },
    );

    AppLogger.info('GPS tracking started');
  }

  /// إيقاف تتبع GPS
  void stopGPSTracking() {
    _gpsUpdateTimer?.cancel();
    _gpsUpdateTimer = null;
    _locationService.stopTracking();
    state = state.copyWith(isTracking: false);
    AppLogger.info('GPS tracking stopped');
  }

  /// تحديث موقع GPS
  Future<void> _updateGPSPosition() async {
    if (state.trip == null || !state.isTracking) return;

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) return;

      state = state.copyWith(currentPosition: position);

      // إرسال الموقع للسيرفر
      await _tripRepository.registerGpsPosition(
        tripId: state.trip!.id,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: _locationService.getSpeedInKmh(position),
        heading: position.heading,
        timestamp: DateTime.now(),
      );

      AppLogger.debug(
        'GPS position updated: ${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      AppLogger.error('Failed to update GPS position', e);
    }
  }

  /// تنظيف الموارد
  @override
  void dispose() {
    stopGPSTracking();
    super.dispose();
  }
}

/// Active Trip Provider
final activeTripNotifierProvider =
    StateNotifierProvider<ActiveTripNotifier, ActiveTripState>((ref) {
  return ActiveTripNotifier(
    ref.watch(tripRepositoryProvider),
    ref.watch(tripLineRepositoryProvider),
  );
});
