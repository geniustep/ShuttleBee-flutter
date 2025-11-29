import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/presentation/providers/auth_notifier.dart';
import 'package:shuttlebee/presentation/providers/auth_state.dart';
import 'package:shuttlebee/presentation/screens/auth/login_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/create_edit_vehicle_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/create_trip_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/dispatcher_home_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/dispatcher_trip_detail_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/edit_trip_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/real_time_monitoring_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/trip_list_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/vehicle_management_screen.dart';
import 'package:shuttlebee/presentation/screens/driver/active_trip_screen.dart';
import 'package:shuttlebee/presentation/screens/driver/driver_home_screen.dart';
import 'package:shuttlebee/presentation/screens/driver/trip_detail_screen.dart';
import 'package:shuttlebee/presentation/screens/manager/analytics_screen.dart';
import 'package:shuttlebee/presentation/screens/manager/manager_home_screen.dart';
import 'package:shuttlebee/presentation/screens/manager/reports_screen.dart';
import 'package:shuttlebee/presentation/screens/passenger/passenger_home_screen.dart';
import 'package:shuttlebee/presentation/screens/passenger/trip_tracking_screen.dart';
import 'package:shuttlebee/presentation/screens/splash/splash_screen.dart';

/// Route Names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String driverHome = '/driver';
  static const String dispatcherHome = '/dispatcher';
  static const String dispatcherTrips = '/dispatcher/trips';
  static const String dispatcherMonitor = '/dispatcher/monitor';
  static const String dispatcherVehicles = '/dispatcher/vehicles';
  static const String passengerHome = '/passenger';
  static const String managerHome = '/manager';
  static const String profile = '/profile'; // ✅ Profile route
  static const String settings = '/settings'; // ✅ Settings route
}

/// ChangeNotifier wrapper for AuthState to use with GoRouter refreshListenable
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(this._state);

  AuthState _state;

  AuthState get currentState => _state;

  void updateState(AuthState newState) {
    if (_state.isAuthenticated != newState.isAuthenticated ||
        _state.user?.id != newState.user?.id) {
      _state = newState;
      notifyListeners();
    }
  }
}

/// Create GoRouter instance with Riverpod support
GoRouter createRouter(AuthState authState, WidgetRef? ref) {
  // إنشاء ChangeNotifier للـ authState
  final authNotifier = _AuthStateNotifier(authState);

  // إذا كان ref متوفراً، مراقبة تغييرات authState
  if (ref != null) {
    ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) {
        // تحديث authState في GoRouter عند التغيير
        authNotifier.updateState(next);
      },
    );
  }

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      // استخدام authState الحالي من notifier
      final currentAuthState = authNotifier.currentState;
      final isAuthenticated = currentAuthState.isAuthenticated;
      final userRole = currentAuthState.user?.role;
      final location = state.matchedLocation;
      final isOnSplash = location == AppRoutes.splash;
      final isOnLogin = location == AppRoutes.login;

      // Debug logging
      if (isAuthenticated) {
        debugPrint(
            '[GoRouter] User authenticated: ${currentAuthState.user?.name}, role: $userRole');
      }

      // لو المستخدم غير مصدَّق، امنعه من دخول أي شاشة غير اللوجين/سبلاش
      if (!isAuthenticated && !isOnLogin && !isOnSplash) {
        debugPrint('[GoRouter] Redirecting to login - not authenticated');
        return AppRoutes.login;
      }

      // لو مصدَّق وحاول يدخل صفحة اللوجين، رجّعه للهوم حسب الدور
      if (isAuthenticated && isOnLogin) {
        final homeRoute = _getHomeRouteForUser(userRole);
        debugPrint('[GoRouter] User authenticated');
        debugPrint('[GoRouter] User role: $userRole');
        debugPrint('[GoRouter] Redirecting to: $homeRoute');
        return homeRoute;
      }

      // التحقق من الصلاحيات - منع المستخدم من الوصول لمسارات لا تنتمي لدوره
      if (isAuthenticated && userRole != null) {
        // منع السائق من الوصول لمسارات المرسل
        if (userRole != UserRole.dispatcher &&
            location.startsWith(AppRoutes.dispatcherHome)) {
          return _getHomeRouteForUser(userRole);
        }

        // منع المرسل من الوصول لمسارات السائق
        if (userRole != UserRole.driver &&
            location.startsWith(AppRoutes.driverHome)) {
          return _getHomeRouteForUser(userRole);
        }

        // منع الراكب من الوصول لمسارات السائق أو المرسل
        if (userRole == UserRole.passenger &&
            (location.startsWith(AppRoutes.driverHome) ||
                location.startsWith(AppRoutes.dispatcherHome))) {
          return _getHomeRouteForUser(userRole);
        }

        // منع المدير من الوصول لمسارات السائق أو المرسل (إلا إذا كان لديه صلاحيات)
        if (userRole == UserRole.manager &&
            (location.startsWith(AppRoutes.driverHome) ||
                location.startsWith(AppRoutes.dispatcherHome))) {
          // المدير يمكنه الوصول لجميع المسارات، لذا لا نمنعه
        }
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login Screen
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Driver Home
      GoRoute(
        path: AppRoutes.driverHome,
        builder: (context, state) => const DriverHomeScreen(),
        routes: [
          GoRoute(
            path: 'trip/:tripId',
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return TripDetailScreen(tripId: tripId);
            },
            routes: [
              GoRoute(
                path: 'active',
                builder: (context, state) {
                  final tripId = int.parse(state.pathParameters['tripId']!);
                  return ActiveTripScreen(tripId: tripId);
                },
              ),
            ],
          ),
        ],
      ),

      // Dispatcher Home + children
      GoRoute(
        path: AppRoutes.dispatcherHome,
        builder: (context, state) => const DispatcherHomeScreen(),
        routes: [
          GoRoute(
            path: 'trips',
            builder: (context, state) => const TripListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateTripScreen(),
              ),
              GoRoute(
                path: ':tripId',
                builder: (context, state) {
                  final tripId = int.parse(state.pathParameters['tripId']!);
                  return DispatcherTripDetailScreen(tripId: tripId);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final tripId = int.parse(state.pathParameters['tripId']!);
                      return EditTripScreen(tripId: tripId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'monitor',
            builder: (context, state) => const RealTimeMonitoringScreen(),
          ),
          GoRoute(
            path: 'vehicles',
            builder: (context, state) => const VehicleManagementScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateEditVehicleScreen(),
              ),
              GoRoute(
                path: ':vehicleId/edit',
                builder: (context, state) {
                  // TODO: Load vehicle from ID
                  return const Scaffold(
                    body: Center(
                      child: Text('تعديل المركبة - قيد التطوير'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // Passenger Home
      GoRoute(
        path: AppRoutes.passengerHome,
        builder: (context, state) => const PassengerHomeScreen(),
        routes: [
          GoRoute(
            path: 'track/:tripId',
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return TripTrackingScreen(tripId: tripId);
            },
          ),
        ],
      ),

      // Manager Home + children
      GoRoute(
        path: AppRoutes.managerHome,
        builder: (context, state) => const ManagerHomeScreen(),
        routes: [
          GoRoute(
            path: 'analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: 'overview',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('شاشة نظرة عامة على الأداء - قيد التطوير'),
              ),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('حدث خطأ غير متوقع:\n${state.error}'),
      ),
    ),
  );
}

/// Get home route based on user role
String _getHomeRouteForUser(UserRole? role) {
  switch (role) {
    case UserRole.driver:
      return AppRoutes.driverHome;
    case UserRole.dispatcher:
      return AppRoutes.dispatcherHome;
    case UserRole.passenger:
      return AppRoutes.passengerHome;
    case UserRole.manager:
      return AppRoutes.managerHome;
    default:
      return AppRoutes.login;
  }
}
