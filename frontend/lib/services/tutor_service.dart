import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/app_constants.dart';
import '../models/course_model.dart';
import '../models/module_model.dart';
import '../models/multimedia_model.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../models/vocation_model.dart';

class TutorService {
  final Dio _dio = DioClient.instance.dio;

  // ==================== DASHBOARD ====================
  Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    try {
      final response = await _dio.get(
        AppConstants.tutorDashboardEndpoint,
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(Map<String, dynamic>.from(response.data));
      }
      return ApiResponse.error('Failed to fetch dashboard.',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== VOCATIONS ====================
  Future<ApiResponse<List<VocationModel>>> getVocations() async {
    try {
      final response = await _dio.get(
        AppConstants.tutorVocationsEndpoint,
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(data
            .map((j) => VocationModel.fromJson(Map<String, dynamic>.from(j)))
            .toList());
      }
      return ApiResponse.error('Failed to fetch vocations.',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== COURSES ====================
  Future<ApiResponse<List<CourseModel>>> getMyCourses() async {
    try {
      final response = await _dio.get(
        AppConstants.tutorCoursesEndpoint,
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(data
            .map((j) => CourseModel.fromJson(Map<String, dynamic>.from(j)))
            .toList());
      }
      return ApiResponse.error('Failed to fetch courses.',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<CourseModel>> createCourse({
    required String title,
    required String description,
    required int vocationId,
    bool isPublished = false,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.tutorCoursesEndpoint,
        data: {
          'title': title,
          'description': description,
          'vocation_id': vocationId,
          'is_published': isPublished,
        },
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 201) {
        return ApiResponse.success(
          CourseModel.fromJson(Map<String, dynamic>.from(response.data)),
          message: 'Course created',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to create course.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<CourseModel>> updateCourse({
    required int courseId,
    String? title,
    String? description,
    int? vocationId,
    bool? isPublished,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (vocationId != null) data['vocation_id'] = vocationId;
      if (isPublished != null) data['is_published'] = isPublished;

      final response = await _dio.put(
        '${AppConstants.tutorCoursesEndpoint}/$courseId',
        data: data,
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(
          CourseModel.fromJson(Map<String, dynamic>.from(response.data)),
          message: 'Course updated',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to update course.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<void>> deleteCourse(int courseId) async {
    try {
      final response = await _dio.delete(
        '${AppConstants.tutorCoursesEndpoint}/$courseId',
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(null, message: 'Course deleted');
      }
      return ApiResponse.error('Failed to delete course.',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== MODULES ====================
  Future<ApiResponse<List<ModuleModel>>> getCourseModules(int courseId) async {
    try {
      final response = await _dio.get(
        '${AppConstants.tutorCoursesEndpoint}/$courseId/modules',
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(data
            .map((j) => ModuleModel.fromJson(Map<String, dynamic>.from(j)))
            .toList());
      }
      return ApiResponse.error('Failed to fetch modules.',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<ModuleModel>> createModule({
    required int courseId,
    required String title,
    String? description,
    int order = 0,
    int? durationMinutes,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.tutorModulesEndpoint,
        data: {
          'course_id': courseId,
          'title': title,
          'description': description,
          'order': order,
          'duration_minutes': durationMinutes,
          'is_published': true,
        },
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 201) {
        return ApiResponse.success(
          ModuleModel.fromJson(Map<String, dynamic>.from(response.data)),
          message: 'Module created',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to create module.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<ModuleModel>> updateModule({
    required int moduleId,
    String? title,
    String? description,
    int? order,
    int? durationMinutes,
    bool? isPublished,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (order != null) data['order'] = order;
      if (durationMinutes != null) data['duration_minutes'] = durationMinutes;
      if (isPublished != null) data['is_published'] = isPublished;

      final response = await _dio.put(
        '${AppConstants.tutorModulesEndpoint}/$moduleId',
        data: data,
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(
          ModuleModel.fromJson(Map<String, dynamic>.from(response.data)),
          message: 'Module updated',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to update module.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<void>> deleteModule(int moduleId) async {
    try {
      final response = await _dio.delete(
        '${AppConstants.tutorModulesEndpoint}/$moduleId',
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(null, message: 'Module deleted');
      }
      return ApiResponse.error('Failed to delete module.',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== MULTIMEDIA ====================
  Future<ApiResponse<List<MultimediaModel>>> getModuleMultimedia(
    int moduleId,
  ) async {
    try {
      final response = await _dio.get(
        '${AppConstants.tutorModulesEndpoint}/$moduleId/multimedia',
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(data
            .map((j) => MultimediaModel.fromJson(Map<String, dynamic>.from(j)))
            .toList());
      }
      return ApiResponse.error('Failed to fetch multimedia.',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<MultimediaModel>> uploadMultimedia({
    required int moduleId,
    required String title,
    String? description,
    required List<int> fileBytes,
    required String fileName,
    int order = 0,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final ext = fileName.split('.').last.toLowerCase();
      String mediaType = 'application/octet-stream';

      if (['mp4', 'avi', 'mov', 'mkv'].contains(ext)) {
        mediaType = 'video/$ext';
      } else if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
        mediaType = 'image/${ext == "jpg" ? "jpeg" : ext}';
      } else if (ext == 'pdf') {
        mediaType = 'application/pdf';
      } else if (['doc', 'docx'].contains(ext)) {
        mediaType = 'application/vnd.openxmlformats-officedocument'
            '.wordprocessingml.document';
      }

      final formData = FormData.fromMap({
        'title': title,
        'description': description ?? '',
        'order': order.toString(),
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: DioMediaType.parse(mediaType),
        ),
      });

      final response = await _dio.post(
        '${AppConstants.tutorModulesEndpoint}/$moduleId/upload',
        data: formData,
        onSendProgress: onProgress,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (s) => s != null && s < 500,
          sendTimeout: const Duration(minutes: 30),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(
          MultimediaModel.fromJson(Map<String, dynamic>.from(response.data)),
          message: 'File uploaded',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to upload file.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<void>> deleteMultimedia(int multimediaId) async {
    try {
      final response = await _dio.delete(
        '${AppConstants.tutorMultimediaEndpoint}/$multimediaId',
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(null, message: 'File deleted');
      }
      return ApiResponse.error('Failed to delete file.',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== ASSIGNMENTS ====================
  Future<ApiResponse<List<AssignmentModel>>> getMyAssignments({
    int? courseId,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.tutorAssignmentsEndpoint,
        queryParameters: courseId != null ? {'course_id': courseId} : null,
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(data
            .map((j) => AssignmentModel.fromJson(Map<String, dynamic>.from(j)))
            .toList());
      }
      return ApiResponse.error('Failed to fetch assignments.',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<AssignmentModel>> createAssignment({
    required int courseId,
    required String title,
    String? description,
    required double maxScore,
    String assignmentType = 'practical',
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.tutorAssignmentsEndpoint,
        data: {
          'course_id': courseId,
          'title': title,
          'description': description ?? '',
          'max_score': maxScore.toInt(),
          'assignment_type': assignmentType,
          'is_published': true,
        },
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 201) {
        return ApiResponse.success(
          AssignmentModel.fromJson(Map<String, dynamic>.from(response.data)),
          message: 'Assignment created',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to create assignment.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<AssignmentModel>> createAssignmentWithAttachment({
    required int courseId,
    required String title,
    required String description,
    required double maxScore,
    String assignmentType = 'practical',
    bool isPublished = true,
    List<int>? fileBytes,
    String? fileName,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formMap = <String, dynamic>{
        'course_id': courseId.toString(),
        'title': title,
        'description': description,
        'assignment_type': assignmentType,
        'max_score': maxScore.toInt().toString(),
        'is_published': isPublished.toString(),
      };

      if (fileBytes != null && fileName != null) {
        final ext = fileName.split('.').last.toLowerCase();
        String mediaType = 'application/octet-stream';
        if (['mp4', 'avi', 'mov', 'mkv'].contains(ext)) {
          mediaType = 'video/$ext';
        } else if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
          mediaType = 'image/${ext == "jpg" ? "jpeg" : ext}';
        } else if (ext == 'pdf') {
          mediaType = 'application/pdf';
        } else if (['doc', 'docx'].contains(ext)) {
          mediaType = 'application/vnd.openxmlformats-officedocument'
              '.wordprocessingml.document';
        }
        formMap['file'] = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: DioMediaType.parse(mediaType),
        );
      }

      final response = await _dio.post(
        '${AppConstants.tutorAssignmentsEndpoint}/with-attachment',
        data: FormData.fromMap(formMap),
        onSendProgress: onProgress,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 30),
          receiveTimeout: const Duration(minutes: 5),
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (response.statusCode == 201) {
        return ApiResponse.success(
          AssignmentModel.fromJson(Map<String, dynamic>.from(response.data)),
          message: 'Assignment created',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to create assignment.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<AssignmentModel>> updateAssignment({
    required int assignmentId,
    String? title,
    String? description,
    double? maxScore,
    String? assignmentType,
    bool? isPublished,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (maxScore != null) data['max_score'] = maxScore.toInt();
      if (assignmentType != null) data['assignment_type'] = assignmentType;
      if (isPublished != null) data['is_published'] = isPublished;

      final response = await _dio.put(
        '${AppConstants.tutorAssignmentsEndpoint}/$assignmentId',
        data: data,
        options: Options(validateStatus: (s) => s != null && s < 500),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          AssignmentModel.fromJson(Map<String, dynamic>.from(response.data)),
          message: 'Assignment updated',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to update assignment.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<void>> deleteAssignment(int assignmentId) async {
    try {
      final response = await _dio.delete(
        '${AppConstants.tutorAssignmentsEndpoint}/$assignmentId',
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(null, message: 'Assignment deleted');
      }
      return ApiResponse.error(
        'Failed to delete assignment.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<AssignmentModel>> uploadAssignmentAttachment({
    required int assignmentId,
    required List<int> fileBytes,
    required String fileName,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      final ext = fileName.split('.').last.toLowerCase();
      String mediaType = 'application/octet-stream';
      if (['mp4', 'avi', 'mov', 'mkv'].contains(ext)) {
        mediaType = 'video/$ext';
      } else if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
        mediaType = 'image/${ext == "jpg" ? "jpeg" : ext}';
      } else if (ext == 'pdf') {
        mediaType = 'application/pdf';
      } else if (['doc', 'docx'].contains(ext)) {
        mediaType = 'application/vnd.openxmlformats-officedocument'
            '.wordprocessingml.document';
      }

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: DioMediaType.parse(mediaType),
        ),
      });

      final response = await _dio.post(
        '${AppConstants.tutorAssignmentsEndpoint}/$assignmentId/attachment',
        data: formData,
        onSendProgress: onProgress,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 30),
          receiveTimeout: const Duration(minutes: 5),
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          AssignmentModel.fromJson(Map<String, dynamic>.from(response.data)),
          message: 'Attachment uploaded',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to upload attachment.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<AssignmentModel>> deleteAssignmentAttachment(
    int assignmentId,
  ) async {
    try {
      final response = await _dio.delete(
        '${AppConstants.tutorAssignmentsEndpoint}/$assignmentId/attachment',
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(
          AssignmentModel.fromJson(Map<String, dynamic>.from(response.data)),
          message: 'Attachment removed',
        );
      }
      return ApiResponse.error(
        'Failed to remove attachment.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== STUDENT ASSESSMENT ====================
  Future<ApiResponse<List<SubmissionModel>>> getAssignmentSubmissions(
    int assignmentId,
  ) async {
    try {
      final response = await _dio.get(
        '${AppConstants.tutorAssignmentsEndpoint}/$assignmentId/submissions',
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(data
            .map((j) => SubmissionModel.fromJson(Map<String, dynamic>.from(j)))
            .toList());
      }
      return ApiResponse.error('Failed to fetch submissions.',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getCourseStudents(
    int courseId,
  ) async {
    try {
      final response = await _dio.get(
        '${AppConstants.tutorCoursesEndpoint}/$courseId/students',
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(
          data.map((i) => Map<String, dynamic>.from(i)).toList(),
        );
      }
      return ApiResponse.error('Failed to fetch students.',
          statusCode: response.statusCode);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<SubmissionModel>> gradeSubmission({
    required int submissionId,
    required double score,
    String? feedback,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConstants.tutorSubmissionsEndpoint}/$submissionId/grade',
        data: {
          'score': score.toInt(),
          'feedback': feedback ?? '',
        },
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(
          SubmissionModel.fromJson(Map<String, dynamic>.from(response.data)),
          message: 'Submission graded',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to grade submission.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== ERROR HANDLER ====================
  ApiResponse<T> _handleError<T>(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return ApiResponse.error(
        'Cannot reach the server. Ensure the backend is running '
        'at ${AppConstants.baseUrl} and CORS is configured.',
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiResponse.error('Connection timed out. Please try again.');
    }
    final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
    return ApiResponse.error(
      detail?.toString() ?? 'Network error occurred.',
      statusCode: e.response?.statusCode,
    );
  }
}
