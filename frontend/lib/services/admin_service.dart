import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AdminService {
  final Dio _dio = DioClient.instance.dio;

  // ==================== DASHBOARD ====================

  Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    try {
      final response = await _dio.get(
        AppConstants.adminDashboardEndpoint,
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

  // ==================== USERS ====================

  Future<ApiResponse<List<UserModel>>> getAllStudents() async {
    try {
      final response = await _dio.get(
        AppConstants.adminStudentsEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final users = data
            .map((json) => UserModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        return ApiResponse.success(users);
      }
      return ApiResponse.error(
        'Failed to fetch students.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<List<UserModel>>> getAllUsers({
    String? role,
    bool? isActive,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (role != null && role != 'all') queryParams['role'] = role;
      if (isActive != null) queryParams['is_active'] = isActive;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        AppConstants.adminUsersEndpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final users = data
            .map((json) => UserModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        return ApiResponse.success(users);
      }
      return ApiResponse.error(
        'Failed to fetch users.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<List<UserModel>>> getPendingTutors() async {
    try {
      final response = await _dio.get(
        AppConstants.adminPendingTutorsEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final users = data
            .map((json) => UserModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
        return ApiResponse.success(users);
      }
      return ApiResponse.error(
        'Failed to fetch pending tutors.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<void>> approveTutor(int tutorId) async {
    try {
      final response = await _dio.post(
        '/admin/users/tutors/$tutorId/approve',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null, message: 'Tutor approved');
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to approve tutor.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<void>> rejectTutor(int tutorId) async {
    try {
      final response = await _dio.post(
        '/admin/users/tutors/$tutorId/reject',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null, message: 'Tutor rejected');
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to reject tutor.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Activate a deactivated user account
  Future<ApiResponse<Map<String, dynamic>>> activateUser(int userId) async {
    try {
      final response = await _dio.post(
        '/admin/users/$userId/activate',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          Map<String, dynamic>.from(response.data),
          message: 'User activated successfully',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to activate user.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Deactivate an active user account
  Future<ApiResponse<Map<String, dynamic>>> deactivateUser(int userId) async {
    try {
      final response = await _dio.post(
        '/admin/users/$userId/deactivate',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          Map<String, dynamic>.from(response.data),
          message: 'User deactivated successfully',
        );
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to deactivate user.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Toggle user active status (activate if inactive, deactivate if active)
  Future<ApiResponse<void>> toggleUserActive(int userId) async {
    try {
      final response = await _dio.post(
        '/admin/users/$userId/toggle-active',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      }
      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to update user status.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== SYSTEM ACTIVITY ====================

  Future<ApiResponse<List<Map<String, dynamic>>>> getAllSubmissions({
    String? statusFilter,
  }) async {
    try {
      final response = await _dio.get(
        AppConstants.adminSubmissionsEndpoint,
        queryParameters:
            statusFilter != null ? {'status_filter': statusFilter} : null,
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
        'Failed to fetch submissions.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getAllEnrollments() async {
    try {
      final response = await _dio.get(
        AppConstants.adminEnrollmentsEndpoint,
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
        'Failed to fetch enrollments.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getAllCourses({
    bool? isPublished,
    int? vocationId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (isPublished != null) queryParams['is_published'] = isPublished;
      if (vocationId != null) queryParams['vocation_id'] = vocationId;

      final response = await _dio.get(
        AppConstants.adminAllCoursesEndpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
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
        'Failed to fetch courses.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  // ==================== ANALYTICS ====================

  Future<ApiResponse<List<Map<String, dynamic>>>>
      getEnrollmentByVocation() async {
    try {
      final response = await _dio.get(
        '/admin/analytics/enrollment-by-vocation',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final result =
            data.map((item) => Map<String, dynamic>.from(item)).toList();
        return ApiResponse.success(result);
      }
      return ApiResponse.error(
        'Failed to fetch analytics.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>>
      getEnrollmentByDepartment() async {
    try {
      final response = await _dio.get(
        '/admin/analytics/enrollment-by-department',
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final result =
            data.map((item) => Map<String, dynamic>.from(item)).toList();
        return ApiResponse.success(result);
      }
      return ApiResponse.error(
        'Failed to fetch analytics.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

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
