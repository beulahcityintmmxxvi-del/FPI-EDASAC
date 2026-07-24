import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/network/dio_client.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = DioClient.instance.dio;
  final Box _userBox = Hive.box(AppConstants.userBox);

  /// Login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
        options: Options(
          contentType: 'application/json',
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('Login status: ${response.statusCode}');
      print('Login data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data == null || data['access_token'] == null) {
          return ApiResponse.error('Invalid response from server');
        }

        final token = data['access_token'].toString();
        final role = data['role']?.toString() ?? '';

        // Store token FIRST before any subsequent calls
        await _userBox.put(AppConstants.tokenKey, token);
        await _userBox.put(AppConstants.userRoleKey, role);

        // Fetch user profile - pass token explicitly since
        // the interceptor reads from Hive which we just updated
        final userProfile = await _getCurrentUserWithToken(token);

        if (userProfile.success && userProfile.data != null) {
          await _userBox.put(
            AppConstants.userKey,
            userProfile.data!.toJson(),
          );
        } else {
          print(
              'Warning: Could not fetch user profile: ${userProfile.message}');
          // Login still succeeded even if profile fetch fails
        }

        return ApiResponse.success(
          Map<String, dynamic>.from(data),
          message: 'Login successful',
        );
      } else if (response.statusCode == 401) {
        final detail = response.data?['detail'];
        return ApiResponse.error(
          detail?.toString() ?? 'Invalid credentials. Please try again.',
          statusCode: 401,
        );
      } else if (response.statusCode == 400) {
        final detail = response.data?['detail'];
        return ApiResponse.error(
          detail?.toString() ?? 'Bad request. Please check your input.',
          statusCode: 400,
        );
      } else if (response.statusCode == 403) {
        final detail = response.data?['detail'];
        return ApiResponse.error(
          detail?.toString() ??
              'Account not approved or inactive. Contact admin.',
          statusCode: 403,
        );
      } else if (response.statusCode == 422) {
        final errorMsg = _parseValidationError(response.data);
        return ApiResponse.error(errorMsg, statusCode: 422);
      } else {
        return ApiResponse.error(
          'Login failed (${response.statusCode}). Please try again.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('DioException during login: ${e.type} - ${e.message}');
      print('Response: ${e.response?.data}');
      return _handleDioError(e);
    } catch (e) {
      print('Unexpected login error: $e');
      return ApiResponse.error(
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Get current user with explicit token (used right after login)
  Future<ApiResponse<UserModel>> _getCurrentUserWithToken(String token) async {
    try {
      final response = await _dio.get(
        AppConstants.meEndpoint,
        options: Options(
          // Explicitly pass token - do not rely on interceptor
          // since Hive write may not be visible to interceptor yet
          headers: {
            'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('GetMe status: ${response.statusCode}');
      print('GetMe data: ${response.data}');

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        return ApiResponse.success(user);
      } else {
        return ApiResponse.error(
          'Failed to fetch user profile (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Failed to fetch user profile.');
    }
  }

  /// Get Current User Profile (public - uses interceptor token)
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _dio.get(
        AppConstants.meEndpoint,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        return ApiResponse.success(user);
      } else if (response.statusCode == 401) {
        return ApiResponse.error(
          'Session expired. Please login again.',
          statusCode: 401,
        );
      } else {
        return ApiResponse.error(
          'Failed to fetch user profile.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Register Student
  Future<ApiResponse<UserModel>> registerStudent({
    required String matricNumber,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required int departmentId,
    required String academicLevel,
    required int vocationId,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.registerStudentEndpoint,
        data: {
          'matric_number': matricNumber,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'department_id': departmentId,
          'academic_level': academicLevel,
          'vocation_id': vocationId,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('Register student status: ${response.statusCode}');
      print('Register student data: ${response.data}');

      if (response.statusCode == 201) {
        final user = UserModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        return ApiResponse.success(
          user,
          message: 'Registration successful',
        );
      } else if (response.statusCode == 400) {
        final detail = response.data?['detail'];
        return ApiResponse.error(
          detail?.toString() ?? 'Registration failed. Check your details.',
          statusCode: 400,
        );
      } else if (response.statusCode == 409) {
        return ApiResponse.error(
          'Matric number already registered.',
          statusCode: 409,
        );
      } else if (response.statusCode == 422) {
        return ApiResponse.error(
          _parseValidationError(response.data),
          statusCode: 422,
        );
      } else {
        return ApiResponse.error(
          'Registration failed. Please try again.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Register Tutor
  Future<ApiResponse<UserModel>> registerTutor({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String specialization,
    required String bio,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.registerTutorEndpoint,
        data: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'specialization': specialization,
          'bio': bio,
          'password': password,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('Register tutor status: ${response.statusCode}');
      print('Register tutor data: ${response.data}');

      if (response.statusCode == 201) {
        final user = UserModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        return ApiResponse.success(
          user,
          message: 'Registration successful - Pending approval',
        );
      } else if (response.statusCode == 400) {
        final detail = response.data?['detail'];
        return ApiResponse.error(
          detail?.toString() ?? 'Registration failed. Check your details.',
          statusCode: 400,
        );
      } else if (response.statusCode == 409) {
        return ApiResponse.error(
          'Email already registered.',
          statusCode: 409,
        );
      } else if (response.statusCode == 422) {
        return ApiResponse.error(
          _parseValidationError(response.data),
          statusCode: 422,
        );
      } else {
        return ApiResponse.error(
          'Registration failed. Please try again.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Change Password
  Future<ApiResponse<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.changePasswordEndpoint,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          null,
          message: 'Password changed successfully',
        );
      } else if (response.statusCode == 400) {
        final detail = response.data?['detail'];
        return ApiResponse.error(
          detail?.toString() ?? 'Current password is incorrect.',
          statusCode: 400,
        );
      } else if (response.statusCode == 422) {
        return ApiResponse.error(
          _parseValidationError(response.data),
          statusCode: 422,
        );
      } else {
        return ApiResponse.error(
          'Password change failed. Please try again.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _userBox.clear();
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _userBox.get(AppConstants.tokenKey) != null;
  }

  /// Get stored user from Hive
  UserModel? getStoredUser() {
    final userData = _userBox.get(AppConstants.userKey);
    if (userData != null) {
      try {
        return UserModel.fromJson(
          Map<String, dynamic>.from(userData),
        );
      } catch (e) {
        print('Error parsing stored user: $e');
        return null;
      }
    }
    return null;
  }

  /// Handle Dio Errors
  ApiResponse<T> _handleDioError<T>(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Connection timed out. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Request timed out. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Server took too long to respond. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final detail = data is Map ? data['detail'] : null;

        if (statusCode == 401) {
          errorMessage =
              detail?.toString() ?? 'Invalid credentials. Please try again.';
        } else if (statusCode == 400) {
          errorMessage = detail?.toString() ?? 'Bad request. Check your input.';
        } else if (statusCode == 403) {
          errorMessage =
              detail?.toString() ?? 'Account not approved or inactive.';
        } else if (statusCode == 404) {
          errorMessage = 'Resource not found.';
        } else if (statusCode == 422) {
          errorMessage = _parseValidationError(data);
        } else if (statusCode != null && statusCode >= 500) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          errorMessage =
              detail?.toString() ?? 'An error occurred. Please try again.';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection. Please check your network.';
        break;
      case DioExceptionType.unknown:
      default:
        if (e.message?.contains('SocketException') ?? false) {
          errorMessage = 'No internet connection. Please check your network.';
        } else if (e.message?.contains('HandshakeException') ?? false) {
          errorMessage = 'Secure connection failed. Please try again.';
        } else {
          errorMessage = 'Network error. Please try again.';
        }
        break;
    }

    return ApiResponse.error(
      errorMessage,
      statusCode: e.response?.statusCode,
    );
  }

  /// Parse FastAPI 422 Validation Errors
  String _parseValidationError(dynamic data) {
    try {
      if (data is Map && data['detail'] is List) {
        final errors = data['detail'] as List;
        if (errors.isNotEmpty) {
          final firstError = errors.first;
          final field = (firstError['loc'] as List?)?.last?.toString() ?? '';
          final msg = firstError['msg']?.toString() ?? '';
          return field.isNotEmpty ? '$field: $msg' : msg;
        }
      } else if (data is Map && data['detail'] is String) {
        return data['detail'];
      }
    } catch (_) {}
    return 'Validation error. Please check your input.';
  }
}
