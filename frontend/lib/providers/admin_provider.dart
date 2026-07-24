import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  // ==================== STATE ====================

  Map<String, dynamic>? _dashboardData;
  List<UserModel> _students = [];
  List<UserModel> _tutors = [];
  List<UserModel> _pendingTutors = [];
  List<Map<String, dynamic>> _vocationAnalytics = [];
  List<Map<String, dynamic>> _departmentAnalytics = [];

  bool _isLoadingDashboard = false;
  bool _isLoadingUsers = false;
  bool _isLoadingAnalytics = false;

  String? _errorMessage;
  String _userSearchQuery = '';
  String _userRoleFilter = 'all';

  // ==================== GETTERS ====================

  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<UserModel> get students => _students;
  List<UserModel> get tutors => _tutors;
  List<UserModel> get pendingTutors => _pendingTutors;
  List<Map<String, dynamic>> get vocationAnalytics => _vocationAnalytics;
  List<Map<String, dynamic>> get departmentAnalytics =>
      _departmentAnalytics;

  bool get isLoadingDashboard => _isLoadingDashboard;
  bool get isLoadingUsers => _isLoadingUsers;
  bool get isLoadingAnalytics => _isLoadingAnalytics;

  String? get errorMessage => _errorMessage;
  String get userRoleFilter => _userRoleFilter;
  String get userSearchQuery => _userSearchQuery;

  // Dashboard stats getters
  int get totalStudents =>
      _dashboardData?['users']?['total_students'] ?? 0;
  int get totalTutors =>
      _dashboardData?['users']?['total_tutors'] ?? 0;
  int get pendingApprovals =>
      _dashboardData?['users']?['pending_tutor_approvals'] ?? 0;
  int get newStudentsThisWeek =>
      _dashboardData?['users']?['new_students_this_week'] ?? 0;
  int get totalCourses =>
      _dashboardData?['courses']?['total'] ?? 0;
  int get publishedCourses =>
      _dashboardData?['courses']?['published'] ?? 0;
  int get totalAssignments =>
      _dashboardData?['assignments']?['total'] ?? 0;
  int get pendingGrading =>
      _dashboardData?['assignments']?['pending_grading'] ?? 0;
  int get totalEnrollments =>
      _dashboardData?['enrollments']?['total'] ?? 0;
  int get completedEnrollments =>
      _dashboardData?['enrollments']?['completed'] ?? 0;

  // Filtered users list
  List<UserModel> get filteredUsers {
    List<UserModel> users;

    switch (_userRoleFilter) {
      case 'student':
        users = _students;
        break;
      case 'tutor':
        users = _tutors;
        break;
      default:
        users = [..._students, ..._tutors];
    }

    if (_userSearchQuery.isEmpty) return users;

    return users.where((user) {
      final query = _userSearchQuery.toLowerCase();
      return user.fullName.toLowerCase().contains(query) ||
          (user.matricNumber?.toLowerCase().contains(query) ?? false) ||
          (user.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  // ==================== ACTIONS ====================

  Future<void> loadDashboard() async {
    _isLoadingDashboard = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _adminService.getDashboard();

    _isLoadingDashboard = false;

    if (response.success) {
      _dashboardData = response.data;
    } else {
      _errorMessage = response.message;
    }

    notifyListeners();
  }

  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    _errorMessage = null;
    notifyListeners();

    final results = await Future.wait([
      _adminService.getAllStudents(),
      _adminService.getAllUsers(role: 'tutor'),
    ]);

    _isLoadingUsers = false;

    final studentResponse = results[0];
    final tutorResponse = results[1];

    if (studentResponse.success) {
      _students = studentResponse.data ?? [];
    }
    if (tutorResponse.success) {
      _tutors = tutorResponse.data ?? [];
    }

    notifyListeners();
  }

  Future<void> loadPendingTutors() async {
    final response = await _adminService.getPendingTutors();
    if (response.success) {
      _pendingTutors = response.data ?? [];
      notifyListeners();
    }
  }

  Future<bool> approveTutor(int tutorId) async {
    final response = await _adminService.approveTutor(tutorId);

    if (response.success) {
      _pendingTutors.removeWhere((t) => t.id == tutorId);
      await Future.wait([loadDashboard(), loadUsers()]);
      return true;
    }

    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> rejectTutor(int tutorId) async {
    final response = await _adminService.rejectTutor(tutorId);

    if (response.success) {
      _pendingTutors.removeWhere((t) => t.id == tutorId);
      notifyListeners();
      return true;
    }

    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> toggleUserActive(int userId) async {
    final response = await _adminService.toggleUserActive(userId);

    if (response.success) {
      await loadUsers();
      return true;
    }

    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<void> loadAnalytics() async {
    _isLoadingAnalytics = true;
    notifyListeners();

    final results = await Future.wait([
      _adminService.getEnrollmentByVocation(),
      _adminService.getEnrollmentByDepartment(),
    ]);

    _isLoadingAnalytics = false;

    if (results[0].success) {
      _vocationAnalytics = results[0].data ?? [];
    }
    if (results[1].success) {
      _departmentAnalytics = results[1].data ?? [];
    }

    notifyListeners();
  }

  void setUserRoleFilter(String role) {
    _userRoleFilter = role;
    notifyListeners();
  }

  void setUserSearchQuery(String query) {
    _userSearchQuery = query;
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadDashboard(),
      loadUsers(),
      loadPendingTutors(),
      loadAnalytics(),
    ]);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _dashboardData = null;
    _students = [];
    _tutors = [];
    _pendingTutors = [];
    _vocationAnalytics = [];
    _departmentAnalytics = [];
    _errorMessage = null;
    notifyListeners();
  }
}