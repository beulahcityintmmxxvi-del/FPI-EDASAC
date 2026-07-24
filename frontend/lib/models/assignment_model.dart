class AssignmentModel {
  final int id;
  final String title;
  final String? description;
  final int courseId;
  final double maxScore;
  final bool isPublished;
  final int? submissionCount;
  final String? dueDate;
  final String? assignmentType;
  final String? attachmentPath;
  final String? attachmentName;
  final int? attachmentSize;
  final String? attachmentMimeType;
  final String createdAt;

  AssignmentModel({
    required this.id,
    required this.title,
    this.description,
    required this.courseId,
    required this.maxScore,
    required this.isPublished,
    this.submissionCount,
    this.dueDate,
    this.assignmentType,
    this.attachmentPath,
    this.attachmentName,
    this.attachmentSize,
    this.attachmentMimeType,
    required this.createdAt,
  });

  bool get hasAttachment =>
      attachmentPath != null && attachmentPath!.isNotEmpty;

  double get attachmentSizeMb =>
      attachmentSize != null ? attachmentSize! / (1024 * 1024) : 0.0;

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      courseId: json['course_id'],
      maxScore: (json['max_score'] ?? 100).toDouble(),
      isPublished: json['is_published'] ?? false,
      submissionCount: json['submission_count'],
      dueDate: json['due_date'],
      assignmentType: json['assignment_type']?.toString(),
      attachmentPath: json['attachment_path'],
      attachmentName: json['attachment_name'],
      attachmentSize: json['attachment_size'],
      attachmentMimeType: json['attachment_mime_type'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'course_id': courseId,
        'max_score': maxScore,
        'is_published': isPublished,
        'submission_count': submissionCount,
        'due_date': dueDate,
        'assignment_type': assignmentType,
        'attachment_path': attachmentPath,
        'attachment_name': attachmentName,
        'attachment_size': attachmentSize,
        'attachment_mime_type': attachmentMimeType,
        'created_at': createdAt,
      };
}
