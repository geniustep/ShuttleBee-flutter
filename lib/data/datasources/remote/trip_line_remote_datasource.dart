import 'package:shuttlebee/core/constants/odoo_constants.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/services/bridgecore_service.dart';
import 'package:shuttlebee/data/models/trip_line_model.dart';

/// مصدر البيانات البعيد لخطوط الرحلة
abstract class TripLineRemoteDataSource {
  Future<List<TripLineModel>> getTripLines({int? tripId, int? passengerId});
  Future<TripLineModel> getTripLineById(int id);
  Future<TripLineModel> createTripLine(Map<String, dynamic> data);
  Future<TripLineModel> updateTripLine(int id, Map<String, dynamic> data);
  Future<void> deleteTripLine(int id);
  Future<TripLineModel> markAsBoarded(int tripLineId);
  Future<TripLineModel> markAsAbsent(int tripLineId, {String? absenceReason});
  Future<TripLineModel> markAsDropped(int tripLineId);
}

/// تنفيذ TripLineRemoteDataSource
class TripLineRemoteDataSourceImpl implements TripLineRemoteDataSource {
  TripLineRemoteDataSourceImpl(this._bridgeCoreService);

  final BridgeCoreService _bridgeCoreService;

  @override
  Future<List<TripLineModel>> getTripLines({
    int? tripId,
    int? passengerId,
  }) async {
    try {
      final domain = <dynamic>[];

      if (tripId != null) {
        domain.add([
          OdooConstants.fieldTripId,
          OdooConstants.operatorEqual,
          tripId,
        ]);
      }

      if (passengerId != null) {
        domain.add([
          OdooConstants.fieldPassengerId,
          OdooConstants.operatorEqual,
          passengerId,
        ]);
      }

      final results = await _bridgeCoreService.search(
        model: OdooConstants.modelTripLine,
        domain: domain.isEmpty ? null : domain,
      );

      return results
          .map((json) => TripLineModel.fromBridgeCoreResponse(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripLineModel> getTripLineById(int id) async {
    try {
      final result = await _bridgeCoreService.readOne(
        model: OdooConstants.modelTripLine,
        id: id,
      );

      return TripLineModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripLineModel> createTripLine(Map<String, dynamic> data) async {
    try {
      final result = await _bridgeCoreService.create(
        model: OdooConstants.modelTripLine,
        data: data,
      );

      return TripLineModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripLineModel> updateTripLine(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final result = await _bridgeCoreService.update(
        model: OdooConstants.modelTripLine,
        id: id,
        data: data,
      );

      return TripLineModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTripLine(int id) async {
    try {
      await _bridgeCoreService.delete(
        model: OdooConstants.modelTripLine,
        id: id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripLineModel> markAsBoarded(int tripLineId) async {
    try {
      final result = await _bridgeCoreService.executeMethod(
        model: OdooConstants.modelTripLine,
        method: OdooConstants.methodMarkBoarded,
        recordIds: [tripLineId],
        context: {'service_response': true},
      );

      return TripLineModel.fromBridgeCoreResponse(result['data']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripLineModel> markAsAbsent(
    int tripLineId, {
    String? absenceReason,
  }) async {
    try {
      final result = await _bridgeCoreService.executeMethod(
        model: OdooConstants.modelTripLine,
        method: OdooConstants.methodMarkAbsent,
        recordIds: [tripLineId],
        kwargs: {
          if (absenceReason != null) 'absence_reason': absenceReason,
        },
        context: {'service_response': true},
      );

      return TripLineModel.fromBridgeCoreResponse(result['data']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TripLineModel> markAsDropped(int tripLineId) async {
    try {
      final result = await _bridgeCoreService.executeMethod(
        model: OdooConstants.modelTripLine,
        method: OdooConstants.methodMarkDropped,
        recordIds: [tripLineId],
        context: {'service_response': true},
      );

      return TripLineModel.fromBridgeCoreResponse(result['data']);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
