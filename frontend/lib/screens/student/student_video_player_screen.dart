import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../core/theme/app_colors.dart';
import '../../models/multimedia_model.dart';
import '../../services/media_download_service.dart';

class StudentVideoPlayerScreen extends StatefulWidget {
  final MultimediaModel media;

  const StudentVideoPlayerScreen({super.key, required this.media});

  @override
  State<StudentVideoPlayerScreen> createState() =>
      _StudentVideoPlayerScreenState();
}

class _StudentVideoPlayerScreenState extends State<StudentVideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final service = MediaDownloadService();
      final streamUrl = service.buildStreamUrl(widget.media.id);

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(streamUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
      );

      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryGreen,
          handleColor: AppColors.primaryGreenLight,
          backgroundColor: AppColors.borderLight,
          bufferedColor: AppColors.primaryGreen.withOpacity(0.3),
        ),
        placeholder: Container(
          color: AppColors.black,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
        ),
        errorBuilder: (context, errorMessage) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Video playback error.\nPlease try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      );

      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage =
              'Could not load video. Please check your internet connection and try again.';
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_rounded, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.media.title.isNotEmpty ? widget.media.title : 'Video',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(flex: 5, child: _buildVideoArea()),
          Expanded(flex: 3, child: _buildVideoInfo()),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_isInitializing) {
      return Container(
        color: AppColors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryGreen),
              SizedBox(height: 16),
              Text('Loading video...',
                  style: TextStyle(color: AppColors.white, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: AppColors.black,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.error, size: 56),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _initializePlayer,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }

    if (_chewieController == null) return const SizedBox.shrink();
    return Chewie(controller: _chewieController!);
  }

  Widget _buildVideoInfo() {
    return Container(
      width: double.infinity,
      color: AppColors.charcoal,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.media.title.isNotEmpty ? widget.media.title : 'Video',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('VIDEO',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    )),
              ),
              if (widget.media.durationSeconds != null) ...[
                const SizedBox(width: 10),
                const Icon(Icons.access_time_rounded,
                    color: AppColors.gray, size: 14),
                const SizedBox(width: 4),
                Text(_formatDuration(widget.media.durationSeconds!),
                    style:
                        const TextStyle(color: AppColors.gray, fontSize: 13)),
              ],
              if (widget.media.fileSize != null) ...[
                const SizedBox(width: 10),
                Text('${widget.media.fileSizeMb.toStringAsFixed(1)} MB',
                    style:
                        const TextStyle(color: AppColors.gray, fontSize: 13)),
              ],
            ],
          ),
          if (widget.media.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Text(
              widget.media.description!,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.7),
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.stream_rounded,
                  color: AppColors.primaryGreen, size: 16),
              const SizedBox(width: 6),
              Text(
                'Streaming online · Internet required',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    return '${m}m ${s}s';
  }
}
