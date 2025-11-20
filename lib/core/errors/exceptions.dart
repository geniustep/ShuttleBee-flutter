/// استثناءات التطبيق

/// استثناء عام في العمليات
class AppException implements Exception {
  const AppException([this.message = 'حدث خطأ']);

  final String message;

  @override
  String toString() => message;
}

/// استثناء في الخادم
class ServerException extends AppException {
  const ServerException([
    super.message = 'حدث خطأ في الخادم',
  ]);

  const ServerException.fromStatusCode(int statusCode, {String? message})
      : super(message ?? 'Server Error: $statusCode');
}

/// استثناء في الشبكة
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'لا يوجد اتصال بالإنترنت',
  ]);
}

/// استثناء في المصادقة
class AuthenticationException extends AppException {
  const AuthenticationException([
    super.message = 'فشلت المصادقة',
  ]);
}

/// استثناء انتهت صلاحية الرمز
class TokenExpiredException extends AppException {
  const TokenExpiredException([
    super.message = 'انتهت صلاحية رمز الوصول',
  ]);
}

/// استثناء في التخزين المحلي
class CacheException extends AppException {
  const CacheException([
    super.message = 'حدث خطأ في التخزين المحلي',
  ]);
}

/// استثناء في التحقق من الصحة
class ValidationException extends AppException {
  const ValidationException([
    super.message = 'البيانات غير صحيحة',
  ]);

  ValidationException.fromErrors(Map<String, List<String>> errors)
      : super(_formatErrors(errors));

  static String _formatErrors(Map<String, List<String>> errors) {
    final buffer = StringBuffer();
    errors.forEach((key, value) {
      buffer.writeln('$key: ${value.join(", ")}');
    });
    return buffer.toString().trim();
  }
}

/// استثناء في الموقع/GPS
class LocationException extends AppException {
  const LocationException([
    super.message = 'حدث خطأ في الحصول على الموقع',
  ]);

  const LocationException.permissionDenied()
      : super('تم رفض إذن الوصول للموقع');

  const LocationException.serviceDisabled()
      : super('خدمة تحديد الموقع غير مفعلة');
}

/// استثناء في التحليل
class ParseException extends AppException {
  const ParseException([
    super.message = 'حدث خطأ في تحليل البيانات',
  ]);
}

/// استثناء timeout
class TimeoutException extends AppException {
  const TimeoutException([
    super.message = 'انتهت مهلة الطلب',
  ]);
}

/// استثناء في الصلاحيات
class PermissionException extends AppException {
  const PermissionException([
    super.message = 'ليس لديك صلاحية للقيام بهذا الإجراء',
  ]);
}

/// استثناء في الملفات
class FileException extends AppException {
  const FileException([
    super.message = 'حدث خطأ في العملية على الملف',
  ]);

  const FileException.notFound() : super('الملف غير موجود');

  const FileException.readError() : super('حدث خطأ في قراءة الملف');

  const FileException.writeError() : super('حدث خطأ في كتابة الملف');
}
