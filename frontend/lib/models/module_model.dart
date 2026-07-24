class ModuleModel {
  final int id;
  final String title;
  final String? description;
  final int courseId;
  final int order;
  final int? durationMinutes;
  final bool isPublished;
  final int? multimediaCount;
  final String createdAt;

  ModuleModel({
    required this.id,
    required this.title,
    this.description,
    required this.courseId,
    required this.order,
    this.durationMinutes,
    required this.isPublished,
    this.multimediaCount,
    required this.createdAt,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      courseId: json['course_id'],
      order: json['order'] ?? 0,
      durationMinutes: json['duration_minutes'],
      isPublished: json['is_published'] ?? false,
      multimediaCount: json['multimedia_count'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'course_id': courseId,
      'order': order,
      'duration_minutes': durationMinutes,
      'is_published': isPublished,
      'multimedia_count': multimediaCount,
      'created_at': createdAt,
    };
  }
}
