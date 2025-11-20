import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shuttlebee/core/network/api_client.dart';
import 'package:shuttlebee/core/network/network_info.dart';
import 'package:shuttlebee/core/services/bridgecore_service.dart';
import 'package:shuttlebee/data/datasources/local/auth_local_datasource.dart';
import 'package:shuttlebee/data/datasources/remote/auth_remote_datasource.dart';
import 'package:shuttlebee/data/datasources/remote/trip_line_remote_datasource.dart';
import 'package:shuttlebee/data/datasources/remote/trip_remote_datasource.dart';
import 'package:shuttlebee/data/repositories/auth_repository_impl.dart';
import 'package:shuttlebee/data/repositories/trip_repository_impl.dart';
import 'package:shuttlebee/domain/repositories/auth_repository.dart';
import 'package:shuttlebee/domain/repositories/trip_repository.dart';

// ========== External Dependencies ==========

/// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

/// Flutter Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Connectivity Provider
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

// ========== Core ==========

/// Network Info Provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

/// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    storage: ref.watch(secureStorageProvider),
    dio: ref.watch(dioProvider),
  );
});

/// BridgeCore Service Provider
final bridgeCoreServiceProvider = Provider<BridgeCoreService>((ref) {
  return BridgeCoreService(
    apiClient: ref.watch(apiClientProvider),
  );
});

// ========== Data Sources ==========

// Local Data Sources
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(ref.watch(secureStorageProvider));
});

// Remote Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(bridgeCoreServiceProvider));
});

final tripRemoteDataSourceProvider = Provider<TripRemoteDataSource>((ref) {
  return TripRemoteDataSourceImpl(ref.watch(bridgeCoreServiceProvider));
});

final tripLineRemoteDataSourceProvider =
    Provider<TripLineRemoteDataSource>((ref) {
  return TripLineRemoteDataSourceImpl(ref.watch(bridgeCoreServiceProvider));
});

// ========== Repositories ==========

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

/// Trip Repository Provider
final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepositoryImpl(
    remoteDataSource: ref.watch(tripRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// TODO: Add more repository providers:
// - tripLineRepositoryProvider
// - stopRepositoryProvider
// - vehicleRepositoryProvider
// - partnerRepositoryProvider
// - passengerGroupRepositoryProvider

// ========== Use Cases ==========
// TODO: Create and add use case providers when needed
