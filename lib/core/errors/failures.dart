import 'package:equatable/equatable.dart';

/// فشل عام في العمليات
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

/// فشل في الشبكة
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال.',
  ]);
}

/// فشل في الخادم
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى.',
  ]);

  factory ServerFailure.fromStatusCode(int statusCode, {String? message}) {
    switch (statusCode) {
      case 400:
        return ServerFailure(message ?? 'طلب غير صحيح');
      case 401:
        return const ServerFailure('غير مصرح لك بالوصول');
      case 403:
        return const ServerFailure('الوصول مرفوض');
      case 404:
        return const ServerFailure('المورد المطلوب غير موجود');
      case 408:
        return const ServerFailure('انتهت مهلة الطلب');
      case 422:
        return ServerFailure(message ?? 'خطأ في التحقق من البيانات');
      case 429:
        return const ServerFailure('تم تجاوز عدد الطلبات المسموح بها');
      case 500:
        return const ServerFailure('خطأ داخلي في الخادم');
      case 502:
        return const ServerFailure('خطأ في البوابة');
      case 503:
        return const ServerFailure('الخدمة غير متوفرة مؤقتاً');
      default:
        return ServerFailure(message ?? 'حدث خطأ في الخادم ($statusCode)');
    }
  }
}

/// فشل في المصادقة
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([
    super.message = 'فشلت المصادقة. يرجى تسجيل الدخول مرة أخرى.',
  ]);
}

/// فشل في التخزين المحلي
class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'حدث خطأ في التخزين المحلي.',
  ]);
}

/// فشل في التحقق من الصحة
class ValidationFailure extends Failure {
  const ValidationFailure([
    super.message = 'البيانات المدخلة غير صحيحة. يرجى التحقق والمحاولة مرة أخرى.',
  ]);

  ValidationFailure.fromErrors(Map<String, List<String>> errors)
      : super(_formatErrors(errors));

  static String _formatErrors(Map<String, List<String>> errors) {
    final buffer = StringBuffer();
    errors.forEach((key, value) {
      buffer.writeln('$key: ${value.join(", ")}');
    });
    return buffer.toString().trim();
  }
}

/// فشل في الموقع/GPS
class LocationFailure extends Failure {
  const LocationFailure([
    super.message = 'حدث خطأ في الحصول على الموقع.',
  ]);

  const LocationFailure.permissionDenied()
      : super('تم رفض إذن الوصول للموقع.');

  const LocationFailure.serviceDisabled()
      : super('خدمة تحديد الموقع غير مفعلة.');
}

/// فشل في الإشعارات
class NotificationFailure extends Failure {
  const NotificationFailure([
    super.message = 'حدث خطأ في إرسال الإشعار.',
  ]);

  const NotificationFailure.permissionDenied()
      : super('تم رفض إذن الإشعارات.');
}

/// فشل في الملفات
class FileFailure extends Failure {
  const FileFailure([
    super.message = 'حدث خطأ في العملية على الملف.',
  ]);

  const FileFailure.notFound() : super('الملف غير موجود.');

  const FileFailure.readError() : super('حدث خطأ في قراءة الملف.');

  const FileFailure.writeError() : super('حدث خطأ في كتابة الملف.');
}

/// فشل غير متوقع
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
  ]);

  UnexpectedFailure.fromException(Object exception)
      : super('خطأ غير متوقع: ${exception.toString()}');
}
