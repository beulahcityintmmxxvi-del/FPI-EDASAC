import 'dart:io' show Directory, File, Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_constants.dart';
import '../core/network/dio_client.dart';

class MediaDownloadService {
  final Dio _dio = DioClient.instance.dio;

  String? _getToken() {
    try {
      final box = Hive.box(AppConstants.userBox);
      return box.get(AppConstants.tokenKey) as String?;
    } catch (_) {
      return null;
    }
  }

  /// Build a signed stream URL for use in <video> / VideoPlayerController.
  /// CRITICAL: must use apiUrl (which includes /api), not baseUrl.
  String buildStreamUrl(int multimediaId) {
    final base = '${AppConstants.apiUrl}'
        '${AppConstants.mediaStreamEndpoint}/$multimediaId';
    final token = _getToken();
    if (token == null || token.isEmpty) return base;
    return '$base?token=${Uri.encodeQueryComponent(token)}';
  }

  /// Build a signed download URL for the browser to open in a new tab.
  String buildDownloadUrl(int multimediaId) {
    final base = '${AppConstants.apiUrl}'
        '${AppConstants.mediaDownloadEndpoint}/$multimediaId';
    final token = _getToken();
    if (token == null || token.isEmpty) return base;
    return '$base?token=${Uri.encodeQueryComponent(token)}';
  }

  Future<DownloadResult> downloadReadingMaterial({
    required int multimediaId,
    required String fileName,
    required BuildContext context,
    void Function(double progress)? onProgress,
  }) async {
    if (kIsWeb) {
      final url = Uri.parse(buildDownloadUrl(multimediaId));
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      return launched
          ? DownloadResult.success(
              filePath: url.toString(),
              fileName: fileName,
              openedInBrowser: true,
            )
          : DownloadResult.error('Could not open the file in your browser.');
    }

    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          return DownloadResult.error(
            'Storage permission denied. Enable it in Settings.',
          );
        }
      }

      final directory = await _getDownloadDirectory();
      if (directory == null) {
        return DownloadResult.error('Could not access download folder.');
      }
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final savePath = '${directory.path}/$fileName';
      final saveFile = File(savePath);
      if (await saveFile.exists()) {
        return DownloadResult.success(
          filePath: savePath,
          fileName: fileName,
          alreadyExisted: true,
        );
      }

      // Dio uses apiUrl as its baseUrl, so the relative path is correct here.
      await _dio.download(
        '${AppConstants.mediaDownloadEndpoint}/$multimediaId',
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 10),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      return DownloadResult.success(filePath: savePath, fileName: fileName);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return DownloadResult.error(
          'No internet connection. Please check your network.',
        );
      }
      return DownloadResult.error(
        'Download failed: ${e.message ?? "Unknown error"}',
      );
    } catch (_) {
      return DownloadResult.error(
        'An unexpected error occurred during download.',
      );
    }
  }

  Future<bool> openFile(String filePath) async {
    if (kIsWeb) return false;
    try {
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) return await launchUrl(uri);
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (kIsWeb) return null;
    try {
      if (Platform.isAndroid) {
        return Directory('/storage/emulated/0/Download/EDASAC');
      } else if (Platform.isIOS) {
        final docs = await getApplicationDocumentsDirectory();
        return Directory('${docs.path}/EDASAC');
      }
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return null;
    }
  }

  Future<bool> isFileDownloaded(String fileName) async {
    if (kIsWeb) return false;
    final dir = await _getDownloadDirectory();
    if (dir == null) return false;
    return File('${dir.path}/$fileName').exists();
  }

  Future<String?> getLocalFilePath(String fileName) async {
    if (kIsWeb) return null;
    final dir = await _getDownloadDirectory();
    if (dir == null) return null;
    final path = '${dir.path}/$fileName';
    if (await File(path).exists()) return path;
    return null;
  }
}

class DownloadResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final String? errorMessage;
  final bool alreadyExisted;
  final bool openedInBrowser;

  const DownloadResult._({
    required this.success,
    this.filePath,
    this.fileName,
    this.errorMessage,
    this.alreadyExisted = false,
    this.openedInBrowser = false,
  });

  factory DownloadResult.success({
    required String filePath,
    required String fileName,
    bool alreadyExisted = false,
    bool openedInBrowser = false,
  }) =>
      DownloadResult._(
        success: true,
        filePath: filePath,
        fileName: fileName,
        alreadyExisted: alreadyExisted,
        openedInBrowser: openedInBrowser,
      );

  factory DownloadResult.error(String message) =>
      DownloadResult._(success: false, errorMessage: message);
}
