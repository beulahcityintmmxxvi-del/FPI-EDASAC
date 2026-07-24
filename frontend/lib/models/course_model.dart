class CourseModel {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final int vocationId;
  final int tutorId;
  final bool isPublished;
  final int? moduleCount;
  final int? enrollmentCount;
  final String createdAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    required this.vocationId,
    required this.tutorId,
    required this.isPublished,
    this.moduleCount,
    this.enrollmentCount,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      description: json['description'],
      vocationId: json['vocation_id'],
      tutorId: json['tutor_id'],
      isPublished: json['is_published'] ?? false,
      moduleCount: json['module_count'],
      enrollmentCount: json['enrollment_count'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'vocation_id': vocationId,
      'tutor_id': tutorId,
      'is_published': isPublished,
      'module_count': moduleCount,
      'enrollment_count': enrollmentCount,
      'created_at': createdAt,
    };
  }
}
