import 'package:shuttlebee/core/constants/odoo_constants.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/services/bridgecore_service.dart';
import 'package:shuttlebee/data/models/passenger_group_model.dart';

/// مصدر البيانات البعيد لمجموعات الركاب
abstract class PassengerGroupRemoteDataSource {
  Future<List<PassengerGroupModel>> getPassengerGroups({
    TripType? tripType,
    int? driverId,
    int? vehicleId,
    int? limit,
    int? offset,
  });

  Future<PassengerGroupModel> getPassengerGroupById(int id);

  Future<List<PassengerGroupModel>> searchPassengerGroups(String query);

  Future<PassengerGroupModel> createPassengerGroup(Map<String, dynamic> data);

  Future<PassengerGroupModel> updatePassengerGroup(
      int id, Map<String, dynamic> data);

  Future<void> deletePassengerGroup(int id);
}

/// تنفيذ PassengerGroupRemoteDataSource
class PassengerGroupRemoteDataSourceImpl
    implements PassengerGroupRemoteDataSource {
  PassengerGroupRemoteDataSourceImpl(this._bridgeCoreService);

  final BridgeCoreService _bridgeCoreService;

  @override
  Future<List<PassengerGroupModel>> getPassengerGroups({
    TripType? tripType,
    int? driverId,
    int? vehicleId,
    int? limit,
    int? offset,
  }) async {
    try {
      final domain = <dynamic>[];

      if (tripType != null) {
        domain.add([
          OdooConstants.fieldTripType,
          OdooConstants.operatorEqual,
          tripType.value,
        ]);
      }

      if (driverId != null) {
        domain.add([
          OdooConstants.fieldDriverId,
          OdooConstants.operatorEqual,
          driverId,
        ]);
      }

      if (vehicleId != null) {
        domain.add([
          OdooConstants.fieldVehicleId,
          OdooConstants.operatorEqual,
          vehicleId,
        ]);
      }

      final results = await _bridgeCoreService.search(
        model: OdooConstants.modelPassengerGroup,
        domain: domain.isEmpty ? null : domain,
        limit: limit,
        offset: offset,
      );

      return results
          .map((json) => PassengerGroupModel.fromBridgeCoreResponse(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PassengerGroupModel> getPassengerGroupById(int id) async {
    try {
      final result = await _bridgeCoreService.readOne(
        model: OdooConstants.modelPassengerGroup,
        id: id,
      );

      return PassengerGroupModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PassengerGroupModel>> searchPassengerGroups(String query) async {
    try {
      final domain = [
        [
          OdooConstants.fieldName,
          OdooConstants.operatorILike,
          '%$query%',
        ],
      ];

      final results = await _bridgeCoreService.search(
        model: OdooConstants.modelPassengerGroup,
        domain: domain,
      );

      return results
          .map((json) => PassengerGroupModel.fromBridgeCoreResponse(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PassengerGroupModel> createPassengerGroup(
      Map<String, dynamic> data) async {
    try {
      final result = await _bridgeCoreService.create(
        model: OdooConstants.modelPassengerGroup,
        data: data,
      );

      return PassengerGroupModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PassengerGroupModel> updatePassengerGroup(
      int id, Map<String, dynamic> data) async {
    try {
      final result = await _bridgeCoreService.update(
        model: OdooConstants.modelPassengerGroup,
        id: id,
        data: data,
      );

      return PassengerGroupModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deletePassengerGroup(int id) async {
    try {
      await _bridgeCoreService.delete(
        model: OdooConstants.modelPassengerGroup,
        id: id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

