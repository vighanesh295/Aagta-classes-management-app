// lib/core/constants/app_strings.dart

class AppStrings {
  AppStrings._();

  // App
  static const String appName     = 'Aagte Classes';
  static const String tagline     = 'Learn Today, Lead Tomorrow';
  static const String appVersion  = 'v1.0.0';

  // Auth
  static const String login           = 'Login';
  static const String logout          = 'Logout';
  static const String email           = 'Email Address';
  static const String password        = 'Password';
  static const String forgotPassword  = 'Forgot Password?';
  static const String rememberMe      = 'Remember Me';
  static const String selectRole      = 'Select Your Role';
  static const String studentRole     = 'Student';
  static const String teacherRole     = 'Teacher';
  static const String adminRole       = 'Admin';
  static const String resetPassword   = 'Reset Password';
  static const String sendResetLink   = 'Send Reset Link';
  static const String backToLogin     = 'Back to Login';
  static const String register        = 'Register';
  static const String createAccount   = 'Create Account';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";
  static const String signUp          = 'Sign Up';
  static const String fullName        = 'Full Name';

  // Dashboard
  static const String dashboard       = 'Dashboard';
  static const String welcome         = 'Welcome back,';
  static const String feeStatus       = 'Fee Status';
  static const String attendance      = 'Attendance';
  static const String studyMaterial   = 'Study Material';
  static const String upcomingExams   = 'Upcoming Exams';
  static const String results         = 'Results';
  static const String notifications   = 'Notifications';
  static const String announcements   = 'Announcements';

  // Fee
  static const String totalFees       = 'Total Fees';
  static const String paidAmount      = 'Paid Amount';
  static const String remainingAmount = 'Remaining Amount';
  static const String dueDate         = 'Due Date';
  static const String installments    = 'Installments';
  static const String paymentHistory  = 'Payment History';
  static const String paid            = 'PAID';
  static const String pending         = 'PENDING';
  static const String overdue         = 'OVERDUE';

  // Teacher
  static const String lectureSchedule = 'Lecture Schedule';
  static const String todaysClasses   = "Today's Classes";
  static const String uploadNotes     = 'Upload Notes/PDF';
  static const String homework        = 'Homework';
  static const String performance     = 'Student Performance';

  // Admin
  static const String manageStudents  = 'Manage Students';
  static const String manageTeachers  = 'Manage Teachers';
  static const String manageFees      = 'Manage Fees';
  static const String analytics       = 'Analytics';
  static const String batchManagement = 'Batch Management';
  static const String totalStudents   = 'Total Students';
  static const String totalTeachers   = 'Total Teachers';
  static const String feesCollected   = 'Fees Collected';
  static const String pendingFees     = 'Pending Fees';
  static const String monthlyRevenue  = 'Monthly Revenue';

  // Common
  static const String profile         = 'Profile';
  static const String settings        = 'Settings';
  static const String darkMode        = 'Dark Mode';
  static const String save            = 'Save';
  static const String cancel          = 'Cancel';
  static const String delete          = 'Delete';
  static const String edit            = 'Edit';
  static const String add             = 'Add';
  static const String search          = 'Search';
  static const String noData          = 'No data available';
  static const String loading         = 'Loading...';
  static const String retry           = 'Retry';
  static const String submit          = 'Submit';

  // Errors
  static const String errorGeneric    = 'Something went wrong. Please try again.';
  static const String errorNetwork    = 'No internet connection.';
  static const String errorAuth       = 'Invalid email or password.';
  static const String errorRequired   = 'This field is required.';
  static const String errorEmail      = 'Enter a valid email address.';
  static const String errorPassword   = 'Password must be at least 6 characters.';

  // Notifications
  static const String installmentReminder = 'Installment Reminder';
  static const String feeReminderBody     =
      'Reminder: Your installment payment is due in {days} days.';
}
