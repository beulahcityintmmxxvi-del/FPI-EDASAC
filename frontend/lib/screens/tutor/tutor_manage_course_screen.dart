import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/course_model.dart';
import '../../models/module_model.dart';
import '../../models/multimedia_model.dart';
import '../../providers/tutor_provider.dart';

class TutorManageCourseScreen extends StatefulWidget {
  final CourseModel course;

  const TutorManageCourseScreen({super.key, required this.course});

  @override
  State<TutorManageCourseScreen> createState() =>
      _TutorManageCourseScreenState();
}

class _TutorManageCourseScreenState extends State<TutorManageCourseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TutorProvider>().loadModules(widget.course.id);
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
        title: Text(
          'Manage Course',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateModuleDialog(context),
        backgroundColor: AppColors.blue,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: const Text(
          'Add Module',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<TutorProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            color: AppColors.blue,
            onRefresh: () => provider.loadModules(widget.course.id),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildCourseHeader()),
                if (provider.isLoadingModules)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.blue),
                    ),
                  )
                else if (provider.currentModules.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildModuleCard(
                          provider.currentModules[index],
                          index,
                          provider,
                        ),
                        childCount: provider.currentModules.length,
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

  Widget _buildCourseHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: AppColors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.course.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (widget.course.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            Text(
              widget.course.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.course.isPublished ? '● Published' : '○ Draft',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
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
            const Icon(Icons.layers_outlined,
                size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No modules yet.\nTap "Add Module" to create the first one.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    ModuleModel module,
    int index,
    TutorProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          title: Text(
            module.title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.attach_file_rounded,
                    size: 13, color: AppColors.textTertiary),
                const SizedBox(width: 3),
                Text(
                  '${module.multimediaCount ?? 0} materials',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
                if (module.durationMinutes != null) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.access_time_rounded,
                      size: 13, color: AppColors.textTertiary),
                  const SizedBox(width: 3),
                  Text(
                    '${module.durationMinutes} min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _handleModuleAction(value, module, provider),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 18, color: AppColors.blue),
                  SizedBox(width: 8),
                  Text('Edit Module'),
                ]),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 18, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.error)),
                ]),
              ),
            ],
          ),
          onExpansionChanged: (expanded) {
            if (expanded) provider.loadMultimedia(module.id);
          },
          children: [_buildMaterialsSection(module, provider)],
        ),
      ),
    );
  }

  Widget _buildMaterialsSection(
    ModuleModel module,
    TutorProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (module.description?.isNotEmpty ?? false) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              module.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Learning Materials',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
            TextButton.icon(
              onPressed: provider.isUploading
                  ? null
                  : () => _pickAndUploadFile(module, provider),
              icon: const Icon(Icons.upload_file_rounded, size: 16),
              label: const Text('Upload'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (provider.isUploading) _buildUploadProgress(provider),
        if (provider.isLoadingMultimedia)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: AppColors.blue, strokeWidth: 2),
              ),
            ),
          )
        else if (provider.currentMultimedia.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No materials uploaded yet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          )
        else
          ...provider.currentMultimedia
              .map((m) => _buildMaterialTile(m, provider)),
      ],
    );
  }

  Widget _buildUploadProgress(TutorProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploading...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${(provider.uploadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: provider.uploadProgress,
              backgroundColor: AppColors.blue.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialTile(
    MultimediaModel media,
    TutorProvider provider,
  ) {
    IconData icon;
    Color color;
    if (media.isVideo) {
      icon = Icons.videocam_rounded;
      color = AppColors.red;
    } else if (media.isPdf) {
      icon = Icons.picture_as_pdf_rounded;
      color = AppColors.orange;
    } else if (media.isImage) {
      icon = Icons.image_rounded;
      color = AppColors.blue;
    } else {
      icon = Icons.description_rounded;
      color = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
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
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${media.mediaType.toUpperCase()} · '
                  '${media.fileSizeMb.toStringAsFixed(1)} MB',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 20),
            onPressed: () => _confirmDeleteMaterial(media, provider),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS ====================

  Future<void> _handleModuleAction(
    String action,
    ModuleModel module,
    TutorProvider provider,
  ) async {
    if (action == 'edit') {
      _showEditModuleDialog(module, provider);
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Module'),
          content: Text(
            'Delete "${module.title}" and all its materials? '
            'This cannot be undone.',
          ),
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
        final success = await provider.deleteModule(module.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Module deleted'
                  : provider.errorMessage ?? 'Failed to delete'),
              backgroundColor: success ? AppColors.success : AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteMaterial(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Material deleted'
                : provider.errorMessage ?? 'Failed to delete'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadFile(
    ModuleModel module,
    TutorProvider provider,
  ) async {
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

    // Ask for optional title
    final titleController =
        TextEditingController(text: file.name.replaceAll('.$ext', ''));
    final descController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Upload Material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
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
      moduleId: module.id,
      title: titleController.text.trim().isEmpty
          ? file.name
          : titleController.text.trim(),
      description: descController.text.trim(),
      fileBytes: file.bytes!,
      fileName: file.name,
      order: provider.currentMultimedia.length,
    );

    if (!mounted) return;
    _snack(
      success
          ? 'File uploaded successfully'
          : provider.errorMessage ?? 'Upload failed',
      success ? AppColors.success : AppColors.error,
    );

    // Refresh module count on parent list
    await provider.loadModules(widget.course.id);
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _showCreateModuleDialog(BuildContext ctx) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final durationController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: ctx,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Create Module'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration:
                        const InputDecoration(labelText: 'Module Title'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes, optional)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isLoading = true);

                      final provider = ctx.read<TutorProvider>();
                      final success = await provider.createModule(
                        courseId: widget.course.id,
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        order: provider.currentModules.length,
                        durationMinutes: int.tryParse(
                          durationController.text.trim(),
                        ),
                      );

                      if (dCtx.mounted) {
                        Navigator.pop(dCtx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Module created'
                                : provider.errorMessage ?? 'Failed to create'),
                            backgroundColor:
                                success ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2),
                    )
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );

    // Delay disposal to avoid _dependents.isEmpty crash during async
    // widget tree teardown after the dialog closes.
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      titleController.dispose();
      descController.dispose();
      durationController.dispose();
    });
  }

  Future<void> _showEditModuleDialog(
    ModuleModel module,
    TutorProvider provider,
  ) async {
    final titleController = TextEditingController(text: module.title);
    final descController = TextEditingController(text: module.description);
    final durationController = TextEditingController(
      text: module.durationMinutes?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Module'),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes, optional)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isLoading = true);

                      final success = await provider.updateModule(
                        moduleId: module.id,
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        durationMinutes: int.tryParse(
                          durationController.text.trim(),
                        ),
                      );

                      if (dCtx.mounted) {
                        Navigator.pop(dCtx);
                        _snack(
                          success
                              ? 'Module updated'
                              : provider.errorMessage ?? 'Update failed',
                          success ? AppColors.success : AppColors.error,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: AppColors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );

    // Delay disposal to avoid _dependents.isEmpty crash during async
    // widget tree teardown after the dialog closes.
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      titleController.dispose();
      descController.dispose();
      durationController.dispose();
    });
  }
}
