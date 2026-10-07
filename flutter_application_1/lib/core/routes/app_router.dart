import 'package:go_router/go_router.dart';

import '../../features/admin/screens/dairy_admin_dashboard_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/collector/screens/collector_dashboard_screen.dart';
import '../../features/collector/screens/milk_entries_screen.dart';
import '../../features/collector/screens/payments_screen.dart';
import '../../features/collector/screens/reports_screen.dart';
import '../../features/farmer/screens/farmer_dashboard_screen.dart';
import '../../features/farmers/screens/add_farmer_screen.dart';
import '../../features/farmers/screens/farmer_details_screen.dart';
import '../../features/farmers/screens/farmers_screen.dart';

/// Route names in one central place.
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const collectorDashboard = '/collector/dashboard';
  static const farmerDashboard = '/farmer/dashboard';
  static const adminDashboard = '/admin/dashboard';
  static const farmers = '/farmers';
  static const addFarmer = '/farmers/add';
  static String farmerDetails(String id) => '/farmers/$id';
  static const milkEntries = '/milk-entries';
  static const reports = '/reports';
  static const payments = '/payments';
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
        builder: (context, state) => const CollectorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.collectorDashboard,
        builder: (context, state) => const CollectorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmerDashboard,
        builder: (context, state) => const FarmerDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const DairyAdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.milkEntries,
        builder: (context, state) => const MilkEntriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.payments,
        builder: (context, state) => const PaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.farmers,
        builder: (context, state) => const FarmersScreen(),
        routes: [
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
