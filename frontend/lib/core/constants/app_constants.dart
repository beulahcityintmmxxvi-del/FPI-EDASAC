/// Application-wide Constants
class AppConstants {
  AppConstants._();

  // ==================== APP INFO ====================
  static const String appName = 'EDASAC Vocational Skills';
  static const String appTagline = 'Federal Polytechnic Ilaro';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Mobile-Based Vocational Skills Acquisition System';

  // ==================== API CONFIGURATION ====================
  //
  // Use the correct host per platform:
  //  - Web / Windows / macOS / Linux desktop → http://127.0.0.1:8000
  //  - Android emulator                      → http://10.0.2.2:8000
  //  - Physical device on same Wi-Fi         → http://<your-LAN-IP>:8000
  //
  // If you deploy the backend, replace with the production URL.
  static const String baseUrl = 'http://127.0.0.1:8000';
  // static const String baseUrl = 'http://10.31.149.197:8000';
  static const String apiUrl = '$baseUrl/api';

  // ==================== API ENDPOINTS ====================
  // Authentication
  static const String loginEndpoint = '/auth/login';
  static const String registerStudentEndpoint = '/auth/register/student';
  static const String registerTutorEndpoint = '/auth/register/tutor';
  static const String changePasswordEndpoint = '/auth/change-password';
  static const String meEndpoint = '/auth/me';

  // Admin
  static const String adminDashboardEndpoint = '/admin/dashboard/stats';
  static const String adminUsersEndpoint = '/admin/users';
  static const String adminStudentsEndpoint = '/admin/users/students';
  static const String adminPendingTutorsEndpoint =
      '/admin/users/tutors/pending';
  static const String adminDepartmentsEndpoint = '/admin/departments';
  static const String adminVocationsEndpoint = '/admin/vocations';
  static const String adminSubmissionsEndpoint =
      '/admin/activities/submissions';
  static const String adminEnrollmentsEndpoint =
      '/admin/activities/enrollments';
  static const String adminAllCoursesEndpoint = '/admin/activities/courses';
  static const String adminActivateUserEndpoint = '/admin/users';

  // Tutor
  static const String tutorDashboardEndpoint = '/tutor/dashboard/stats';
  static const String tutorCoursesEndpoint = '/tutor/courses';
  static const String tutorModulesEndpoint = '/tutor/modules';
  static const String tutorAssignmentsEndpoint = '/tutor/assignments';
  static const String tutorUploadMultimediaEndpoint = '/tutor/modules';
  static const String tutorMultimediaEndpoint = '/tutor/multimedia';
  static const String tutorSubmissionsEndpoint = '/tutor/submissions';
  static const String tutorVocationsEndpoint = '/tutor/vocations';

  // Student
  static const String studentDashboardEndpoint = '/student/dashboard';
  static const String studentCoursesAvailableEndpoint =
      '/student/courses/available';
  static const String studentCoursesEnrolledEndpoint =
      '/student/courses/enrolled';
  static const String studentAssignmentsEndpoint = '/student/assignments';
  static const String studentSubmissionsEndpoint = '/student/submissions';
  static const String studentProfileEndpoint = '/student/profile';
  static const String studentDepartmentsEndpoint = '/student/departments';
  static const String studentVocationsEndpoint = '/student/vocations';
  static const String studentVocationEnrollEndpoint =
      '/student/vocations/enroll';
  static const String studentVocationSyncEndpoint = '/student/vocations/sync';
  static const String studentReviewsEndpoint = '/student/reviews';

  // Multimedia
  static const String mediaStreamEndpoint = '/media/stream';
  static const String mediaDownloadEndpoint = '/media/download';
  static const String mediaInfoEndpoint = '/media/info';

  // ==================== STORAGE KEYS ====================
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String userRoleKey = 'user_role';
  static const String isFirstLoginKey = 'is_first_login';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // ==================== HIVE BOXES ====================
  static const String userBox = 'user_box';
  static const String coursesBox = 'courses_box';
  static const String modulesBox = 'modules_box';
  static const String assignmentsBox = 'assignments_box';
  static const String cacheBox = 'cache_box';

  // ==================== VALIDATION ====================
  static const int minPasswordLength = 8;
  static const int matricNumberLength = 10;
  static const String defaultStudentPassword = '12345678';
  static const String passwordRegex =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^0[789][01]\d{8}$';
  static const String matricRegex = r'^\d{10,15}$';

  // ==================== ACADEMIC DATA ====================
  static const List<String> academicLevels = ['ND1', 'ND2', 'HND1', 'HND2'];
  static const List<String> departments = [
    'Computer Science',
    'Food Technology',
    'Hospitality Management',
    'Leisure and Tourism',
    'Nutrition and Dietetics',
    'Science Laboratory Technology',
    'Mathematics and Statistics',
  ];
  static const List<String> vocations = [
    'Barbing and Hair Dressing',
    'Venue Decoration',
    'Beads Making',
    'Shoe Making',
    'Phone Repairs',
    'ICT/Computer Repair',
    'ICT/Web Design',
    'Welding and Fabrication',
    'Aluminium Works',
    'Soap Making',
    'Block Making',
    'Fashion Designing',
    'Bag Making',
    'Catering Services',
    'Tie & Dye',
    'Water Production',
    'Poultry',
    'Plumbing',
    'Solar and CCTV',
    'Carpentry',
    'Cosmetology',
  ];

  // ==================== USER ROLES ====================
  static const String roleAdmin = 'admin';
  static const String roleTutor = 'tutor';
  static const String roleStudent = 'student';

  // ==================== UI CONSTANTS ====================
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 12.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeExtraLarge = 96.0;
  static const double cardElevation = 0.0;
  static const double modalElevation = 8.0;

  // ==================== ANIMATION DURATIONS ====================
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // ==================== FILE UPLOAD LIMITS ====================
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 500;
  static const int maxPdfSizeMB = 50;
  static const int maxDocumentSizeMB = 25;
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp'
  ];
  static const List<String> allowedVideoExtensions = [
    'mp4',
    'avi',
    'mov',
    'mkv'
  ];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx'];

  // ==================== PAGINATION ====================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ==================== ERROR MESSAGES ====================
  static const String networkErrorMessage =
      'Network error. Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String authErrorMessage =
      'Authentication failed. Please login again.';
  static const String validationErrorMessage =
      'Please fill in all required fields correctly.';
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
}
