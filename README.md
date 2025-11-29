# ShuttleBee - نظام إدارة النقل المدرسي والشركات

<div dir="rtl">

## 📋 نظرة عامة

**ShuttleBee** هو نظام متكامل لإدارة النقل المدرسي والشركات، مبني باستخدام Flutter ويتكامل مع BridgeCore API Middleware و Odoo Backend.

## 🏗️ المعمارية

المشروع يتبع **Clean Architecture** مع **MVVM Pattern**

## 🎯 الميزات الرئيسية

### 1. واجهة السائق - Driver Interface
### 2. واجهة المشغل - Dispatcher Interface
### 3. واجهة الراكب - Passenger Interface
### 4. واجهة المدير - Manager Interface

## ✅ ما تم إنجازه

### Phase 1: Project Foundation & Core Infrastructure
**Project Setup & Architecture:**
- ✅ بنية المشروع الكاملة مع Clean Architecture
- ✅ 45+ dependencies (Riverpod, Dio, Freezed, GoRouter, FlutterMap, etc.)
- ✅ Environment configuration مع `.env` support
- ✅ `.gitignore` و `analysis_options.yaml` شامل

**Theme System:**
- ✅ Material Design 3
- ✅ Light & Dark mode support
- ✅ RTL support للغة العربية
- ✅ نظام ألوان شامل (AppColors)
- ✅ نظام نصوص هرمي (AppTextStyles)
- ✅ نظام مسافات (AppSpacing)

**Core Services:**
- ✅ API Client مع Dio (AuthInterceptor, LoggingInterceptor, RetryInterceptor)
- ✅ BridgeCore Service للتكامل مع Odoo (CRUD, search, execute, file operations)
- ✅ Network Info للتحقق من الاتصال
- ✅ Logger utility للتطوير

**Data Models (8 models مع Freezed):**
- ✅ TripModel, TripLineModel, StopModel
- ✅ VehicleModel, PartnerModel, PassengerGroupModel
- ✅ AuthModel, UserModel

**Enums:**
- ✅ TripType, TripState, TripLineStatus, StopType, UserRole

**Error Handling:**
- ✅ Custom Exceptions (ServerException, NetworkException, CacheException, etc.)
- ✅ Failure classes مع Either monad pattern

---

### Phase 2: Repository Pattern & Authentication Setup

**Domain Layer:**
- ✅ 6 Repository interfaces (Auth, Trip, TripLine, Vehicle, Partner, PassengerGroup)
- ✅ 8 Entity classes

**Data Layer:**
- ✅ Remote Data Sources (Auth, Trip, TripLine, Vehicle, Partner, PassengerGroup)
- ✅ Local Data Source (Auth مع FlutterSecureStorage)
- ✅ Repository Implementations (Auth, Trip, TripLine, Vehicle, Partner, PassengerGroup)

**Dependency Injection:**
- ✅ Riverpod provider setup شامل
- ✅ جميع Services, Repositories, و Data Sources مُكوّنة

**Authentication:**
- ✅ Login flow كامل مع JWT token management
- ✅ Secure token storage
- ✅ Auto token refresh على 401
- ✅ Splash screen مع auth check
- ✅ Login screen مع form validation

---

### Phase 3: State Management, Navigation & Driver Interface

**State Management:**
- ✅ AuthState & AuthNotifier مع Riverpod StateNotifier
- ✅ TripListState & TripListNotifier
- ✅ Reactive authentication flow

**Navigation:**
- ✅ GoRouter setup مع auth guards
- ✅ Role-based routing (Driver, Dispatcher, Passenger, Manager)
- ✅ Nested routes support
- ✅ Deep linking ready

**Driver Home Screen:**
- ✅ User info header مع logout
- ✅ Trip statistics cards (total, ongoing, completed)
- ✅ Trip list مع filters (today, upcoming, all)
- ✅ Pull-to-refresh
- ✅ Empty/Error/Loading states
- ✅ Trip cards مع معلومات كاملة
- ✅ Action buttons حسب trip state

---

### Phase 4: GPS Tracking & Active Trip Management

**Location Service:**
- ✅ GPS tracking كامل مع Geolocator
- ✅ Permission handling و service checks
- ✅ Real-time position streaming مع دقة قابلة للتكوين
- ✅ Distance calculation بين الإحداثيات
- ✅ Speed conversion (m/s to km/h)
- ✅ Background tracking support

**Active Trip State Management:**
- ✅ ActiveTripState مع Freezed
- ✅ ActiveTripNotifier مع إدارة دورة حياة كاملة:
  - تحميل تفاصيل الرحلة والركاب
  - عمليات Start/Complete/Cancel trip
  - تحديد حالة الركاب (boarded/absent/dropped)
  - تحديثات GPS تلقائية كل 5 ثواني
  - مزامنة الموقع في الوقت الفعلي للخادم

**Trip Detail Screen:**
- ✅ عرض معلومات الرحلة الشامل
- ✅ Trip header مع state/type badges
- ✅ بطاقة معلومات الرحلة الكاملة (group, vehicle, times, distance)
- ✅ إحصائيات الركاب (total, boarded, absent, dropped)
- ✅ معاينة قائمة الركاب
- ✅ Action buttons (Start Trip, Cancel Trip)

**Active Trip Screen:**
- ✅ Flutter Map integration مع OpenStreetMap tiles
- ✅ Current GPS position marker مع navigation icon
- ✅ Passenger markers ملونة حسب الحالة
- ✅ Top info card مع إحصائيات الرحلة و GPS indicator
- ✅ Bottom action panel مع معلومات الوقت
- ✅ Floating passenger list overlay
- ✅ وظائف الرحلة الكاملة
- ✅ Mark passenger actions (boarded/absent/dropped)
- ✅ Interactive passenger markers مع info modal

---

### Phase 5: Dispatcher Interface (مكتمل)

**Dispatcher Dashboard:**
- ✅ Dispatcher Home Screen مع إحصائيات
- ✅ Quick Actions (إنشاء رحلة، إدارة الرحلات، إدارة المركبات، المراقبة الحية)
- ✅ Trip statistics (total, ongoing, completed, cancelled)
- ✅ Resource statistics (vehicles, drivers)

**Trip Management:**
- ✅ Trip List Screen مع filters
- ✅ Trip cards مع معلومات كاملة
- ✅ Filter by status (all, planned, ongoing, done, cancelled)
- ✅ شاشة إنشاء رحلة جديدة مع form validation
- ✅ شاشة تعديل رحلة مع تحميل البيانات الحالية
- ✅ شاشة تفاصيل الرحلة للمرسل مع action buttons

**Real-time Monitoring:**
- ✅ Real-time Monitoring Screen مع auto-refresh
- ✅ Live trip tracking على الخريطة
- ✅ Auto-refresh كل 30 ثانية
- ✅ Toggle auto-refresh functionality
- ✅ Bottom sheet مع قائمة الرحلات الجارية

**Vehicle Management:**
- ✅ Vehicle Repository Implementation
- ✅ Vehicle Remote Data Source
- ✅ Vehicle Management Notifier & State
- ✅ شاشة إدارة المركبات مع CRUD operations
- ✅ شاشة إنشاء/تعديل مركبة
- ✅ شاشة اختيار المركبة
- ✅ Search و filter للمركبات
- ✅ عرض معلومات المركبة (name, license plate, seat capacity, driver)

**Trip Creation Enhancements:**
- ✅ شاشة اختيار المركبة من قائمة
- ✅ شاشة اختيار السائق من قائمة
- ✅ Integration مع شاشات إنشاء/تعديل الرحلة

**Repositories & Data Sources:**
- ✅ Vehicle Repository Implementation
- ✅ Partner Repository Implementation
- ✅ PassengerGroup Repository Implementation
- ✅ Vehicle Remote Data Source
- ✅ Partner Remote Data Source
- ✅ PassengerGroup Remote Data Source
- ✅ Providers setup في Dependency Injection

**Quality Improvements:**
- ✅ Error Boundary Widget للتعامل مع الأخطاء بشكل أنيق
- ✅ ErrorView Widget لعرض الأخطاء داخل الشاشات
- ✅ EmptyStateView Widget لعرض حالة فارغة
- ✅ Pull-to-refresh على جميع الشاشات الرئيسية
- ✅ Form validation شامل
- ✅ Loading و Error states لجميع العمليات

**Custom Fields System:**
- ✅ نظام مرن للتعامل مع Odoo Custom Fields
- ✅ OdooFieldParser للتعامل مع جميع أنواع الحقول
- ✅ Extension methods لسهولة الوصول
- ✅ دعم كامل لـ Many2one, Many2many, Boolean, Date, Lists, etc.
- ✅ لا حاجة لتعديل الكود عند إضافة custom fields جديدة
- ✅ **تكامل مع BridgeCore `odoo_fields_check`** - فحص custom fields عند Login
- ✅ **CustomFieldsConfig** - configuration مركزي للـ custom fields
- ✅ **OdooFieldsCheck Models** - Freezed models للـ API integration
- ✅ Documentation شامل في `lib/core/models/CUSTOM_FIELDS_GUIDE.md`

---

### Phase 6: Passenger Interface (مكتمل ✅)

**Passenger Home Screen:**
- ✅ Passenger Home Screen مع user info header
- ✅ عرض الرحلات المخصصة (Active, Upcoming, Past)
- ✅ Active trip tracking مع real-time updates
- ✅ Pull-to-refresh functionality
- ✅ Empty/Error/Loading states

**Trip Tracking Screen (Enhanced):**
- ✅ Trip Tracking Screen مع خريطة تفاعلية
- ✅ **Auto-refresh** كل 10 ثواني مع toggle
- ✅ **ETA (Estimated Time of Arrival)** calculation
- ✅ **Distance to destination** display
- ✅ **Trip progress indicator** مع نسبة الإنجاز
- ✅ Real-time driver location على الخريطة
- ✅ Vehicle و Driver information
- ✅ Trip status و timing information
- ✅ Beautiful UI مع Material Design 3

**Notification System:**
- ✅ **NotificationService** - خدمة إشعارات محلية
- ✅ **Trip Started** notification
- ✅ **Approaching Stop** notification (مع ETA)
- ✅ **Arrived at Stop** notification
- ✅ **Trip Delayed** notification
- ✅ **Trip Cancelled** notification
- ✅ **Trip Completed** notification
- ✅ Integration مع Flutter Local Notifications
- ✅ iOS و Android support

---

### Phase 7: Manager Interface (بدء التطوير)

- ✅ Manager Home Screen
- ✅ Analytics Screen
- ✅ Reports Screen
- ✅ Key metrics و performance metrics

---

## 🎉 المشروع مكتمل!

جميع المراحل الرئيسية تم إنجازها بنجاح:
- ✅ Phase 1-4: Core Infrastructure & Driver Interface
- ✅ Phase 5: Dispatcher Interface
- ✅ Phase 6: Passenger Interface
- ✅ Phase 7: Manager Interface
- ✅ Phase 8: Advanced Features

### 🆕 التحديثات الأخيرة

**BridgeCore Flutter v0.2.0 Integration (مكتمل 100% ✅):**

**الميزات المنفذة:**
- ✅ تم تحديث bridgecore_flutter إلى v0.2.0
- ✅ دعم /me endpoint المحسّن مع `odoo_fields_data`
- ✅ نظام صلاحيات شامل في UserEntity
- ✅ Multi-company support (companyId, allowedCompanyIds)
- ✅ Groups support (hasGroup, isFleetManager, etc.)
- ✅ Custom fields support محسّن (`shuttle_role` من `odoo_fields_data`)
- ✅ Permission methods (canCreate, canRead, canUpdate, canDelete)
- ✅ Profile Screen كامل مع عرض جميع المعلومات
- ✅ Settings Screen شامل مع 6 أقسام
- ✅ Caching ذكي

**بنية API Response الحقيقية:**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "User Name",
    "odoo_user_id": 6
  },
  "tenant": {...},
  "partner_id": 7,
  "groups": ["shuttlebee.group_shuttle_driver", ...],
  "company_ids": [1],
  "current_company_id": 1,
  "odoo_fields_data": {
    "shuttle_role": "driver"
  }
}
```

**الملفات المحدثة:**
- `lib/domain/entities/user_entity.dart` - إضافة permissions, groups, companies
- `lib/data/models/user_model.dart` - متوافق مع API الحقيقي + استخراج shuttle_role
- `lib/core/services/bridgecore_service.dart` - استخدام /me endpoint
- `lib/presentation/screens/common/profile_screen.dart` - شاشة Profile جديدة
- `lib/presentation/screens/common/settings_screen.dart` - شاشة Settings شاملة (جديد)

**Settings Screen يتضمن:**
1. 👤 User Profile Card (مع shuttle_role)
2. 🔐 Account Settings (email, phone, role)
3. 🏢 Company & Organization (companies, partner_id)
4. 🔒 Permissions & Groups (عرض تفصيلي)
5. ⚙️ App Settings (notifications, language, theme)
6. ℹ️ About & Support (help, privacy)
7. 🚪 Logout

📄 **للمزيد:** راجع [BRIDGECORE_V0.2.0_INTEGRATION.md](BRIDGECORE_V0.2.0_INTEGRATION.md)

### 🔍 **تشخيص مشاكل Role Detection**

**✅ تم إصلاح المشكلة الرئيسية:**
- كان الكود يمرر `user` object فقط بدلاً من الـ response الكامل
- الآن يتم تمرير الـ response الكامل الذي يحتوي على: `user`, `tenant`, `groups`, `odoo_fields_data`

**الأسباب المحتملة إذا استمرت المشكلة:**
1. `DEBUG_ROLE_OVERRIDE` مفعّل في `.env` → اتركه فارغاً
2. `odoo_fields_data` لا يأتي من API → أرسل `odoo_fields_check` في request
3. `shuttle_role` غير موجود في `odoo_fields_data` → تحقق من Odoo
4. قيمة `shuttle_role` غير صحيحة → يجب: driver, dispatcher, manager, passenger
5. Groups غير صحيحة → تحقق من `shuttlebee.group_shuttle_driver`

**✅ تم إضافة `odoo_fields_check` في `/me` request:**
- الآن يتم إرسال `odoo_fields_check` تلقائياً للحصول على `shuttle_role` و `groups`
- Response الكامل يحتوي على: `user`, `tenant`, `groups`, `odoo_fields_data`, `company_ids`

**أولوية تحديد الـ Role:**
1. `shuttle_role` من `odoo_fields_data` ⭐ (الآن يعمل!)
2. `groups` (مثل `shuttlebee.group_shuttle_driver`) (الآن يعمل!)
3. `user.role = "admin"` → `manager`
4. **اسم المستخدم** (مثل "chauffeur" → driver)
5. افتراضي: `passenger`

**Logs المتوقعة:**
```
🔍 [UserModel._parseRole] Checking username: chauffeur youssef
✅ [UserModel._parseRole] Using username pattern: driver
🎯 [AuthNotifier] User role: UserRole.driver
[GoRouter] Redirecting to: /driver
```

**للإنتاج:**
```env
DEBUG_MODE=false
DEBUG_ROLE_OVERRIDE=
```

### 🔧 **تحديثات تقنية**

**إزالة `connectSystem` (deprecated):**
- تم إزالة `connectSystem` من `AuthRemoteDataSource` و `AuthRepository`
- في Tenant-Based API، جميع العمليات تمر عبر `bridgecore.geniura.com`
- لا حاجة لـ connection منفصل لـ Odoo - يتم التعامل تلقائياً

**Dialog تأكيد تسجيل الخروج:**
- تم إضافة dialog تأكيد في جميع الشاشات (Driver, Dispatcher, Manager, Passenger, Settings)
- يمنع تسجيل الخروج العرضي
- يحتوي على زرين: "إلغاء" و "تسجيل الخروج" (باللون الأحمر)

---

## 🚀 الخطوات القادمة (اختيارية)

### Phase 5: Dispatcher Interface (مكتمل ✅)
- [x] إكمال Repositories المفقودة (Vehicle, Partner, PassengerGroup)
- [x] شاشة إنشاء رحلة جديدة مع CRUD كامل
- [x] شاشة تعديل رحلة
- [x] شاشة تفاصيل الرحلة للمرسل
- [x] شاشة إدارة المركبات
- [x] شاشة إنشاء/تعديل مركبة
- [x] شاشة اختيار المركبة
- [x] شاشة اختيار السائق
- [x] Real-time Monitoring مع auto-refresh
- [x] Error Boundaries و Quality Improvements

### Phase 6: Passenger Interface (إكمال)
- [ ] تحسينات على شاشة تتبع الرحلة
- [ ] إشعارات لتحديثات الرحلة

### Phase 7: Manager Interface (إكمال)
- [ ] تحسينات على Analytics
- [ ] Report generation
- [ ] Performance metrics متقدمة

### Phase 8: Advanced Features (مكتمل ✅)

**Manager Analytics Enhancement:**
- ✅ **Chart Widgets** - Line, Bar, Pie charts مع fl_chart
- ✅ **LineChartWidget** - رسم بياني خطي تفاعلي
- ✅ **BarChartWidget** - رسم بياني بالأعمدة
- ✅ **PieChartWidget** - رسم بياني دائري مع legend
- ✅ **Customizable** - colors, grid, tooltips

**Report Generation:**
- ✅ **ReportService** - خدمة توليد التقارير
- ✅ **PDF Reports** - تقارير PDF مع pdf package
- ✅ **Excel Reports** - تقارير Excel مع Syncfusion XLSIO
- ✅ **Trips Report** - تقرير شامل للرحلات
- ✅ **Custom Reports** - إمكانية إنشاء تقارير مخصصة
- ✅ **Auto-formatting** - تنسيق تلقائي للتقارير

**Offline Support:**
- ✅ **OfflineService** - خدمة الدعم بدون اتصال
- ✅ **Data Caching** - تخزين مؤقت مع TTL
- ✅ **Operation Queue** - قائمة انتظار للعمليات
- ✅ **Auto Sync** - مزامنة تلقائية عند الاتصال
- ✅ **Conflict Resolution** - حل التعارضات
- ✅ **Sync Status** - تتبع حالة المزامنة

**Firebase Push Notifications:**
- ✅ **FCMService** - خدمة Firebase Cloud Messaging
- ✅ **Foreground Handling** - معالجة الإشعارات في الـ foreground
- ✅ **Background Handling** - معالجة الإشعارات في الخلفية
- ✅ **Topic Subscriptions** - الاشتراك في topics
- ✅ **Token Management** - إدارة FCM tokens
- ✅ **Deep Linking** - التنقل عند النقر على الإشعار
- ✅ **iOS & Android Support** - دعم كامل للمنصتين

## 📞 التواصل

للدعم والاستفسارات: support@shuttlebee.com

---

**Built with ❤️ using Flutter**

</div>