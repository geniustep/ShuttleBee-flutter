import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuttlebee/core/di/injection.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/utils/logger.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';
import 'package:shuttlebee/domain/repositories/trip_repository.dart';
import 'package:shuttlebee/presentation/providers/trip_list_state.dart';

/// Trip List Notifier
class TripListNotifier extends StateNotifier<TripListState> {
  TripListNotifier(this._tripRepository) : super(TripListState.initial());

  final TripRepository _tripRepository;

  /// جلب الرحلات
  Future<void> loadTrips({
    DateTime? dateFrom,
    DateTime? dateTo,
    TripState? tripState,
    int? driverId,
    int? groupId,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      state = TripListState.refreshing(state.trips);
    } else {
      state = TripListState.loading();
    }

    final result = await _tripRepository.getTrips(
      dateFrom: dateFrom,
      dateTo: dateTo,
      state: tripState,
      driverId: driverId,
      groupId: groupId,
    );

    result.fold(
      (failure) {
        AppLogger.error('Failed to load trips', failure.message);
        state = TripListState.error(failure.message, state.trips);
      },
      (trips) {
        AppLogger.info('Loaded ${trips.length} trips');
        state = TripListState.loaded(trips);
      },
    );
  }

  /// جلب رحلات السائق اليوم
  Future<void> loadDriverDailyTrips(int driverId, DateTime date) async {
    state = TripListState.loading();

    final result = await _tripRepository.getDriverDailyTrips(driverId, date);

    result.fold(
      (failure) {
        AppLogger.error('Failed to load driver trips', failure.message);
        state = TripListState.error(failure.message, state.trips);
      },
      (trips) {
        AppLogger.info('Loaded ${trips.length} trips for driver $driverId');
        state = TripListState.loaded(trips);
      },
    );
  }

  /// تحديث رحلة في القائمة
  void updateTrip(int tripId, Function(TripEntity) updater) {
    final updatedTrips = state.trips.map((trip) {
      if (trip.id == tripId) {
        return updater(trip);
      }
      return trip;
    }).toList();

    state = state.copyWith(trips: updatedTrips as List<TripEntity>);
  }

  /// إزالة رحلة من القائمة
  void removeTrip(int tripId) {
    final updatedTrips =
        state.trips.where((trip) => trip.id != tripId).toList();
    state = state.copyWith(trips: updatedTrips);
  }

  /// مسح الأخطاء
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Trip List Provider
final tripListNotifierProvider =
    StateNotifierProvider<TripListNotifier, TripListState>((ref) {
  return TripListNotifier(ref.watch(tripRepositoryProvider));
});

/// Provider لرحلات السائق اليومية
final driverDailyTripsProvider = FutureProvider.family<List<dynamic>, int>(
  (ref, driverId) async {
    final tripRepository = ref.watch(tripRepositoryProvider);
    final today = DateTime.now();

    final result = await tripRepository.getDriverDailyTrips(driverId, today);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (trips) => trips,
    );
  },
);
