import 'package:flutter/foundation.dart';
import '../models/course_model.dart';
import '../models/module_model.dart';
import '../models/multimedia_model.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../services/tutor_service.dart';

class TutorProvider with ChangeNotifier {
  final TutorService _tutorService = TutorService();

  // ==================== STATE ====================
  Map<String, dynamic>? _dashboardData;
  List<CourseModel> _courses = [];
  List<ModuleModel> _currentModules = [];
  List<MultimediaModel> _currentMultimedia = [];
  List<AssignmentModel> _assignments = [];
  List<SubmissionModel> _currentSubmissions = [];

  bool _isLoadingDashboard = false;
  bool _isLoadingCourses = false;
  bool _isLoadingModules = false;
  bool _isLoadingMultimedia = false;
  bool _isLoadingAssignments = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  String? _errorMessage;
  CourseModel? _selectedCourse;

  // ==================== GETTERS ====================
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<CourseModel> get courses => _courses;
  List<ModuleModel> get currentModules => _currentModules;
  List<MultimediaModel> get currentMultimedia => _currentMultimedia;
  List<AssignmentModel> get assignments => _assignments;
  List<SubmissionModel> get currentSubmissions => _currentSubmissions;

  bool get isLoadingDashboard => _isLoadingDashboard;
  bool get isLoadingCourses => _isLoadingCourses;
  bool get isLoadingModules => _isLoadingModules;
  bool get isLoadingMultimedia => _isLoadingMultimedia;
  bool get isLoadingAssignments => _isLoadingAssignments;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;

  String? get errorMessage => _errorMessage;
  CourseModel? get selectedCourse => _selectedCourse;

  int get totalCourses => _dashboardData?['courses']?['total'] ?? 0;
  int get publishedCourses => _dashboardData?['courses']?['published'] ?? 0;
  int get draftCourses => _dashboardData?['courses']?['draft'] ?? 0;
  int get totalModules => _dashboardData?['content']?['total_modules'] ?? 0;
  int get totalAssignments => _dashboardData?['assignments']?['total'] ?? 0;
  int get pendingGrading =>
      _dashboardData?['assignments']?['pending_grading'] ?? 0;

  // ==================== DASHBOARD ====================
  Future<void> loadDashboard() async {
    _isLoadingDashboard = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _tutorService.getDashboard();

    _isLoadingDashboard = false;
    if (response.success) {
      _dashboardData = response.data;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  // ==================== COURSES ====================
  Future<void> loadCourses() async {
    _isLoadingCourses = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _tutorService.getMyCourses();

    _isLoadingCourses = false;
    if (response.success) {
      _courses = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> createCourse({
    required String title,
    required String description,
    required int vocationId,
    bool isPublished = false,
  }) async {
    final response = await _tutorService.createCourse(
      title: title,
      description: description,
      vocationId: vocationId,
      isPublished: isPublished,
    );

    if (response.success && response.data != null) {
      _courses.insert(0, response.data!);
      await loadDashboard();
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> updateCourse({
    required int courseId,
    String? title,
    String? description,
    int? vocationId,
    bool? isPublished,
  }) async {
    final response = await _tutorService.updateCourse(
      courseId: courseId,
      title: title,
      description: description,
      vocationId: vocationId,
      isPublished: isPublished,
    );

    if (response.success && response.data != null) {
      final index = _courses.indexWhere((c) => c.id == courseId);
      if (index != -1) _courses[index] = response.data!;
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteCourse(int courseId) async {
    final response = await _tutorService.deleteCourse(courseId);
    if (response.success) {
      _courses.removeWhere((c) => c.id == courseId);
      await loadDashboard();
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  void selectCourse(CourseModel course) {
    _selectedCourse = course;
    notifyListeners();
  }

  // ==================== MODULES ====================
  Future<void> loadModules(int courseId) async {
    _isLoadingModules = true;
    _currentModules = [];
    notifyListeners();

    final response = await _tutorService.getCourseModules(courseId);

    _isLoadingModules = false;
    if (response.success) {
      _currentModules = response.data ?? [];
      _currentModules.sort((a, b) => a.order.compareTo(b.order));
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> createModule({
    required int courseId,
    required String title,
    String? description,
    int order = 0,
    int? durationMinutes,
  }) async {
    final response = await _tutorService.createModule(
      courseId: courseId,
      title: title,
      description: description,
      order: order,
      durationMinutes: durationMinutes,
    );

    if (response.success && response.data != null) {
      _currentModules.add(response.data!);
      _currentModules.sort((a, b) => a.order.compareTo(b.order));
      await loadDashboard();
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> updateModule({
    required int moduleId,
    String? title,
    String? description,
    int? order,
    int? durationMinutes,
    bool? isPublished,
  }) async {
    final response = await _tutorService.updateModule(
      moduleId: moduleId,
      title: title,
      description: description,
      order: order,
      durationMinutes: durationMinutes,
      isPublished: isPublished,
    );

    if (response.success && response.data != null) {
      final index = _currentModules.indexWhere((m) => m.id == moduleId);
      if (index != -1) _currentModules[index] = response.data!;
      _currentModules.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteModule(int moduleId) async {
    final response = await _tutorService.deleteModule(moduleId);
    if (response.success) {
      _currentModules.removeWhere((m) => m.id == moduleId);
      await loadDashboard();
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  // ==================== MULTIMEDIA ====================
  Future<void> loadMultimedia(int moduleId) async {
    _isLoadingMultimedia = true;
    _currentMultimedia = [];
    notifyListeners();

    final response = await _tutorService.getModuleMultimedia(moduleId);

    _isLoadingMultimedia = false;
    if (response.success) {
      _currentMultimedia = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> uploadMultimedia({
    required int moduleId,
    required String title,
    String? description,
    required List<int> fileBytes,
    required String fileName,
    int order = 0,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    final response = await _tutorService.uploadMultimedia(
      moduleId: moduleId,
      title: title,
      description: description,
      fileBytes: fileBytes,
      fileName: fileName,
      order: order,
      onProgress: (sent, total) {
        if (total > 0) {
          _uploadProgress = sent / total;
          notifyListeners();
        }
      },
    );

    _isUploading = false;
    _uploadProgress = 0.0;

    if (response.success && response.data != null) {
      _currentMultimedia.add(response.data!);
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteMultimedia(int multimediaId) async {
    final response = await _tutorService.deleteMultimedia(multimediaId);
    if (response.success) {
      _currentMultimedia.removeWhere((m) => m.id == multimediaId);
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  // ==================== ASSIGNMENTS ====================
  Future<void> loadAssignments({int? courseId}) async {
    _isLoadingAssignments = true;
    notifyListeners();

    final response = await _tutorService.getMyAssignments(courseId: courseId);

    _isLoadingAssignments = false;
    if (response.success) {
      _assignments = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> createAssignment({
    required int courseId,
    required String title,
    String? description,
    required double maxScore,
    String assignmentType = 'practical',
  }) async {
    final response = await _tutorService.createAssignment(
      courseId: courseId,
      title: title,
      description: description,
      maxScore: maxScore,
      assignmentType: assignmentType,
    );

    if (response.success && response.data != null) {
      _assignments.insert(0, response.data!);
      await loadDashboard();
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> createAssignmentWithAttachment({
    required int courseId,
    required String title,
    required String description,
    required double maxScore,
    String assignmentType = 'practical',
    List<int>? fileBytes,
    String? fileName,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    final response = await _tutorService.createAssignmentWithAttachment(
      courseId: courseId,
      title: title,
      description: description,
      maxScore: maxScore,
      assignmentType: assignmentType,
      fileBytes: fileBytes,
      fileName: fileName,
      onProgress: (sent, total) {
        if (total > 0) {
          _uploadProgress = sent / total;
          notifyListeners();
        }
      },
    );

    _isUploading = false;
    _uploadProgress = 0.0;

    if (response.success && response.data != null) {
      _assignments.insert(0, response.data!);
      await loadDashboard();
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> updateAssignment({
    required int assignmentId,
    String? title,
    String? description,
    double? maxScore,
    String? assignmentType,
    bool? isPublished,
  }) async {
    final response = await _tutorService.updateAssignment(
      assignmentId: assignmentId,
      title: title,
      description: description,
      maxScore: maxScore,
      assignmentType: assignmentType,
      isPublished: isPublished,
    );
    if (response.success && response.data != null) {
      final i = _assignments.indexWhere((a) => a.id == assignmentId);
      if (i != -1) _assignments[i] = response.data!;
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteAssignment(int assignmentId) async {
    final response = await _tutorService.deleteAssignment(assignmentId);
    if (response.success) {
      _assignments.removeWhere((a) => a.id == assignmentId);
      await loadDashboard();
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadAssignmentAttachment({
    required int assignmentId,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    final response = await _tutorService.uploadAssignmentAttachment(
      assignmentId: assignmentId,
      fileBytes: fileBytes,
      fileName: fileName,
      onProgress: (sent, total) {
        if (total > 0) {
          _uploadProgress = sent / total;
          notifyListeners();
        }
      },
    );

    _isUploading = false;
    _uploadProgress = 0.0;

    if (response.success && response.data != null) {
      final i = _assignments.indexWhere((a) => a.id == assignmentId);
      if (i != -1) _assignments[i] = response.data!;
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteAssignmentAttachment(int assignmentId) async {
    final response =
        await _tutorService.deleteAssignmentAttachment(assignmentId);
    if (response.success && response.data != null) {
      final i = _assignments.indexWhere((a) => a.id == assignmentId);
      if (i != -1) _assignments[i] = response.data!;
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  // ==================== GRADING ====================
  Future<void> loadSubmissions(int assignmentId) async {
    _currentSubmissions = [];
    notifyListeners();

    final response = await _tutorService.getAssignmentSubmissions(assignmentId);
    if (response.success) {
      _currentSubmissions = response.data ?? [];
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }

  Future<bool> gradeSubmission({
    required int submissionId,
    required double score,
    String? feedback,
  }) async {
    final response = await _tutorService.gradeSubmission(
      submissionId: submissionId,
      score: score,
      feedback: feedback,
    );

    if (response.success && response.data != null) {
      final index = _currentSubmissions.indexWhere((s) => s.id == submissionId);
      if (index != -1) _currentSubmissions[index] = response.data!;
      await loadDashboard();
      notifyListeners();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  // ==================== UTILS ====================
  Future<void> loadAll() async {
    await Future.wait([
      loadDashboard(),
      loadCourses(),
      loadAssignments(),
    ]);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _dashboardData = null;
    _courses = [];
    _currentModules = [];
    _currentMultimedia = [];
    _assignments = [];
    _currentSubmissions = [];
    _selectedCourse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
