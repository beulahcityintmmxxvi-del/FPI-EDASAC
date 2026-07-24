import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../services/student_service.dart';

class StudentProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  // ==================== STATE ====================

  Map<String, dynamic>? _dashboardData;
  List<CourseModel> _availableCourses = [];
  List<CourseModel> _enrolledCourses = [];
  List<AssignmentModel> _assignments = [];
  List<SubmissionModel> _submissions = [];

  bool _isLoadingDashboard = false;
  bool _isLoadingCourses = false;
  bool _isLoadingAssignments = false;

  String? _errorMessage;

  // ==================== GETTERS ====================

  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<CourseModel> get availableCourses => _availableCourses;
  List<CourseModel> get enrolledCourses => _enrolledCourses;
  List<AssignmentModel> get assignments => _assignments;
  List<SubmissionModel> get submissions => _submissions;

  bool get isLoadingDashboard => _isLoadingDashboard;
  bool get isLoadingCourses => _isLoadingCourses;
  bool get isLoadingAssignments => _isLoadingAssignments;

  String? get errorMessage => _errorMessage;

  int get totalEnrollments => _dashboardData?['enrollments']?['total'] ?? 0;
  int get completedCourses => _dashboardData?['enrollments']?['completed'] ?? 0;
  int get availableCoursesCount =>
      _dashboardData?['courses']?['available'] ?? 0;
  int get pendingAssignments => _dashboardData?['assignments']?['pending'] ?? 0;
  int get submittedAssignments =>
      _dashboardData?['assignments']?['submitted'] ?? 0;
  int get gradedAssignments => _dashboardData?['assignments']?['graded'] ?? 0;

  // ==================== ACTIONS ====================

  Future<void> loadDashboard() async {
    _isLoadingDashboard = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _studentService.getDashboard();

    _isLoadingDashboard = false;

    if (response.success) {
      _dashboardData = response.data;
    } else {
      _errorMessage = response.message;
    }

    notifyListeners();
  }

  Future<void> loadAvailableCourses() async {
    _isLoadingCourses = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _studentService.getAvailableCourses();

    _isLoadingCourses = false;

    if (response.success) {
      _availableCourses = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }

    notifyListeners();
  }

  Future<void> loadEnrolledCourses() async {
    _isLoadingCourses = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _studentService.getEnrolledCourses();

    _isLoadingCourses = false;

    if (response.success) {
      _enrolledCourses = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }

    notifyListeners();
  }

  Future<bool> enrollInCourse(int courseId) async {
    final response = await _studentService.enrollInCourse(courseId);

    if (response.success) {
      // Refresh everything so:
      //  - Enrolled tab picks up the new course
      //  - Available tab keeps showing it with "Enrolled" state
      //  - Dashboard counters update
      await Future.wait([
        loadEnrolledCourses(),
        loadAvailableCourses(),
        loadDashboard(),
      ]);
      return true;
    }

    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<void> loadAssignments() async {
    _isLoadingAssignments = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _studentService.getAssignments();

    _isLoadingAssignments = false;

    if (response.success) {
      _assignments = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }

    notifyListeners();
  }

  Future<void> loadSubmissions() async {
    final response = await _studentService.getMySubmissions();

    if (response.success) {
      _submissions = response.data ?? [];
      notifyListeners();
    }
  }

  Future<bool> submitAssignment({
    required int assignmentId,
    String? submissionText,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final response = await _studentService.submitAssignment(
      assignmentId: assignmentId,
      submissionText: submissionText,
      fileBytes: fileBytes,
      fileName: fileName,
    );

    if (response.success) {
      await Future.wait([
        loadSubmissions(),
        loadDashboard(),
      ]);
      return true;
    }

    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadDashboard(),
      loadEnrolledCourses(),
      loadAvailableCourses(),
      loadAssignments(),
      loadSubmissions(),
    ]);
  }

  Future<bool> updateSubmission({
    required int assignmentId,
    String? submissionText,
    List<int>? fileBytes,
    String? fileName,
  }) =>
      submitAssignment(
        assignmentId: assignmentId,
        submissionText: submissionText,
        fileBytes: fileBytes,
        fileName: fileName,
      );

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _dashboardData = null;
    _availableCourses = [];
    _enrolledCourses = [];
    _assignments = [];
    _submissions = [];
    _errorMessage = null;
    notifyListeners();
  }
}
