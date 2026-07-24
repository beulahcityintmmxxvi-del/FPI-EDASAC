/// Enrollment Model
/// Tracks student enrollment in courses

class EnrollmentModel {
  final int id;
  final int studentId;
  final int courseId;
  final double progressPercentage;
  final bool isCompleted;
  final String createdAt;

  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.progressPercentage,
    required this.isCompleted,
    required this.createdAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      courseId: json['course_id'] as int,
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'course_id': courseId,
      'progress_percentage': progressPercentage,
      'is_completed': isCompleted,
      'created_at': createdAt,
    };
  }
}

/// Result returned after enrolling in a vocation
class VocationEnrollmentResult {
  final int vocationId;
  final String vocationName;
  final int coursesEnrolled;
  final String message;

  VocationEnrollmentResult({
    required this.vocationId,
    required this.vocationName,
    required this.coursesEnrolled,
    required this.message,
  });

  factory VocationEnrollmentResult.fromJson(Map<String, dynamic> json) {
    return VocationEnrollmentResult(
      vocationId: json['vocation_id'] as int,
      vocationName: json['vocation_name']?.toString() ?? '',
      coursesEnrolled: json['courses_enrolled'] as int? ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}
