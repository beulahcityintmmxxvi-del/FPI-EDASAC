class SubmissionModel {
  final int id;
  final int assignmentId;
  final int studentId;
  final String? submissionText;
  final String? filePath;
  final String? fileName;
  final String status;
  final double? score;
  final String? feedback;
  final String createdAt;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.submissionText,
    this.filePath,
    this.fileName,
    required this.status,
    this.score,
    this.feedback,
    required this.createdAt,
  });

  bool get isGraded => status == 'graded';
  bool get isSubmitted => status == 'submitted';

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'],
      assignmentId: json['assignment_id'],
      studentId: json['student_id'],
      submissionText: json['submission_text'],
      filePath: json['file_path'],
      fileName: json['file_name'],
      status: json['status'] ?? 'submitted',
      score: json['score'] != null
          ? (json['score'] as num).toDouble()
          : null,
      feedback: json['feedback'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'submission_text': submissionText,
      'file_path': filePath,
      'file_name': fileName,
      'status': status,
      'score': score,
      'feedback': feedback,
      'created_at': createdAt,
    };
  }
}