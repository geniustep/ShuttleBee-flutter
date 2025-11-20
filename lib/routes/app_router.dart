import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shuttlebee/core/enums/enums.dart';
import 'package:shuttlebee/presentation/providers/auth_state.dart';
import 'package:shuttlebee/presentation/screens/auth/login_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/dispatcher_home_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/real_time_monitoring_screen.dart';
import 'package:shuttlebee/presentation/screens/dispatcher/trip_list_screen.dart';
import 'package:shuttlebee/presentation/screens/driver/active_trip_screen.dart';
import 'package:shuttlebee/presentation/screens/driver/driver_home_screen.dart';
import 'package:shuttlebee/presentation/screens/driver/trip_detail_screen.dart';
import 'package:shuttlebee/presentation/screens/passenger/passenger_home_screen.dart';
import 'package:shuttlebee/presentation/screens/passenger/trip_tracking_screen.dart';
import 'package:shuttlebee/presentation/screens/splash/splash_screen.dart';

/// Route Names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String driverHome = '/driver';
  static const String dispatcherHome = '/dispatcher';
  static const String passengerHome = '/passenger';
  static const String managerHome = '/manager';
}

/// Create GoRouter instance
GoRouter createRouter(AuthState authState) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnSplash = state.matchedLocation == AppRoutes.splash;
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      // إذا كان المستخدم غير مصادق ولا يوجد على صفحة Login أو Splash
      if (!isAuthenticated && !isOnLogin && !isOnSplash) {
        return AppRoutes.login;
      }

      // إذا كان المستخدم مصادق ويحاول الوصول لـ Login
      if (isAuthenticated && isOnLogin) {
        return _getHomeRouteForUser(authState.user?.role);
      }

      return null; // لا يوجد إعادة توجيه
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
          // Trip Detail
          GoRoute(
            path: 'trip/:tripId',
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return TripDetailScreen(tripId: tripId);
            },
            routes: [
              // Active Trip
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

      // Dispatcher Home
      GoRoute(
        path: AppRoutes.dispatcherHome,
        builder: (context, state) => const DispatcherHomeScreen(),
        routes: [
          // Trip Management
          GoRoute(
            path: 'trips',
            builder: (context, state) => const TripListScreen(),
          ),
          // Real-time Monitoring
          GoRoute(
            path: 'monitor',
            builder: (context, state) => const RealTimeMonitoringScreen(),
          ),
          // Vehicles (placeholder for now)
          GoRoute(
            path: 'vehicles',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('إدارة المركبات - قريباً')),
            ),
          ),
        ],
      ),

      // Passenger Home
      GoRoute(
        path: AppRoutes.passengerHome,
        builder: (context, state) => const PassengerHomeScreen(),
        routes: [
          // Trip Tracking
          GoRoute(
            path: 'track/:tripId',
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return TripTrackingScreen(tripId: tripId);
            },
          ),
        ],
      ),

      // Manager Home
      GoRoute(
        path: AppRoutes.managerHome,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Manager Home - Coming Soon')),
        ),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('خطأ: ${state.error}'),
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
