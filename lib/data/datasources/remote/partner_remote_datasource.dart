import 'package:shuttlebee/core/constants/odoo_constants.dart';
import 'package:shuttlebee/core/errors/exceptions.dart';
import 'package:shuttlebee/core/services/bridgecore_service.dart';
import 'package:shuttlebee/data/models/partner_model.dart';

/// مصدر البيانات البعيد للشركاء
abstract class PartnerRemoteDataSource {
  Future<List<PartnerModel>> getPartners({
    bool? isShuttlePassenger,
    bool? isDriver,
    int? limit,
    int? offset,
  });

  Future<PartnerModel> getPartnerById(int id);

  Future<List<PartnerModel>> searchPartners(String query);

  Future<PartnerModel> createPartner(Map<String, dynamic> data);

  Future<PartnerModel> updatePartner(int id, Map<String, dynamic> data);

  Future<void> deletePartner(int id);
}

/// تنفيذ PartnerRemoteDataSource
class PartnerRemoteDataSourceImpl implements PartnerRemoteDataSource {
  PartnerRemoteDataSourceImpl(this._bridgeCoreService);

  final BridgeCoreService _bridgeCoreService;

  @override
  Future<List<PartnerModel>> getPartners({
    bool? isShuttlePassenger,
    bool? isDriver,
    int? limit,
    int? offset,
  }) async {
    try {
      final domain = <dynamic>[];

      if (isShuttlePassenger != null) {
        domain.add([
          OdooConstants.fieldIsShuttlePassenger,
          OdooConstants.operatorEqual,
          isShuttlePassenger,
        ]);
      }

      if (isDriver != null) {
        domain.add([
          OdooConstants.fieldIsDriver,
          OdooConstants.operatorEqual,
          isDriver,
        ]);
      }

      final results = await _bridgeCoreService.search(
        model: OdooConstants.modelPartner,
        domain: domain.isEmpty ? null : domain,
        limit: limit,
        offset: offset,
      );

      return results
          .map((json) => PartnerModel.fromBridgeCoreResponse(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PartnerModel> getPartnerById(int id) async {
    try {
      final result = await _bridgeCoreService.readOne(
        model: OdooConstants.modelPartner,
        id: id,
      );

      return PartnerModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PartnerModel>> searchPartners(String query) async {
    try {
      final domain = [
        [
          OdooConstants.fieldName,
          OdooConstants.operatorILike,
          '%$query%',
        ],
      ];

      final results = await _bridgeCoreService.search(
        model: OdooConstants.modelPartner,
        domain: domain,
      );

      return results
          .map((json) => PartnerModel.fromBridgeCoreResponse(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PartnerModel> createPartner(Map<String, dynamic> data) async {
    try {
      final result = await _bridgeCoreService.create(
        model: OdooConstants.modelPartner,
        data: data,
      );

      return PartnerModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PartnerModel> updatePartner(int id, Map<String, dynamic> data) async {
    try {
      final result = await _bridgeCoreService.update(
        model: OdooConstants.modelPartner,
        id: id,
        data: data,
      );

      return PartnerModel.fromBridgeCoreResponse(result);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deletePartner(int id) async {
    try {
      await _bridgeCoreService.delete(
        model: OdooConstants.modelPartner,
        id: id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

