import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/app_constants.dart';
import '../models/course_model.dart';
import '../models/module_model.dart';
import '../models/multimedia_model.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../models/department_model.dart';
import '../models/vocation_model.dart';
import '../models/enrollment_model.dart';

class StudentService {
  final Dio _dio = DioClient.instance.dio;

  // ==================== METADATA ====================

  Future<ApiResponse<List<DepartmentModel>>> getDepartments() async {
    try {
      final response = await _dio.get(
        AppConstants.studentDepartmentsEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(
          data
              .map((json) =>
                  DepartmentModel.fromJson(Map<String, dynamic>.from(json)))
              .toList(),
        );
      }
      return ApiResponse.error(
        'Failed to fetch departments.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<List<VocationModel>>> getVocations() async {
    try {
      final response = await _dio.get(
        AppConstants.studentVocationsEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(
          data
              .map((json) =>
                  VocationModel.fromJson(Map<String, dynamic>.from(json)))
              .toList(),
        );
      }
      return ApiResponse.error(
        'Failed to fetch vocations.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== VOCATION ENROLLMENT ====================

  Future<ApiResponse<VocationEnrollmentResult>> enrollInVocation(
    int vocationId,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.studentVocationEnrollEndpoint,
        data: {'vocation_id': vocationId},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        final result = VocationEnrollmentResult.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        return ApiResponse.success(result, message: result.message);
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to enroll in vocation.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> syncVocationCourses() async {
    try {
      final response = await _dio.post(
        AppConstants.studentVocationSyncEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(
          Map<String, dynamic>.from(response.data),
        );
      }
      return ApiResponse.error(
        'Failed to sync vocation courses.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== DASHBOARD ====================

  Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    try {
      final response = await _dio.get(
        AppConstants.studentDashboardEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(
          Map<String, dynamic>.from(response.data),
        );
      }
      return ApiResponse.error(
        'Failed to fetch dashboard.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== COURSES ====================

  Future<ApiResponse<List<CourseModel>>> getAvailableCourses() async {
    try {
      final response = await _dio.get(
        AppConstants.studentCoursesAvailableEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(
          data
              .map((json) =>
                  CourseModel.fromJson(Map<String, dynamic>.from(json)))
              .toList(),
        );
      }
      return ApiResponse.error(
        'Failed to fetch courses.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<List<CourseModel>>> getEnrolledCourses() async {
    try {
      final response = await _dio.get(
        AppConstants.studentCoursesEnrolledEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(
          data
              .map((json) =>
                  CourseModel.fromJson(Map<String, dynamic>.from(json)))
              .toList(),
        );
      }
      return ApiResponse.error(
        'Failed to fetch enrolled courses.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<void>> enrollInCourse(int courseId) async {
    try {
      final response = await _dio.post(
        '/student/courses/$courseId/enroll',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        return ApiResponse.success(null, message: 'Enrolled successfully');
      } else if (response.statusCode == 400) {
        final detail = response.data?['detail'];
        return ApiResponse.error(
          detail?.toString() ?? 'Already enrolled in this course.',
          statusCode: 400,
        );
      }
      return ApiResponse.error(
        'Failed to enroll.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== MODULES ====================

  Future<ApiResponse<List<ModuleModel>>> getCourseModules(
    int courseId,
  ) async {
    try {
      final response = await _dio.get(
        '/student/courses/$courseId/modules',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(
          data
              .map((json) =>
                  ModuleModel.fromJson(Map<String, dynamic>.from(json)))
              .toList(),
        );
      } else if (response.statusCode == 403) {
        return ApiResponse.error(
          'You are not enrolled in this course.',
          statusCode: 403,
        );
      }
      return ApiResponse.error(
        'Failed to fetch modules.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== MULTIMEDIA ====================

  Future<ApiResponse<List<MultimediaModel>>> getModuleMultimedia(
    int moduleId,
  ) async {
    try {
      final response = await _dio.get(
        '/student/modules/$moduleId/multimedia',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(
          data
              .map((json) =>
                  MultimediaModel.fromJson(Map<String, dynamic>.from(json)))
              .toList(),
        );
      } else if (response.statusCode == 403) {
        return ApiResponse.error(
          'You are not enrolled in this course.',
          statusCode: 403,
        );
      }
      return ApiResponse.error(
        'Failed to fetch content.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== ASSIGNMENTS ====================

  Future<ApiResponse<List<AssignmentModel>>> getAssignments() async {
    try {
      final response = await _dio.get(
        AppConstants.studentAssignmentsEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(
          data
              .map((json) =>
                  AssignmentModel.fromJson(Map<String, dynamic>.from(json)))
              .toList(),
        );
      }
      return ApiResponse.error(
        'Failed to fetch assignments.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== SUBMISSIONS ====================

  Future<ApiResponse<List<SubmissionModel>>> getMySubmissions() async {
    try {
      final response = await _dio.get(
        AppConstants.studentSubmissionsEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(
          data
              .map((json) =>
                  SubmissionModel.fromJson(Map<String, dynamic>.from(json)))
              .toList(),
        );
      }
      return ApiResponse.error(
        'Failed to fetch submissions.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<SubmissionModel>> submitAssignment({
    required int assignmentId,
    String? submissionText,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    try {
      dynamic data;
      Options options;

      if (fileBytes != null && fileName != null) {
        final ext = fileName.split('.').last.toLowerCase();
        String mediaType = 'application/octet-stream';
        if (ext == 'pdf') mediaType = 'application/pdf';
        if (['jpg', 'jpeg'].contains(ext)) mediaType = 'image/jpeg';
        if (ext == 'png') mediaType = 'image/png';
        if (['doc', 'docx'].contains(ext)) {
          mediaType = 'application/vnd.openxmlformats-officedocument'
              '.wordprocessingml.document';
        }

        final formMap = <String, dynamic>{
          'file': MultipartFile.fromBytes(
            fileBytes,
            filename: fileName,
            contentType: DioMediaType.parse(mediaType),
          ),
        };

        if (submissionText != null && submissionText.isNotEmpty) {
          formMap['submission_text'] = submissionText;
        }

        data = FormData.fromMap(formMap);
        options = Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => status != null && status < 500,
        );
      } else {
        data = FormData.fromMap({
          'submission_text': submissionText ?? '',
        });
        options = Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => status != null && status < 500,
        );
      }

      final response = await _dio.post(
        '${AppConstants.studentAssignmentsEndpoint}/$assignmentId/submit',
        data: data,
        options: options,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final submission = SubmissionModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        return ApiResponse.success(
          submission,
          message: 'Assignment submitted successfully',
        );
      } else if (response.statusCode == 400) {
        final detail = response.data?['detail'];
        return ApiResponse.error(
          detail?.toString() ?? 'Submission failed.',
          statusCode: 400,
        );
      }

      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Submission failed.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Alias for submitAssignment. Backend upserts existing submissions
  /// unless they've been graded.
  Future<ApiResponse<SubmissionModel>> updateSubmission({
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

  // ==================== REVIEWS ====================

  Future<ApiResponse<List<Map<String, dynamic>>>> getMyReviews() async {
    try {
      final response = await _dio.get(
        AppConstants.studentReviewsEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return ApiResponse.success(
          data.map((item) => Map<String, dynamic>.from(item)).toList(),
        );
      }
      return ApiResponse.error(
        'Failed to fetch reviews.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<SubmissionModel>> getSubmissionReview(
    int submissionId,
  ) async {
    try {
      final response = await _dio.get(
        '/student/submissions/$submissionId/review',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      if (response.statusCode == 200) {
        final submission = SubmissionModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        return ApiResponse.success(submission);
      }
      return ApiResponse.error(
        'Failed to fetch review.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== ERROR HANDLER ====================

  ApiResponse<T> _handleError<T>(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return ApiResponse.error('No internet connection.');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiResponse.error('Connection timed out. Please try again.');
    }
    final detail = e.response?.data is Map ? e.response?.data['detail'] : null;
    return ApiResponse.error(
      detail?.toString() ?? 'Network error occurred.',
      statusCode: e.response?.statusCode,
    );
  }
}
