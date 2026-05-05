import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:moneywise/features/budget/presentation/screens/budget_screen.dart';
import 'package:moneywise/features/categories/presentation/screens/categories_screen.dart';
import 'package:moneywise/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:moneywise/features/loans/presentation/screens/loan_detail_screen.dart';
import 'package:moneywise/features/loans/presentation/screens/loans_screen.dart';
import 'package:moneywise/features/settings/presentation/screens/lock_screen.dart';
import 'package:moneywise/features/settings/presentation/screens/pin_setup_screen.dart';
import 'package:moneywise/features/settings/presentation/screens/settings_screen.dart';
import 'package:moneywise/features/sms/presentation/screens/sms_import_screen.dart';
import 'package:moneywise/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:moneywise/routing/route_names.dart';
import 'package:moneywise/shared/widgets/app_bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: const AppBottomNav(),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            name: RouteNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/analytics',
            name: RouteNames.analytics,
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/loans',
            name: RouteNames.loans,
            builder: (context, state) => const LoansScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: RouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/categories',
            name: 'categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/pin-setup',
            name: 'pin-setup',
            builder: (context, state) => const PinSetupScreen(),
          ),
          GoRoute(
            path: '/budget',
            name: 'budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/sms-import',
            name: 'sms-import',
            builder: (context, state) => const SmsImportScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/loans/:uuid',
        builder: (context, state) => LoanDetailScreen(uuid: state.pathParameters['uuid']!),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),
    ],
  );
});
