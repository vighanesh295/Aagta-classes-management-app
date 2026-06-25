// lib/routes/app_router.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/student/screens/student_dashboard.dart';
import '../features/student/screens/student_profile_screen.dart';
import '../features/student/screens/fee_details_screen.dart';
import '../features/student/screens/attendance_screen.dart';
import '../features/student/screens/study_material_screen.dart';
import '../features/student/screens/results_screen.dart';
import '../features/student/screens/notifications_screen.dart';
import '../features/teacher/screens/teacher_dashboard.dart';
import '../features/teacher/screens/lecture_schedule_screen.dart';
import '../features/teacher/screens/upload_material_screen.dart';
import '../features/teacher/screens/student_attendance_screen.dart';
import '../features/teacher/screens/homework_screen.dart';
import '../features/admin/screens/admin_dashboard.dart';
import '../features/admin/screens/manage_students_screen.dart';
import '../features/admin/screens/manage_teachers_screen.dart';
import '../features/admin/screens/fee_management_screen.dart';
import '../features/admin/screens/analytics_screen.dart';
import '../features/admin/screens/batch_management_screen.dart';
import '../features/admin/screens/announcements_screen.dart';
import '../features/common/screens/profile_screen.dart';

// ── Route names ────────────────────────────────────────────────────────────
class Routes {
  static const splash          = '/';
  static const login           = '/login';
  static const register        = '/register';
  static const forgotPassword  = '/forgot-password';

  static const studentDashboard = '/student';
  static const studentProfile   = '/student/profile';
  static const feeDetails       = '/student/fees';
  static const attendance       = '/student/attendance';
  static const studyMaterial    = '/student/materials';
  static const results          = '/student/results';
  static const notifications    = '/student/notifications';

  static const teacherDashboard = '/teacher';
  static const lectureSchedule  = '/teacher/schedule';
  static const uploadMaterial   = '/teacher/upload';
  static const markAttendance   = '/teacher/attendance';
  static const homework         = '/teacher/homework';

  static const adminDashboard   = '/admin';
  static const manageStudents   = '/admin/students';
  static const manageTeachers   = '/admin/teachers';
  static const manageFees       = '/admin/fees';
  static const analytics        = '/admin/analytics';
  static const batchManagement  = '/admin/batches';
  static const announcements    = '/admin/announcements';

  static const profile          = '/profile';
}

// ── Router provider ────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: _AuthChangeNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(currentUserProvider);
      if (authState.isLoading) return null; // Wait for auth state to load

      final user = authState.valueOrNull;
      final isAuth = user != null;
      final isOnAuth = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.register ||
          state.matchedLocation == Routes.forgotPassword ||
          state.matchedLocation == Routes.splash;

      if (!isAuth && !isOnAuth) {
        // In debug mode, allow bypassing auth to test dashboards directly
        if (kDebugMode && state.matchedLocation != Routes.splash) {
          return null; 
        }
        return Routes.login;
      }

      if (isAuth && isOnAuth && state.matchedLocation != Routes.splash) {
        switch (user.role) {
          case UserRole.student: return Routes.studentDashboard;
          case UserRole.teacher: return Routes.teacherDashboard;
          case UserRole.admin:   return Routes.adminDashboard;
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash,         builder: (_, __) => const SplashScreen()),
      GoRoute(path: Routes.login,          builder: (_, __) => const LoginScreen()),
      GoRoute(path: Routes.register,       builder: (_, __) => const RegisterScreen()),
      GoRoute(path: Routes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),

      // Student routes
      GoRoute(path: Routes.studentDashboard, builder: (_, __) => const StudentDashboard()),
      GoRoute(path: Routes.studentProfile,   builder: (_, __) => const StudentProfileScreen()),
      GoRoute(path: Routes.feeDetails,       builder: (_, __) => const FeeDetailsScreen()),
      GoRoute(path: Routes.attendance,       builder: (_, __) => const AttendanceScreen()),
      GoRoute(path: Routes.studyMaterial,    builder: (_, __) => const StudyMaterialScreen()),
      GoRoute(path: Routes.results,          builder: (_, __) => const ResultsScreen()),
      GoRoute(path: Routes.notifications,    builder: (_, __) => const NotificationsScreen()),

      // Teacher routes
      GoRoute(path: Routes.teacherDashboard, builder: (_, __) => Theme(data: AppTheme.teacherLight, child: const TeacherDashboard())),
      GoRoute(path: Routes.lectureSchedule,  builder: (_, __) => Theme(data: AppTheme.teacherLight, child: const LectureScheduleScreen())),
      GoRoute(path: Routes.uploadMaterial,   builder: (_, __) => Theme(data: AppTheme.teacherLight, child: const UploadMaterialScreen())),
      GoRoute(path: Routes.markAttendance,   builder: (_, __) => Theme(data: AppTheme.teacherLight, child: const StudentAttendanceScreen())),
      GoRoute(path: Routes.homework,         builder: (_, __) => Theme(data: AppTheme.teacherLight, child: const HomeworkScreen())),

      // Admin routes
      GoRoute(path: Routes.adminDashboard,  builder: (_, __) => Theme(data: AppTheme.adminLight, child: const AdminDashboard())),
      GoRoute(path: Routes.manageStudents,  builder: (_, __) => Theme(data: AppTheme.adminLight, child: const ManageStudentsScreen())),
      GoRoute(path: Routes.manageTeachers,  builder: (_, __) => Theme(data: AppTheme.adminLight, child: const ManageTeachersScreen())),
      GoRoute(path: Routes.manageFees,      builder: (_, __) => Theme(data: AppTheme.adminLight, child: const FeeManagementScreen())),
      GoRoute(path: Routes.analytics,       builder: (_, __) => Theme(data: AppTheme.adminLight, child: const AnalyticsScreen())),
      GoRoute(path: Routes.batchManagement, builder: (_, __) => Theme(data: AppTheme.adminLight, child: const BatchManagementScreen())),
      GoRoute(path: Routes.announcements,   builder: (_, __) => Theme(data: AppTheme.adminLight, child: const AdminAnnouncementsScreen())),

      // Common
      GoRoute(path: Routes.profile,  builder: (_, __) => const ProfileScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }
}
