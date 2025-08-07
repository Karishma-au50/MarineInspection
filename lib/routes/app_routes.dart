import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:marine_inspection/routes/app_pages.dart';
import '../features/Inspections/view/inspection_detail_screen.dart';
import '../features/Splash/splash_screen.dart';
import '../features/Auth/login_screen.dart';
import '../features/Home/role_based_home_screen.dart';
import '../features/Inspections/view/inspections_screen.dart';
import '../features/Reports/reports_screen.dart';
import '../features/Profile/profile_screen.dart';
import '../features/QuestionAnswer/dynamic_question_answer_screen.dart';
import '../shared/widgets/main_shell.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: AppPages.splash,
    routes: [
      // Routes without bottom navigation
      GoRoute(
        path: AppPages.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppPages.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppPages.questionAnswer,
        name: 'questionAnswer',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return QuestionAnswerScreen(
            section: extra?['section'],
            templateId: extra?['templateId'],
            inspectionId: extra?['inspectionId'],
          );
        },
      ),

      // Shell route with persistent bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) {
              return RoleBasedHomeScreen(key: UniqueKey());
            },
          ),
          GoRoute(
            path: AppPages.inspections,
            name: 'inspections',
            builder: (context, state) => InspectionsScreen(),
          ),
          GoRoute(
            path: AppPages.reports,
            name: 'reports',
            builder: (context, state) => ReportsScreen(),
          ),
          GoRoute(
            path: AppPages.profile,
            name: 'profile',
            builder: (context, state) => ProfileScreen(),
          ),
          GoRoute(
            path: AppPages.inspectionDetail,
            name: 'inspectionDetail',
            builder: (context, state) {
              final section = state.extra as String;
              return InspectionDetailScreen(sectionId: section);
            },
          ),
        ],
      ),
    ],
  );
}
