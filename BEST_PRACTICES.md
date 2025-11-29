# 📚 Best Practices & Code Quality Guidelines

## 🎯 نظرة عامة

هذا الملف يحتوي على أفضل الممارسات والإرشادات لضمان جودة الكود في مشروع ShuttleBee.

---

## 🏗️ Architecture Best Practices

### Clean Architecture
```
✅ DO: فصل الطبقات بوضوح
- Domain Layer: Business logic فقط
- Data Layer: Data sources و repositories
- Presentation Layer: UI و state management

❌ DON'T: خلط المسؤوليات بين الطبقات
```

### MVVM Pattern
```
✅ DO: استخدام StateNotifier للـ ViewModels
✅ DO: فصل UI logic عن business logic
❌ DON'T: وضع business logic في Widgets
```

---

## 📦 State Management (Riverpod)

### Providers
```dart
// ✅ GOOD: استخدام const constructors
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref.watch(authRepositoryProvider));
});

// ❌ BAD: إنشاء instances جديدة في كل مرة
final userProvider = Provider((ref) => UserNotifier());
```

### State Classes
```dart
// ✅ GOOD: استخدام Freezed للـ immutability
@freezed
class UserState with _$UserState {
  const factory UserState({
    required bool isLoading,
    User? user,
    String? error,
  }) = _UserState;
}

// ❌ BAD: mutable state
class UserState {
  bool isLoading = false;
  User? user;
}
```

---

## 🎨 UI Best Practices

### Widget Organization
```dart
// ✅ GOOD: تقسيم Widgets كبيرة إلى widgets صغيرة
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildContent(),
          _buildFooter(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() => ...;
  Widget _buildContent() => ...;
  Widget _buildFooter() => ...;
}

// ❌ BAD: widget واحد كبير جداً
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 500 lines of code...
        ],
      ),
    );
  }
}
```

### Theme Usage
```dart
// ✅ GOOD: استخدام Theme constants
Text('Hello', style: AppTextStyles.heading1);
Container(color: AppColors.primary);
SizedBox(height: AppSpacing.md);

// ❌ BAD: hard-coded values
Text('Hello', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
Container(color: Color(0xFF2196F3));
SizedBox(height: 16);
```

---

## 🔧 Error Handling

### Repository Pattern
```dart
// ✅ GOOD: استخدام Either monad
Future<Either<Failure, User>> getUser(int id) async {
  try {
    final user = await remoteDataSource.getUser(id);
    return Right(user);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}

// ❌ BAD: throwing exceptions
Future<User> getUser(int id) async {
  return await remoteDataSource.getUser(id); // throws exception
}
```

### UI Error Display
```dart
// ✅ GOOD: عرض أخطاء واضحة للمستخدم
if (state.error != null) {
  return ErrorView(
    message: state.error!,
    onRetry: () => ref.read(provider.notifier).retry(),
  );
}

// ❌ BAD: تجاهل الأخطاء
if (state.error != null) {
  return SizedBox.shrink();
}
```

---

## 🚀 Performance Optimization

### List Performance
```dart
// ✅ GOOD: استخدام ListView.builder للقوائم الطويلة
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);

// ❌ BAD: ListView مع children للقوائم الطويلة
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
);
```

### Image Optimization
```dart
// ✅ GOOD: استخدام cached_network_image
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
);

// ❌ BAD: Image.network بدون caching
Image.network(url);
```

### Const Constructors
```dart
// ✅ GOOD: استخدام const عندما ممكن
const Text('Hello');
const SizedBox(height: 16);
const Icon(Icons.home);

// ❌ BAD: عدم استخدام const
Text('Hello');
SizedBox(height: 16);
Icon(Icons.home);
```

---

## 📝 Code Documentation

### Class Documentation
```dart
/// User Repository - يدير عمليات المستخدمين
///
/// يوفر methods للحصول على بيانات المستخدمين، تحديثها، وحذفها.
/// يستخدم [UserRemoteDataSource] للتواصل مع API.
///
/// Example:
/// ```dart
/// final user = await userRepository.getUser(userId);
/// ```
class UserRepository {
  // ...
}
```

### Method Documentation
```dart
/// يحصل على بيانات المستخدم من الخادم
///
/// [userId] - معرف المستخدم
/// Returns [Either<Failure, User>] - إما خطأ أو بيانات المستخدم
///
/// Throws [ServerException] إذا فشل الاتصال بالخادم
Future<Either<Failure, User>> getUser(int userId) async {
  // ...
}
```

---

## 🧪 Testing Best Practices

### Unit Tests
```dart
// ✅ GOOD: اختبار كل method بشكل منفصل
test('getUser returns user when successful', () async {
  // Arrange
  when(mockDataSource.getUser(1)).thenAnswer((_) async => mockUser);
  
  // Act
  final result = await repository.getUser(1);
  
  // Assert
  expect(result, Right(mockUser));
});
```

### Widget Tests
```dart
// ✅ GOOD: اختبار UI interactions
testWidgets('Login button calls login method', (tester) async {
  await tester.pumpWidget(LoginScreen());
  await tester.enterText(find.byKey(Key('email')), 'test@test.com');
  await tester.tap(find.byKey(Key('loginButton')));
  
  verify(mockAuthNotifier.login(any, any)).called(1);
});
```

---

## 🔒 Security Best Practices

### Sensitive Data
```dart
// ✅ GOOD: استخدام FlutterSecureStorage للبيانات الحساسة
await secureStorage.write(key: 'token', value: token);

// ❌ BAD: استخدام SharedPreferences للبيانات الحساسة
await prefs.setString('token', token);
```

### API Keys
```dart
// ✅ GOOD: استخدام .env للـ API keys
final apiKey = dotenv.env['API_KEY'];

// ❌ BAD: hard-coded API keys
final apiKey = 'sk_live_1234567890';
```

---

## 📱 Platform-Specific Best Practices

### iOS
```dart
// ✅ GOOD: طلب permissions قبل الاستخدام
final status = await Permission.location.request();
if (status.isGranted) {
  // Use location
}
```

### Android
```dart
// ✅ GOOD: التحقق من Android version
if (Platform.isAndroid && Build.VERSION.SDK_INT >= 33) {
  // Use Android 13+ features
}
```

---

## 🎯 Naming Conventions

### Files
```
✅ GOOD:
- user_repository.dart
- login_screen.dart
- auth_notifier.dart

❌ BAD:
- UserRepository.dart
- LoginScreen.dart
- authNotifier.dart
```

### Classes
```dart
// ✅ GOOD: PascalCase
class UserRepository {}
class LoginScreen {}

// ❌ BAD:
class user_repository {}
class loginScreen {}
```

### Variables & Methods
```dart
// ✅ GOOD: camelCase
final userName = 'John';
void getUserData() {}

// ❌ BAD:
final UserName = 'John';
void GetUserData() {}
```

### Constants
```dart
// ✅ GOOD: lowerCamelCase
const maxRetries = 3;
const apiTimeout = Duration(seconds: 30);

// ❌ BAD:
const MAX_RETRIES = 3;
const API_TIMEOUT = Duration(seconds: 30);
```

---

## 🔄 Git Best Practices

### Commit Messages
```
✅ GOOD:
feat: Add user authentication
fix: Resolve login button not responding
refactor: Improve trip list performance

❌ BAD:
Update
Fixed stuff
Changes
```

### Branch Naming
```
✅ GOOD:
feature/user-authentication
bugfix/login-button-issue
hotfix/critical-crash

❌ BAD:
my-branch
test
fix
```

---

## 📊 Performance Metrics

### Target Metrics
- **App Size**: < 50 MB
- **Startup Time**: < 2 seconds
- **Frame Rate**: 60 FPS
- **Memory Usage**: < 200 MB
- **Network Requests**: < 3 seconds

### Monitoring
```dart
// ✅ GOOD: استخدام Performance monitoring
final stopwatch = Stopwatch()..start();
await heavyOperation();
stopwatch.stop();
AppLogger.info('Operation took: ${stopwatch.elapsedMilliseconds}ms');
```

---

## 🎨 UI/UX Best Practices

### Loading States
```dart
// ✅ GOOD: عرض loading indicator
if (state.isLoading) {
  return Center(child: CircularProgressIndicator());
}

// ❌ BAD: شاشة فارغة أثناء التحميل
if (state.isLoading) {
  return SizedBox.shrink();
}
```

### Empty States
```dart
// ✅ GOOD: عرض رسالة واضحة
if (items.isEmpty) {
  return EmptyStateView(
    message: 'لا توجد رحلات',
    icon: Icons.directions_bus,
    onRefresh: () => loadTrips(),
  );
}
```

### Error States
```dart
// ✅ GOOD: عرض خطأ مع إمكانية إعادة المحاولة
if (state.error != null) {
  return ErrorView(
    message: state.error!,
    onRetry: () => retry(),
  );
}
```

---

## 🔍 Code Review Checklist

### Before Submitting PR
- [ ] All tests passing
- [ ] No linter warnings
- [ ] Code documented
- [ ] Performance tested
- [ ] UI tested on multiple devices
- [ ] Accessibility checked
- [ ] Security reviewed
- [ ] Git history clean

### Reviewer Checklist
- [ ] Code follows architecture
- [ ] No code duplication
- [ ] Error handling proper
- [ ] Performance acceptable
- [ ] UI/UX consistent
- [ ] Tests adequate
- [ ] Documentation clear

---

## 📚 Resources

- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Documentation](https://riverpod.dev/)

---

## 🎉 Conclusion

اتباع هذه الممارسات يضمن:
- ✅ كود نظيف وقابل للصيانة
- ✅ أداء ممتاز
- ✅ تجربة مستخدم رائعة
- ✅ سهولة التطوير المستقبلي

**Happy Coding! 🚀**

