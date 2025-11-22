# إعداد ملف .env للتطوير

## خطوات الإعداد

1. أنشئ ملف `.env` في المجلد الرئيسي للمشروع (نفس مستوى `pubspec.yaml`)

2. انسخ المحتوى التالي إلى الملف:

```env
# ShuttleBee Environment Configuration

# Debug Mode - Enable for development
DEBUG_MODE=true

# Debug Role Override - Force a specific role in debug mode
# Options: 'dispatcher', 'driver', 'passenger', 'manager'
DEBUG_ROLE_OVERRIDE=dispatcher

# API Configuration
API_BASE_URL=http://localhost:8000
SYSTEM_ID=odoo-prod

# Odoo Configuration
ODOO_URL=https://demo.odoo.com
ODOO_DATABASE=demo
ODOO_USERNAME=admin
ODOO_PASSWORD=admin

# Token Configuration
ACCESS_TOKEN_EXPIRY=1800
REFRESH_TOKEN_EXPIRY=604800

# App Configuration
APP_NAME=ShuttleBee
APP_VERSION=1.0.0

# GPS Configuration
GPS_UPDATE_INTERVAL_SECONDS=5
GPS_DISTANCE_FILTER_METERS=10.0

# Map Configuration
MAP_DEFAULT_ZOOM=15.0
MAP_DEFAULT_LAT=33.5731
MAP_DEFAULT_LNG=-7.5898

# Notification Configuration
FCM_SERVER_KEY=your_fcm_server_key

# Logging
ENABLE_LOGGING=true
```

## المتغيرات المهمة للتطوير

### `DEBUG_MODE=true`
- يجب تفعيله لتشغيل وضع التطوير
- عند تفعيله، سيتم استخدام دور `dispatcher` تلقائياً إذا لم يكن هناك دور محدد من API

### `DEBUG_ROLE_OVERRIDE=dispatcher`
- يفرض دور معين في وضع التطوير
- القيم المتاحة:
  - `dispatcher` - مرسل
  - `driver` - سائق
  - `passenger` - راكب
  - `manager` - مدير

## ملاحظات

- ملف `.env` موجود في `.gitignore` ولن يتم رفعه للمستودع
- تأكد من تحديث القيم حسب بيئتك
- بعد إنشاء الملف، أعد تشغيل التطبيق

