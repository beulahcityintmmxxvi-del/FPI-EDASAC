import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/assignment_model.dart';
import '../../models/submission_model.dart';
import '../../providers/student_provider.dart';

class StudentSubmitAssignmentScreen extends StatefulWidget {
  final AssignmentModel assignment;
  final StudentProvider provider;
  final SubmissionModel? existingSubmission;

  const StudentSubmitAssignmentScreen({
    super.key,
    required this.assignment,
    required this.provider,
    this.existingSubmission,
  });

  @override
  State<StudentSubmitAssignmentScreen> createState() =>
      _StudentSubmitAssignmentScreenState();
}

class _StudentSubmitAssignmentScreenState
    extends State<StudentSubmitAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  PlatformFile? _selectedFile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _useFileUpload = false;

  bool get _isEditing => widget.existingSubmission != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSubmission;
    if (existing != null) {
      if (existing.submissionText?.isNotEmpty ?? false) {
        _textController.text = existing.submissionText!;
        _useFileUpload = false;
      } else if (existing.fileName != null) {
        _useFileUpload = true;
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
          _isEditing ? 'Edit Submission' : 'Submit Assignment',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAssignmentInfo(),
            if (_isEditing) ...[
              const SizedBox(height: 12),
              _buildEditingBanner(),
            ],
            const SizedBox(height: 20),
            _buildSubmissionModeToggle(),
            const SizedBox(height: 20),
            _buildSubmissionForm(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.05),
        border: Border.all(color: AppColors.blue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note_rounded, color: AppColors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are updating your previous submission. '
              'You can edit until the tutor grades it.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.assignment_rounded,
                    color: AppColors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.assignment.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          if (widget.assignment.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 10),
            Text(
              widget.assignment.description!,
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
              'Max Score: ${widget.assignment.maxScore.toInt()} pts',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _useFileUpload = false),
              child: AnimatedContainer(
                duration: AppConstants.shortAnimation,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_useFileUpload
                      ? AppColors.primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.text_fields_rounded,
                        color: !_useFileUpload
                            ? AppColors.white
                            : AppColors.textSecondary,
                        size: 18),
                    const SizedBox(width: 6),
                    Text('Text Answer',
                        style: TextStyle(
                          color: !_useFileUpload
                              ? AppColors.white
                              : AppColors.textSecondary,
                          fontWeight: !_useFileUpload
                              ? FontWeight.w700
                              : FontWeight.normal,
                          fontSize: 13,
                        )),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _useFileUpload = true),
              child: AnimatedContainer(
                duration: AppConstants.shortAnimation,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _useFileUpload
                      ? AppColors.primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_file_rounded,
                        color: _useFileUpload
                            ? AppColors.white
                            : AppColors.textSecondary,
                        size: 18),
                    const SizedBox(width: 6),
                    Text('File Upload',
                        style: TextStyle(
                          color: _useFileUpload
                              ? AppColors.white
                              : AppColors.textSecondary,
                          fontWeight: _useFileUpload
                              ? FontWeight.w700
                              : FontWeight.normal,
                          fontSize: 13,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_useFileUpload) ...[
              Text('Your Answer',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _textController,
                maxLines: 8,
                validator: (value) {
                  if (!_useFileUpload &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Please enter your answer';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Type your answer here...',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primaryGreen, width: 2),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ] else ...[
              Text('Upload File',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              if (_isEditing &&
                  widget.existingSubmission?.fileName != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file_rounded,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Current: ${widget.existingSubmission!.fileName}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick a new file to replace it, or leave as is.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickFile,
                child: AnimatedContainer(
                  duration: AppConstants.shortAnimation,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _selectedFile != null
                        ? AppColors.primaryGreen.withOpacity(0.05)
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedFile != null
                          ? AppColors.primaryGreen.withOpacity(0.4)
                          : AppColors.borderMedium,
                    ),
                  ),
                  child: _selectedFile != null
                      ? Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.insert_drive_file_rounded,
                                color: AppColors.primaryGreen,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selectedFile!.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  Text(_formatFileSize(_selectedFile!.size),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: AppColors.error),
                              onPressed: () =>
                                  setState(() => _selectedFile = null),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            const Icon(Icons.cloud_upload_outlined,
                                size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text('Tap to select a file',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text('PDF, DOC, DOCX, JPG, PNG',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textTertiary)),
                          ],
                        ),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleSubmit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 2.5),
                      )
                    : Icon(_isEditing ? Icons.save_rounded : Icons.send_rounded,
                        size: 20),
                label: Text(_isLoading
                    ? (_isEditing ? 'Updating...' : 'Submitting...')
                    : (_isEditing ? 'Update Submission' : 'Submit Assignment')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor:
                      AppColors.primaryGreen.withOpacity(0.6),
                  foregroundColor: AppColors.white,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.size > AppConstants.maxDocumentSizeMB * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'File too large. Max size is ${AppConstants.maxDocumentSizeMB}MB.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      setState(() => _selectedFile = file);
    }
  }

  Future<void> _handleSubmit() async {
    if (_useFileUpload &&
        _selectedFile == null &&
        (widget.existingSubmission?.fileName == null)) {
      setState(() => _errorMessage = 'Please select a file to upload.');
      return;
    }

    if (!_useFileUpload && !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.provider.submitAssignment(
      assignmentId: widget.assignment.id,
      submissionText: !_useFileUpload ? _textController.text.trim() : null,
      fileBytes: _useFileUpload ? _selectedFile?.bytes : null,
      fileName: _useFileUpload ? _selectedFile?.name : null,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.white),
              const SizedBox(width: 12),
              Text(_isEditing
                  ? 'Submission updated successfully!'
                  : 'Assignment submitted successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pop(context);
    } else {
      setState(() => _errorMessage = widget.provider.errorMessage ??
          'Submission failed. Please try again.');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
