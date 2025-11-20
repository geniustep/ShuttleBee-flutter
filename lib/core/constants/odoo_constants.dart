/// ثوابت نماذج Odoo
class OdooConstants {
  OdooConstants._();

  // Odoo Models
  static const String modelTrip = 'shuttle.trip';
  static const String modelTripLine = 'shuttle.trip.line';
  static const String modelPassengerGroup = 'shuttle.passenger.group';
  static const String modelStop = 'shuttle.stop';
  static const String modelVehicle = 'shuttle.vehicle';
  static const String modelPartner = 'res.partner';
  static const String modelUser = 'res.users';

  // Trip Methods
  static const String methodStartTrip = 'action_start_trip';
  static const String methodCompleteTrip = 'action_complete_trip';
  static const String methodCancelTrip = 'action_cancel_trip';
  static const String methodSendApproachingNotifications =
      'action_send_approaching_notifications';
  static const String methodSendArrivedNotifications =
      'action_send_arrived_notifications';
  static const String methodRegisterGpsPosition = 'register_gps_position';
  static const String methodGetDashboardStats = 'get_dashboard_stats';

  // Trip Line Methods
  static const String methodMarkBoarded = 'action_mark_boarded';
  static const String methodMarkAbsent = 'action_mark_absent';
  static const String methodMarkDropped = 'action_mark_dropped';

  // Stop Methods
  static const String methodSuggestNearest = 'suggest_nearest';

  // Common Fields
  static const String fieldId = 'id';
  static const String fieldName = 'name';
  static const String fieldCreateDate = 'create_date';
  static const String fieldWriteDate = 'write_date';

  // Trip Fields
  static const String fieldDate = 'date';
  static const String fieldTripType = 'trip_type';
  static const String fieldState = 'state';
  static const String fieldDriverId = 'driver_id';
  static const String fieldVehicleId = 'vehicle_id';
  static const String fieldGroupId = 'group_id';
  static const String fieldPlannedStartTime = 'planned_start_time';
  static const String fieldPlannedArrivalTime = 'planned_arrival_time';
  static const String fieldActualStartTime = 'actual_start_time';
  static const String fieldActualArrivalTime = 'actual_arrival_time';
  static const String fieldTotalPassengers = 'total_passengers';
  static const String fieldPresentCount = 'present_count';
  static const String fieldAbsentCount = 'absent_count';
  static const String fieldBoardedCount = 'boarded_count';
  static const String fieldDroppedCount = 'dropped_count';
  static const String fieldOccupancyRate = 'occupancy_rate';
  static const String fieldCurrentLatitude = 'current_latitude';
  static const String fieldCurrentLongitude = 'current_longitude';
  static const String fieldLastGpsUpdate = 'last_gps_update';

  // Trip Line Fields
  static const String fieldTripId = 'trip_id';
  static const String fieldPassengerId = 'passenger_id';
  static const String fieldPassengerPhone = 'passenger_phone';
  static const String fieldPickupStopId = 'pickup_stop_id';
  static const String fieldDropoffStopId = 'dropoff_stop_id';
  static const String fieldPickupLatitude = 'pickup_latitude';
  static const String fieldPickupLongitude = 'pickup_longitude';
  static const String fieldDropoffLatitude = 'dropoff_latitude';
  static const String fieldDropoffLongitude = 'dropoff_longitude';
  static const String fieldStatus = 'status';
  static const String fieldBoardingTime = 'boarding_time';
  static const String fieldDropoffTime = 'dropoff_time';
  static const String fieldAbsenceReason = 'absence_reason';
  static const String fieldSequence = 'sequence';

  // Passenger Group Fields
  static const String fieldDestinationStopId = 'destination_stop_id';
  static const String fieldUseCompanyDestination = 'use_company_destination';
  static const String fieldAutoScheduleEnabled = 'auto_schedule_enabled';
  static const String fieldAutoScheduleWeeks = 'auto_schedule_weeks';
  static const String fieldTotalSeats = 'total_seats';
  static const String fieldPassengerCount = 'passenger_count';

  // Stop Fields
  static const String fieldStopType = 'stop_type';
  static const String fieldLatitude = 'latitude';
  static const String fieldLongitude = 'longitude';
  static const String fieldAddress = 'address';
  static const String fieldCity = 'city';
  static const String fieldUsageCount = 'usage_count';

  // Vehicle Fields
  static const String fieldSeatCapacity = 'seat_capacity';
  static const String fieldLicensePlate = 'license_plate';

  // Partner Fields
  static const String fieldEmail = 'email';
  static const String fieldPhone = 'phone';
  static const String fieldMobile = 'mobile';
  static const String fieldIsShuttlePassenger = 'is_shuttle_passenger';
  static const String fieldIsDriver = 'is_driver';
  static const String fieldDefaultPickupStopId = 'default_pickup_stop_id';
  static const String fieldDefaultDropoffStopId = 'default_dropoff_stop_id';
  static const String fieldShuttleLatitude = 'shuttle_latitude';
  static const String fieldShuttleLongitude = 'shuttle_longitude';

  // Operators for search
  static const String operatorEqual = '=';
  static const String operatorNotEqual = '!=';
  static const String operatorGreaterThan = '>';
  static const String operatorGreaterThanOrEqual = '>=';
  static const String operatorLessThan = '<';
  static const String operatorLessThanOrEqual = '<=';
  static const String operatorLike = 'like';
  static const String operatorILike = 'ilike';
  static const String operatorIn = 'in';
  static const String operatorNotIn = 'not in';
}
