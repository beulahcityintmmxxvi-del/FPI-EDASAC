import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/module_model.dart';
import '../../models/multimedia_model.dart';
import '../../services/student_service.dart';
import '../../services/media_download_service.dart';
import 'student_video_player_screen.dart';

class StudentModuleDetailScreen extends StatefulWidget {
  final ModuleModel module;

  const StudentModuleDetailScreen({
    super.key,
    required this.module,
  });

  @override
  State<StudentModuleDetailScreen> createState() =>
      _StudentModuleDetailScreenState();
}

class _StudentModuleDetailScreenState extends State<StudentModuleDetailScreen> {
  final StudentService _studentService = StudentService();
  final MediaDownloadService _downloadService = MediaDownloadService();

  List<MultimediaModel> _multimedia = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Track per-item download state
  // key = multimedia id, value = progress 0.0–1.0 or -1.0 if done
  final Map<int, double> _downloadProgress = {};
  final Map<int, bool> _downloadedFiles = {};

  @override
  void initState() {
    super.initState();
    _loadMultimedia();
  }

  Future<void> _loadMultimedia() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response =
        await _studentService.getModuleMultimedia(widget.module.id);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success) {
          _multimedia = response.data ?? [];
        } else {
          _errorMessage = response.message;
        }
      });

      // Check which files are already downloaded
      for (final media in _multimedia) {
        if (_isReadingMaterial(media)) {
          final alreadyDownloaded =
              await _downloadService.isFileDownloaded(media.fileName);
          if (mounted) {
            setState(() {
              _downloadedFiles[media.id] = alreadyDownloaded;
            });
          }
        }
      }
    }
  }

  /// Reading materials = PDF, DOC, DOCX, images (non-video)
  bool _isReadingMaterial(MultimediaModel media) {
    return !media.isVideo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.module.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: _loadMultimedia,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModuleHeader(),
              const SizedBox(height: 20),
              _buildContentSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${widget.module.order}',
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.module.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (widget.module.description != null &&
                    widget.module.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.module.description!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (widget.module.durationMinutes != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.module.durationMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadMultimedia,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_multimedia.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'No content available yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    // Separate videos and reading materials
    final videos = _multimedia.where((m) => m.isVideo).toList();
    final readingMaterials = _multimedia.where((m) => !m.isVideo).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Video Tutorials Section ──────────────────────
        if (videos.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            icon: Icons.play_circle_rounded,
            title: 'Video Tutorials',
            color: AppColors.blue,
            count: videos.length,
          ),
          const SizedBox(height: 10),
          // Online streaming notice
          _buildNoticeBar(
            icon: Icons.stream_rounded,
            message: 'Videos stream online. Internet connection required.',
            color: AppColors.blue,
          ),
          const SizedBox(height: 12),
          ...videos.map(
            (media) => _buildVideoCard(media),
          ),
          const SizedBox(height: 20),
        ],

        // ── Reading Materials Section ────────────────────
        if (readingMaterials.isNotEmpty) ...[
          _buildSectionHeader(
            context,
            icon: Icons.menu_book_rounded,
            title: 'Reading Materials',
            color: AppColors.primaryGreen,
            count: readingMaterials.length,
          ),
          const SizedBox(height: 10),
          // Download notice
          _buildNoticeBar(
            icon: Icons.download_rounded,
            message: 'Download files to read offline on your device.',
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: 12),
          ...readingMaterials.map(
            (media) => _buildReadingMaterialCard(media),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoticeBar({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // ── VIDEO CARD — tap to stream online ─────────────────────

  Widget _buildVideoCard(MultimediaModel media) {
    return GestureDetector(
      onTap: () => _openVideoPlayer(media),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(
            color: AppColors.blue.withOpacity(0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Thumbnail area
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.charcoal,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.defaultRadius),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Play icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.white,
                      size: 36,
                    ),
                  ),
                  // Duration badge
                  if (media.durationSeconds != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(media.durationSeconds!),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  // Stream badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stream_rounded,
                            color: AppColors.white,
                            size: 10,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'STREAM',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.play_circle_rounded,
                      color: AppColors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          media.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (media.fileSize != null)
                          Text(
                            '${media.fileSizeMb.toStringAsFixed(1)} MB',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── READING MATERIAL CARD — tap to download ────────────────

  Widget _buildReadingMaterialCard(MultimediaModel media) {
    final isDownloading = _downloadProgress.containsKey(media.id);
    final progress = _downloadProgress[media.id] ?? 0.0;
    final isDownloaded = _downloadedFiles[media.id] ?? false;

    IconData icon;
    Color color;
    String typeLabel;

    if (media.isPdf) {
      icon = Icons.picture_as_pdf_rounded;
      color = AppColors.red;
      typeLabel = 'PDF';
    } else if (media.isImage) {
      icon = Icons.image_rounded;
      color = AppColors.primaryGreen;
      typeLabel = 'Image';
    } else {
      icon = Icons.description_rounded;
      color = AppColors.blue;
      typeLabel = 'Document';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(
          color: isDownloaded
              ? AppColors.success.withOpacity(0.3)
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      media.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (media.fileSize != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${media.fileSizeMb.toStringAsFixed(1)} MB',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Action Button ──────────────────────────
              const SizedBox(width: 8),
              _buildActionButton(
                media: media,
                isDownloading: isDownloading,
                isDownloaded: isDownloaded,
                color: color,
              ),
            ],
          ),

          // ── Download Progress Bar ──────────────────────
          if (isDownloading) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Downloading...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGreen,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],

          // ── Downloaded — open file button ──────────────
          if (isDownloaded && !isDownloading) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openDownloadedFile(media),
                icon: const Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                ),
                label: const Text('Open File'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(
                    color: AppColors.primaryGreen,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required MultimediaModel media,
    required bool isDownloading,
    required bool isDownloaded,
    required Color color,
  }) {
    if (isDownloading) {
      // Show spinner while downloading
      return const SizedBox(
        width: 36,
        height: 36,
        child: CircularProgressIndicator(
          color: AppColors.primaryGreen,
          strokeWidth: 2.5,
        ),
      );
    }

    if (isDownloaded) {
      // Show checkmark — already downloaded
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 22,
        ),
      );
    }

    // Show download button
    return GestureDetector(
      onTap: () => _startDownload(media),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.download_rounded,
          color: AppColors.primaryGreen,
          size: 22,
        ),
      ),
    );
  }

  // ── ACTIONS ────────────────────────────────────────────────

  void _openVideoPlayer(MultimediaModel media) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudentVideoPlayerScreen(media: media),
      ),
    );
  }

  Future<void> _startDownload(MultimediaModel media) async {
    // Prevent duplicate downloads
    if (_downloadProgress.containsKey(media.id)) return;

    setState(() {
      _downloadProgress[media.id] = 0.0;
    });

    final result = await _downloadService.downloadReadingMaterial(
      multimediaId: media.id,
      fileName: media.fileName,
      context: context,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress[media.id] = progress;
          });
        }
      },
    );

    if (!mounted) return;

    // Remove progress tracker
    setState(() {
      _downloadProgress.remove(media.id);
    });

    if (result.success) {
      setState(() {
        _downloadedFiles[media.id] = true;
      });

      final message = result.alreadyExisted
          ? '"${media.title}" already downloaded.'
          : '"${media.title}" downloaded successfully!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.download_done_rounded,
                color: AppColors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          action: SnackBarAction(
            label: 'Open',
            textColor: AppColors.white,
            onPressed: () => _openDownloadedFile(media),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.errorMessage ?? 'Download failed.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _openDownloadedFile(MultimediaModel media) async {
    final path = await _downloadService.getLocalFilePath(media.fileName);

    if (path == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'File not found. Please download it again.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final opened = await _downloadService.openFile(path);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the file. '
            'Please install a compatible app to open this file type.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m}m ${s}s';
  }
}
