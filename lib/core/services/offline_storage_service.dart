import 'package:hive_flutter/hive_flutter.dart';
import 'package:shuttlebee/core/utils/logger.dart';

/// Offline Storage Service using Hive
/// Provides offline caching for trips, passengers, and other data
class OfflineStorageService {
  static final OfflineStorageService instance = OfflineStorageService._();
  OfflineStorageService._();

  // Box names
  static const String _tripsBox = 'trips';
  static const String _passengersBox = 'passengers';
  static const String _syncQueueBox = 'sync_queue';
  static const String _settingsBox = 'settings';

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Open boxes
      await Hive.openBox(_tripsBox);
      await Hive.openBox(_passengersBox);
      await Hive.openBox(_syncQueueBox);
      await Hive.openBox(_settingsBox);

      AppLogger.info('Offline storage initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize offline storage: $e');
      rethrow;
    }
  }

  // ==================== Trips ====================

  /// Save trip to local storage
  Future<void> saveTrip(Map<String, dynamic> tripData) async {
    try {
      final box = Hive.box(_tripsBox);
      await box.put(tripData['id'], tripData);
      AppLogger.debug('Trip ${tripData['id']} saved offline');
    } catch (e) {
      AppLogger.error('Failed to save trip offline: $e');
    }
  }

  /// Save multiple trips
  Future<void> saveTrips(List<Map<String, dynamic>> trips) async {
    try {
      final box = Hive.box(_tripsBox);
      final tripMap = {for (var trip in trips) trip['id']: trip};
      await box.putAll(tripMap);
      AppLogger.debug('${trips.length} trips saved offline');
    } catch (e) {
      AppLogger.error('Failed to save trips offline: $e');
    }
  }

  /// Get trip from local storage
  Map<String, dynamic>? getTrip(int tripId) {
    try {
      final box = Hive.box(_tripsBox);
      return box.get(tripId);
    } catch (e) {
      AppLogger.error('Failed to get trip from offline storage: $e');
      return null;
    }
  }

  /// Get all trips from local storage
  List<Map<String, dynamic>> getAllTrips() {
    try {
      final box = Hive.box(_tripsBox);
      return box.values.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      AppLogger.error('Failed to get all trips from offline storage: $e');
      return [];
    }
  }

  /// Delete trip from local storage
  Future<void> deleteTrip(int tripId) async {
    try {
      final box = Hive.box(_tripsBox);
      await box.delete(tripId);
      AppLogger.debug('Trip $tripId deleted from offline storage');
    } catch (e) {
      AppLogger.error('Failed to delete trip from offline storage: $e');
    }
  }

  /// Clear all trips
  Future<void> clearTrips() async {
    try {
      final box = Hive.box(_tripsBox);
      await box.clear();
      AppLogger.debug('All trips cleared from offline storage');
    } catch (e) {
      AppLogger.error('Failed to clear trips: $e');
    }
  }

  // ==================== Sync Queue ====================

  /// Add operation to sync queue
  /// Used to queue operations when offline
  Future<void> addToSyncQueue(Map<String, dynamic> operation) async {
    try {
      final box = Hive.box(_syncQueueBox);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await box.put(timestamp, operation);
      AppLogger.debug('Operation added to sync queue');
    } catch (e) {
      AppLogger.error('Failed to add operation to sync queue: $e');
    }
  }

  /// Get all pending sync operations
  List<Map<String, dynamic>> getSyncQueue() {
    try {
      final box = Hive.box(_syncQueueBox);
      return box.values.cast<Map<String, dynamic>>().toList();
    } catch (e) {
      AppLogger.error('Failed to get sync queue: $e');
      return [];
    }
  }

  /// Remove operation from sync queue
  Future<void> removeFromSyncQueue(int timestamp) async {
    try {
      final box = Hive.box(_syncQueueBox);
      await box.delete(timestamp);
      AppLogger.debug('Operation removed from sync queue');
    } catch (e) {
      AppLogger.error('Failed to remove operation from sync queue: $e');
    }
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    try {
      final box = Hive.box(_syncQueueBox);
      await box.clear();
      AppLogger.debug('Sync queue cleared');
    } catch (e) {
      AppLogger.error('Failed to clear sync queue: $e');
    }
  }

  // ==================== Settings ====================

  /// Save setting
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      final box = Hive.box(_settingsBox);
      await box.put(key, value);
    } catch (e) {
      AppLogger.error('Failed to save setting: $e');
    }
  }

  /// Get setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      final box = Hive.box(_settingsBox);
      return box.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      AppLogger.error('Failed to get setting: $e');
      return defaultValue;
    }
  }

  // ==================== General ====================

  /// Check if data exists in cache
  bool hasTrip(int tripId) {
    try {
      final box = Hive.box(_tripsBox);
      return box.containsKey(tripId);
    } catch (e) {
      return false;
    }
  }

  /// Get cache size
  int getCacheSize() {
    try {
      final tripsBox = Hive.box(_tripsBox);
      final passengersBox = Hive.box(_passengersBox);
      final syncBox = Hive.box(_syncQueueBox);

      return tripsBox.length + passengersBox.length + syncBox.length;
    } catch (e) {
      AppLogger.error('Failed to get cache size: $e');
      return 0;
    }
  }

  /// Clear all offline data
  Future<void> clearAllData() async {
    try {
      await clearTrips();
      await clearSyncQueue();
      AppLogger.info('All offline data cleared');
    } catch (e) {
      AppLogger.error('Failed to clear all offline data: $e');
    }
  }

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
  }
}
