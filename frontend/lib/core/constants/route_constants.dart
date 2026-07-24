/// Navigation Route Names
class RouteConstants {
  RouteConstants._();

  // ==================== ROOT ROUTES ====================

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // ==================== AUTH ROUTES ====================

  static const String login = '/login';
  static const String studentRegistration = '/register/student';
  static const String tutorRegistration = '/register/tutor';
  static const String forgotPassword = '/forgot-password';
  static const String changePassword = '/change-password';

  // ==================== STUDENT ROUTES ====================

  static const String studentDashboard = '/student/dashboard';
  static const String studentCourses = '/student/courses';
  static const String studentCourseDetail = '/student/courses/:id';
  static const String studentCourseModules = '/student/courses/:id/modules';
  static const String studentModuleDetail = '/student/modules/:id';
  static const String studentVocationEnroll = '/student/vocations/enroll';
  static const String studentAssignments = '/student/assignments';
  static const String studentSubmitAssignment =
      '/student/assignments/:id/submit';
  static const String studentReviews = '/student/reviews';
  static const String studentProfile = '/student/profile';
  static const String studentEditProfile = '/student/profile/edit';
  static const String studentSettings = '/student/settings';

  // ==================== TUTOR ROUTES ====================

  static const String tutorDashboard = '/tutor/dashboard';
  static const String tutorCourses = '/tutor/courses';
  static const String tutorCreateCourse = '/tutor/courses/create';
  static const String tutorEditCourse = '/tutor/courses/:id/edit';
  static const String tutorCourseModules = '/tutor/courses/:id/modules';
  static const String tutorUploadContent = '/tutor/modules/:id/upload';
  static const String tutorAssignments = '/tutor/assignments';
  static const String tutorCreateAssignment = '/tutor/assignments/create';
  static const String tutorGrading = '/tutor/assignments/:id/grade';
  static const String tutorStudentAssessment = '/tutor/courses/:id/students';
  static const String tutorProfile = '/tutor/profile';
  static const String tutorEditProfile = '/tutor/profile/edit';
  static const String tutorSettings = '/tutor/settings';

  // ==================== ADMIN ROUTES ====================

  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminStudents = '/admin/users/students';
  static const String adminTutors = '/admin/users/tutors';
  static const String adminApproveTutors = '/admin/users/tutors/pending';
  static const String adminUserActivation = '/admin/users/:id/activate';
  static const String adminActivitySubmissions =
      '/admin/activities/submissions';
  static const String adminActivityEnrollments =
      '/admin/activities/enrollments';
  static const String adminActivityCourses = '/admin/activities/courses';
  static const String adminDepartments = '/admin/departments';
  static const String adminVocations = '/admin/vocations';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminBulkImport = '/admin/bulk-import';
  static const String adminProfile = '/admin/profile';
  static const String adminEditProfile = '/admin/profile/edit';
  static const String adminSettings = '/admin/settings';
}
