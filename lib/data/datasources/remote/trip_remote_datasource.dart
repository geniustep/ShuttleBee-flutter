import 'package:bridgecore_flutter/bridgecore_flutter.dart' show BridgeCore;
import 'package:shuttlebee/core/constants/odoo_constants.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/services/bridgecore_service.dart';
import 'package:shuttlebee/data/models/trip_line_model.dart';
import 'package:shuttlebee/data/models/trip_model.dart';

/// مصدر البيانات البعيد للرحلات
abstract class TripRemoteDataSource {
  Future<List<TripModel>> getTrips({
    DateTime? dateFrom,
    DateTime? dateTo,
    TripState? state,
    int? driverId,
    int? groupId,
    int? limit,
    int? offset,
  });

  Future<TripModel> getTripById(int id);

  Future<TripModel> createTrip(Map<String, dynamic> data);

  Future<TripModel> updateTrip(int id, Map<String, dynamic> data);

  Future<void> deleteTrip(int id);

  Future<TripModel> startTrip(int tripId);

  Future<TripModel> completeTrip(int tripId);

  Future<TripModel> cancelTrip(int tripId);

  Future<void> registerGpsPosition({
    required int tripId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
  });

  Future<void> sendApproachingNotifications(int tripId);

  Future<void> sendArrivedNotifications(int tripId);

  Future<Map<String, dynamic>> getDashboardStats({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<List<TripLineModel>> getTripLines(int tripId);
}

/// تنفيذ TripRemoteDataSource
class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  TripRemoteDataSourceImpl(this._bridgeCoreService);

  final BridgeCoreService _bridgeCoreService;

  @override
  Future<List<TripModel>> getTrips({
    DateTime? dateFrom,
    DateTime? dateTo,
    TripState? state,
    int? driverId,
    int? groupId,
    int? limit,
    int? offset,
  }) async {
    try {
      final domain = <dynamic>[];

      if (dateFrom != null) {
        domain.add([
          OdooConstants.fieldDate,
          OdooConstants.operatorGreaterThanOrEqual,
          dateFrom.toIso8601String().split('T').first,
        ]);
      }

      if (dateTo != null) {
        domain.add([
          OdooConstants.fieldDate,
          OdooConstants.operatorLessThanOrEqual,
          dateTo.toIso8601String().split('T').first,
        ]);
      }

      if (state != null) {
        domain.add([
          OdooConstants.fieldState,
          OdooConstants.operatorEqual,
          state.value,
        ]);
      }

      if (driverId != null) {
        domain.add([
          OdooConstants.fieldDriverId,
          OdooConstants.operatorEqual,
          driverId,
        ]);
      }

      if (groupId != null) {
        domain.add([
          OdooConstants.fieldGroupId,
          OdooConstants.operatorEqual,
          groupId,
        ]);
      }

      // استخدام BridgeCore SDK مباشرة
      // limit يجب أن يكون >= 1 للـ SDK
      final effectiveLimit = (limit == null || limit <= 0) ? 100 : limit;

      print('🔍 [getTrips] Domain: $domain');
      print('🔍 [getTrips] Limit: $effectiveLimit, Offset: ${offset ?? 0}');

      final results = await BridgeCore.instance.odoo.searchRead(
        model: OdooConstants.modelTrip,
        domain: domain,
        limit: effectiveLimit,
        offset: offset ?? 0,
      );

      print('✅ [getTrips] Got ${results.length} results');
      if (results.isNotEmpty) {
        print('📋 [getTrips] First result keys: ${results.first.keys.toList()}');
      }

      return results
          .map((json) => TripModel.fromBridgeCoreResponse(json))
          .toList();
    } catch (e, stackTrace) {
      print('❌ [getTrips] Error: $e');
      print('❌ [getTrips] Stack trace: $stackTrace');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> getTripById(int id) async {
    try {
      final result = await _bridgeCoreService.readOne(
        model: OdooConstants.modelTrip,
        id: id,
      );

      return TripModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> createTrip(Map<String, dynamic> data) async {
    try {
      final result = await _bridgeCoreService.create(
        model: OdooConstants.modelTrip,
        data: data,
      );

      return TripModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> updateTrip(int id, Map<String, dynamic> data) async {
    try {
      final result = await _bridgeCoreService.update(
        model: OdooConstants.modelTrip,
        id: id,
        data: data,
      );

      return TripModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTrip(int id) async {
    try {
      await _bridgeCoreService.delete(
        model: OdooConstants.modelTrip,
        id: id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> startTrip(int tripId) async {
    try {
      final result = await _bridgeCoreService.executeMethod(
        model: OdooConstants.modelTrip,
        method: OdooConstants.methodStartTrip,
        recordIds: [tripId],
        context: {'service_response': true},
      );

      return TripModel.fromBridgeCoreResponse(result['data']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> completeTrip(int tripId) async {
    try {
      final result = await _bridgeCoreService.executeMethod(
        model: OdooConstants.modelTrip,
        method: OdooConstants.methodCompleteTrip,
        recordIds: [tripId],
        context: {'service_response': true},
      );

      return TripModel.fromBridgeCoreResponse(result['data']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripModel> cancelTrip(int tripId) async {
    try {
      final result = await _bridgeCoreService.executeMethod(
        model: OdooConstants.modelTrip,
        method: OdooConstants.methodCancelTrip,
        recordIds: [tripId],
        context: {'service_response': true},
      );

      return TripModel.fromBridgeCoreResponse(result['data']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> registerGpsPosition({
    required int tripId,
    required double latitude,
    required double longitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
  }) async {
    try {
      await _bridgeCoreService.executeMethod(
        model: OdooConstants.modelTrip,
        method: OdooConstants.methodRegisterGpsPosition,
        recordIds: [tripId],
        args: [latitude, longitude],
        kwargs: {
          if (speed != null) 'speed': speed,
          if (heading != null) 'heading': heading,
          if (timestamp != null) 'timestamp': timestamp.toIso8601String(),
        },
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendApproachingNotifications(int tripId) async {
    try {
      await _bridgeCoreService.executeMethod(
        model: OdooConstants.modelTrip,
        method: OdooConstants.methodSendApproachingNotifications,
        recordIds: [tripId],
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendArrivedNotifications(int tripId) async {
    try {
      await _bridgeCoreService.executeMethod(
        model: OdooConstants.modelTrip,
        method: OdooConstants.methodSendArrivedNotifications,
        recordIds: [tripId],
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final result = await _bridgeCoreService.executeMethod(
        model: OdooConstants.modelTrip,
        method: OdooConstants.methodGetDashboardStats,
        kwargs: {
          if (dateFrom != null)
            'date_from': dateFrom.toIso8601String().split('T').first,
          if (dateTo != null)
            'date_to': dateTo.toIso8601String().split('T').first,
        },
      );

      return result;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TripLineModel>> getTripLines(int tripId) async {
    try {
      final results = await _bridgeCoreService.search(
        model: OdooConstants.modelTripLine,
        domain: [
          [
            OdooConstants.fieldTripId,
            OdooConstants.operatorEqual,
            tripId,
          ],
        ],
      );

      return results
          .map((json) => TripLineModel.fromBridgeCoreResponse(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
