import 'package:shuttlebee/core/constants/odoo_constants.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/services/bridgecore_service.dart';
import 'package:shuttlebee/data/models/vehicle_model.dart';

/// مصدر البيانات البعيد للمركبات
abstract class VehicleRemoteDataSource {
  Future<List<VehicleModel>> getVehicles({
    int? driverId,
    int? limit,
    int? offset,
  });

  Future<VehicleModel> getVehicleById(int id);

  Future<List<VehicleModel>> searchVehicles(String query);

  Future<VehicleModel> createVehicle(Map<String, dynamic> data);

  Future<VehicleModel> updateVehicle(int id, Map<String, dynamic> data);

  Future<void> deleteVehicle(int id);
}

/// تنفيذ VehicleRemoteDataSource
class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  VehicleRemoteDataSourceImpl(this._bridgeCoreService);

  final BridgeCoreService _bridgeCoreService;

  @override
  Future<List<VehicleModel>> getVehicles({
    int? driverId,
    int? limit,
    int? offset,
  }) async {
    try {
      final domain = <dynamic>[];

      if (driverId != null) {
        domain.add([
          OdooConstants.fieldDriverId,
          OdooConstants.operatorEqual,
          driverId,
        ]);
      }

      final results = await _bridgeCoreService.search(
        model: OdooConstants.modelVehicle,
        domain: domain.isEmpty ? null : domain,
        limit: limit,
        offset: offset,
      );

      return results
          .map((json) => VehicleModel.fromBridgeCoreResponse(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> getVehicleById(int id) async {
    try {
      final result = await _bridgeCoreService.readOne(
        model: OdooConstants.modelVehicle,
        id: id,
      );

      return VehicleModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<VehicleModel>> searchVehicles(String query) async {
    try {
      final domain = [
        [
          OdooConstants.fieldName,
          OdooConstants.operatorILike,
          '%$query%',
        ],
      ];

      final results = await _bridgeCoreService.search(
        model: OdooConstants.modelVehicle,
        domain: domain,
      );

      return results
          .map((json) => VehicleModel.fromBridgeCoreResponse(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> createVehicle(Map<String, dynamic> data) async {
    try {
      final result = await _bridgeCoreService.create(
        model: OdooConstants.modelVehicle,
        data: data,
      );

      return VehicleModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> updateVehicle(int id, Map<String, dynamic> data) async {
    try {
      final result = await _bridgeCoreService.update(
        model: OdooConstants.modelVehicle,
        id: id,
        data: data,
      );

      return VehicleModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteVehicle(int id) async {
    try {
      await _bridgeCoreService.delete(
        model: OdooConstants.modelVehicle,
        id: id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

