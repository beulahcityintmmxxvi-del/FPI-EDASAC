import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/module_model.dart';
import '../../models/multimedia_model.dart';
import '../../providers/tutor_provider.dart';

class TutorModuleMaterialsScreen extends StatefulWidget {
  final ModuleModel module;

  const TutorModuleMaterialsScreen({super.key, required this.module});

  @override
  State<TutorModuleMaterialsScreen> createState() =>
      _TutorModuleMaterialsScreenState();
}

class _TutorModuleMaterialsScreenState
    extends State<TutorModuleMaterialsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TutorProvider>().loadMultimedia(widget.module.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Materials',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              widget.module.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<TutorProvider>(
        builder: (context, provider, _) => FloatingActionButton.extended(
          onPressed: provider.isUploading ? null : () => _pickFile(provider),
          backgroundColor: AppColors.blue,
          icon: const Icon(Icons.upload_file_rounded, color: AppColors.white),
          label: const Text('Upload',
              style: TextStyle(
                  color: AppColors.white, fontWeight: FontWeight.w600)),
        ),
      ),
      body: Consumer<TutorProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            color: AppColors.blue,
            onRefresh: () => provider.loadMultimedia(widget.module.id),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (provider.isUploading)
                  SliverToBoxAdapter(child: _buildUploadProgress(provider)),
                if (provider.isLoadingMultimedia)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.blue),
                    ),
                  )
                else if (provider.currentMultimedia.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _buildMaterialCard(
                          provider.currentMultimedia[i],
                          provider,
                        ),
                        childCount: provider.currentMultimedia.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadProgress(TutorProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_upload_rounded, color: AppColors.blue),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Uploading file...',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(provider.uploadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: provider.uploadProgress,
              backgroundColor: AppColors.blue.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_outlined,
                size: 72, color: AppColors.textTertiary),
            const SizedBox(height: 20),
            Text(
              'No materials uploaded yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the Upload button below to add videos, PDFs, images, or docs.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(MultimediaModel media, TutorProvider provider) {
    IconData icon;
    Color color;
    String typeLabel;

    if (media.isVideo) {
      icon = Icons.videocam_rounded;
      color = AppColors.red;
      typeLabel = 'VIDEO';
    } else if (media.isPdf) {
      icon = Icons.picture_as_pdf_rounded;
      color = AppColors.orange;
      typeLabel = 'PDF';
    } else if (media.isImage) {
      icon = Icons.image_rounded;
      color = AppColors.blue;
      typeLabel = 'IMAGE';
    } else {
      icon = Icons.description_rounded;
      color = AppColors.textSecondary;
      typeLabel = 'DOC';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 26),
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
                      ?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (media.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 2),
                  Text(
                    media.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${media.fileSizeMb.toStringAsFixed(1)} MB',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            onPressed: () => _confirmDelete(media, provider),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile(TutorProvider provider) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        ...AppConstants.allowedVideoExtensions,
        ...AppConstants.allowedImageExtensions,
        ...AppConstants.allowedDocumentExtensions,
      ],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    if (file.bytes == null) {
      _snack('Could not read file bytes.', AppColors.error);
      return;
    }

    final ext = file.name.split('.').last.toLowerCase();
    int limitMb;
    if (AppConstants.allowedVideoExtensions.contains(ext)) {
      limitMb = AppConstants.maxVideoSizeMB;
    } else if (AppConstants.allowedImageExtensions.contains(ext)) {
      limitMb = AppConstants.maxImageSizeMB;
    } else if (ext == 'pdf') {
      limitMb = AppConstants.maxPdfSizeMB;
    } else {
      limitMb = AppConstants.maxDocumentSizeMB;
    }

    if (file.size > limitMb * 1024 * 1024) {
      _snack('File too large. Max size is ${limitMb}MB for .$ext',
          AppColors.error);
      return;
    }

    final defaultTitle = file.name.replaceAll('.$ext', '');
    final titleController = TextEditingController(text: defaultTitle);
    final descController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Learning Material'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${file.name} · ${(file.size / (1024 * 1024)).toStringAsFixed(2)} MB',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a title.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Upload'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await provider.uploadMultimedia(
      moduleId: widget.module.id,
      title: titleController.text.trim(),
      description: descController.text.trim(),
      fileBytes: file.bytes!,
      fileName: file.name,
      order: provider.currentMultimedia.length,
    );

    if (!mounted) return;
    _snack(
      success
          ? 'Material uploaded successfully'
          : provider.errorMessage ?? 'Upload failed',
      success ? AppColors.success : AppColors.error,
    );
  }

  Future<void> _confirmDelete(
    MultimediaModel media,
    TutorProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Material'),
        content: Text('Delete "${media.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.deleteMultimedia(media.id);
      if (mounted) {
        _snack(
          success
              ? 'Material deleted'
              : provider.errorMessage ?? 'Failed to delete',
          success ? AppColors.success : AppColors.error,
        );
      }
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }
}
