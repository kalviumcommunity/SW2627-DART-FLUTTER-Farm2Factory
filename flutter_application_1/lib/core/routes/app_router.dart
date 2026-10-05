import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/farmers/screens/add_farmer_screen.dart';
import '../../features/farmers/screens/farmer_details_screen.dart';
import '../../features/farmers/screens/farmers_screen.dart';

/// Route names in one place, so we never type paths by hand in screens.
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const farmers = '/farmers';
  static const addFarmer = '/farmers/add';
  static String farmerDetails(String id) => '/farmers/$id';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        // After registering we send the mobile number here ("extra"),
        // so the login screen can fill it in. (Never the password.)
        builder: (context, state) => LoginScreen(
          initialPhone: state.extra is String ? state.extra as String : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmers,
        builder: (context, state) => const FarmersScreen(),
        routes: [
          // 'add' must be listed BEFORE ':id', otherwise "add" is read as an id.
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddFarmerScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                FarmerDetailsScreen(farmerId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
}
