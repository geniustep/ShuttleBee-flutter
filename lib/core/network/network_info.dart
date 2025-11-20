import 'package:connectivity_plus/connectivity_plus.dart';

/// معلومات الشبكة - فحص الاتصال بالإنترنت
abstract class NetworkInfo {
  /// هل يوجد اتصال بالإنترنت
  Future<bool> get isConnected;

  /// Stream لمراقبة تغييرات الاتصال
  Stream<bool> get onConnectivityChanged;
}

/// تنفيذ NetworkInfo
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isConnected);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }
}
