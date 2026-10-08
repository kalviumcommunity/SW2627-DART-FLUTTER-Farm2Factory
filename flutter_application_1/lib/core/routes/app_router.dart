import 'package:go_router/go_router.dart';

<<<<<<< HEAD
=======
import '../../features/admin/screens/collector_details_screen.dart';
import '../../features/admin/screens/collectors_screen.dart';
>>>>>>> origin/main
import '../../features/admin/screens/dairy_admin_dashboard_screen.dart';
import '../../features/admin/screens/dairy_payments_screen.dart';
import '../../features/admin/screens/dispatch_screen.dart';
import '../../features/admin/screens/locations_screen.dart';
import '../../features/admin/screens/quality_analytics_screen.dart';
import '../../features/admin/screens/reports_export_screen.dart';
import '../../features/admin/screens/sellers_screen.dart';
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
<<<<<<< HEAD
=======

  // Dairy Operations Portal routes
  static const dairyCollectors = '/dairy/collectors';
  static String dairyCollectorDetails(String id) => '/dairy/collectors/$id';
  static const dairyDispatch = '/dairy/dispatch';
  static const dairySellers = '/dairy/sellers';
  static const dairyQuality = '/dairy/quality';
  static const dairyPayments = '/dairy/payments';
  static const dairyReports = '/dairy/reports';
  static const dairyLocations = '/dairy/locations';
>>>>>>> origin/main
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
      // Dairy Operations Portal Routes
      GoRoute(
        path: AppRoutes.dairyCollectors,
        builder: (context, state) => const CollectorsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => CollectorDetailsScreen(
              collectorId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.dairyDispatch,
        builder: (context, state) => const DispatchScreen(),
      ),
      GoRoute(
        path: AppRoutes.dairySellers,
        builder: (context, state) => const SellersScreen(),
      ),
      GoRoute(
        path: AppRoutes.dairyQuality,
        builder: (context, state) => const QualityAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.dairyPayments,
        builder: (context, state) => const DairyPaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.dairyReports,
        builder: (context, state) => const ReportsExportScreen(),
      ),
      GoRoute(
        path: AppRoutes.dairyLocations,
        builder: (context, state) => const LocationsScreen(),
      ),
    ],
  );
}
