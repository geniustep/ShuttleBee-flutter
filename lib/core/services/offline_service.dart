import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shuttlebee/core/utils/logger.dart';

/// Offline Service - خدمة الدعم بدون اتصال
class OfflineService {
  OfflineService._();
  
  static final OfflineService instance = OfflineService._();
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _cachePrefix = 'cache_';
  static const String _queuePrefix = 'queue_';
  static const String _syncStatusKey = 'sync_status';

  /// حفظ بيانات في الـ cache
  Future<void> cacheData({
    required String key,
    required Map<String, dynamic> data,
    Duration? ttl,
  }) async {
    try {
      final cacheEntry = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        if (ttl != null) 'ttl': ttl.inSeconds,
      };

      await _storage.write(
        key: '$_cachePrefix$key',
        value: jsonEncode(cacheEntry),
      );

      AppLogger.info('Data cached: $key');
    } catch (e) {
      AppLogger.error('Failed to cache data', e.toString());
    }
  }

  /// استرجاع بيانات من الـ cache
  Future<Map<String, dynamic>?> getCachedData(String key) async {
    try {
      final cached = await _storage.read(key: '$_cachePrefix$key');
      if (cached == null) return null;

      final cacheEntry = jsonDecode(cached) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cacheEntry['timestamp'] as String);
      final ttl = cacheEntry['ttl'] as int?;

      // Check if expired
      if (ttl != null) {
        final expiryDate = timestamp.add(Duration(seconds: ttl));
        if (DateTime.now().isAfter(expiryDate)) {
          await _storage.delete(key: '$_cachePrefix$key');
          AppLogger.info('Cache expired: $key');
          return null;
        }
      }

      return cacheEntry['data'] as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to get cached data', e.toString());
      return null;
    }
  }

  /// حذف بيانات من الـ cache
  Future<void> clearCache(String key) async {
    try {
      await _storage.delete(key: '$_cachePrefix$key');
      AppLogger.info('Cache cleared: $key');
    } catch (e) {
      AppLogger.error('Failed to clear cache', e.toString());
    }
  }

  /// حذف جميع الـ cache
  Future<void> clearAllCache() async {
    try {
      final all = await _storage.readAll();
      for (final key in all.keys) {
        if (key.startsWith(_cachePrefix)) {
          await _storage.delete(key: key);
        }
      }
      AppLogger.info('All cache cleared');
    } catch (e) {
      AppLogger.error('Failed to clear all cache', e.toString());
    }
  }

  /// إضافة عملية إلى قائمة الانتظار للمزامنة
  Future<void> queueOperation({
    required String type,
    required String endpoint,
    required Map<String, dynamic> data,
  }) async {
    try {
      final operation = {
        'type': type, // 'create', 'update', 'delete'
        'endpoint': endpoint,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final queueKey = '$_queuePrefix${DateTime.now().millisecondsSinceEpoch}';
      await _storage.write(
        key: queueKey,
        value: jsonEncode(operation),
      );

      AppLogger.info('Operation queued: $type - $endpoint');
    } catch (e) {
      AppLogger.error('Failed to queue operation', e.toString());
    }
  }

  /// الحصول على جميع العمليات في قائمة الانتظار
  Future<List<Map<String, dynamic>>> getQueuedOperations() async {
    try {
      final all = await _storage.readAll();
      final operations = <Map<String, dynamic>>[];

      for (final entry in all.entries) {
        if (entry.key.startsWith(_queuePrefix)) {
          final operation = jsonDecode(entry.value) as Map<String, dynamic>;
          operations.add({
            ...operation,
            'queueKey': entry.key,
          });
        }
      }

      // Sort by timestamp
      operations.sort((a, b) {
        final aTime = DateTime.parse(a['timestamp'] as String);
        final bTime = DateTime.parse(b['timestamp'] as String);
        return aTime.compareTo(bTime);
      });

      return operations;
    } catch (e) {
      AppLogger.error('Failed to get queued operations', e.toString());
      return [];
    }
  }

  /// حذف عملية من قائمة الانتظار
  Future<void> removeQueuedOperation(String queueKey) async {
    try {
      await _storage.delete(key: queueKey);
      AppLogger.info('Queued operation removed: $queueKey');
    } catch (e) {
      AppLogger.error('Failed to remove queued operation', e.toString());
    }
  }

  /// مزامنة جميع العمليات المعلقة
  Future<int> syncQueuedOperations({
    required Future<bool> Function(Map<String, dynamic>) onSync,
  }) async {
    try {
      final operations = await getQueuedOperations();
      int successCount = 0;

      for (final operation in operations) {
        try {
          final success = await onSync(operation);
          if (success) {
            await removeQueuedOperation(operation['queueKey'] as String);
            successCount++;
          }
        } catch (e) {
          AppLogger.error('Failed to sync operation', e.toString());
        }
      }

      await _updateSyncStatus(DateTime.now());
      AppLogger.info('Synced $successCount operations');
      return successCount;
    } catch (e) {
      AppLogger.error('Failed to sync queued operations', e.toString());
      return 0;
    }
  }

  /// تحديث حالة المزامنة
  Future<void> _updateSyncStatus(DateTime lastSync) async {
    try {
      await _storage.write(
        key: _syncStatusKey,
        value: lastSync.toIso8601String(),
      );
    } catch (e) {
      AppLogger.error('Failed to update sync status', e.toString());
    }
  }

  /// الحصول على آخر وقت مزامنة
  Future<DateTime?> getLastSyncTime() async {
    try {
      final lastSync = await _storage.read(key: _syncStatusKey);
      if (lastSync == null) return null;
      return DateTime.parse(lastSync);
    } catch (e) {
      AppLogger.error('Failed to get last sync time', e.toString());
      return null;
    }
  }

  /// التحقق من وجود عمليات معلقة
  Future<bool> hasPendingOperations() async {
    final operations = await getQueuedOperations();
    return operations.isNotEmpty;
  }

  /// الحصول على عدد العمليات المعلقة
  Future<int> getPendingOperationsCount() async {
    final operations = await getQueuedOperations();
    return operations.length;
  }
}

