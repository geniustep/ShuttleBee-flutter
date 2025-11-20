import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shuttlebee/domain/entities/trip_entity.dart';

part 'trip_management_state.freezed.dart';

/// Trip Management State - حالة إدارة الرحلات
@freezed
class TripManagementState with _$TripManagementState {
  const factory TripManagementState({
    @Default([]) List<TripEntity> trips,
    @Default([]) List<TripEntity> filteredTrips,
    TripEntity? selectedTrip,
    @Default('all') String filterStatus, // all, planned, ongoing, done, cancelled
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    @Default(false) bool isLoading,
    @Default(false) bool isCreating,
    @Default(false) bool isUpdating,
    @Default(false) bool isDeleting,
    String? error,
  }) = _TripManagementState;

  const TripManagementState._();

  /// Create loading state
  factory TripManagementState.loading() {
    return const TripManagementState(isLoading: true);
  }

  /// Create error state
  factory TripManagementState.error(String message) {
    return TripManagementState(error: message, isLoading: false);
  }

  /// Check if any operation is in progress
  bool get isOperating => isCreating || isUpdating || isDeleting;
}
