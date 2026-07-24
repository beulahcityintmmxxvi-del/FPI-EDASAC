import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/network/dio_client.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class ProfileService {
  final Dio _dio = DioClient.instance.dio;
  final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery or camera
  Future<XFile?> pickImage({required bool fromCamera}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      return null;
    }
  }

  /// Upload Student/Admin Profile Picture
  Future<ApiResponse<UserModel>> uploadProfilePicture(XFile image) async {
    try {
      final file = File(image.path);
      final fileName = image.name;
      final ext = fileName.split('.').last.toLowerCase();

      String mediaType = 'image/jpeg';
      if (ext == 'png') mediaType = 'image/png';
      if (ext == 'webp') mediaType = 'image/webp';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: DioMediaType.parse(mediaType),
        ),
      });

      final response = await _dio.post(
        '/auth/profile/picture',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        // Update stored user data
        final userBox = Hive.box(AppConstants.userBox);
        await userBox.put(AppConstants.userKey, user.toJson());
        return ApiResponse.success(user, message: 'Profile picture updated');
      }

      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to upload profile picture.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('Failed to upload profile picture.');
    }
  }

  /// Upload Tutor Profile Picture
  Future<ApiResponse<UserModel>> uploadTutorProfilePicture(XFile image) async {
    try {
      final file = File(image.path);
      final fileName = image.name;
      final ext = fileName.split('.').last.toLowerCase();

      String mediaType = 'image/jpeg';
      if (ext == 'png') mediaType = 'image/png';
      if (ext == 'webp') mediaType = 'image/webp';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: DioMediaType.parse(mediaType),
        ),
      });

      final response = await _dio.post(
        '/tutor/profile/picture',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        // Update stored user data
        final userBox = Hive.box(AppConstants.userBox);
        await userBox.put(AppConstants.userKey, user.toJson());
        return ApiResponse.success(user, message: 'Profile picture updated');
      }

      final detail = response.data?['detail'];
      return ApiResponse.error(
        detail?.toString() ?? 'Failed to upload profile picture.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error('Failed to upload profile picture.');
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
