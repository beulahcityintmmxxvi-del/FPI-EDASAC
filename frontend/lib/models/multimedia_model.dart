class MultimediaModel {
  final int id;
  final String title;
  final String? description;
  final String mediaType;
  final String fileName;
  final int? fileSize;
  final String? mimeType;
  final int? durationSeconds;
  final int moduleId;
  final int order;
  final String createdAt;

  MultimediaModel({
    required this.id,
    required this.title,
    this.description,
    required this.mediaType,
    required this.fileName,
    this.fileSize,
    this.mimeType,
    this.durationSeconds,
    required this.moduleId,
    required this.order,
    required this.createdAt,
  });

  String get streamUrl => '/api/media/stream/$id';
  String get downloadUrl => '/api/media/download/$id';

  bool get isVideo => mediaType == 'video';
  bool get isPdf => mediaType == 'pdf';
  bool get isImage => mediaType == 'image';

  double get fileSizeMb => fileSize != null ? fileSize! / (1024 * 1024) : 0.0;

  factory MultimediaModel.fromJson(Map<String, dynamic> json) {
    return MultimediaModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      mediaType: json['media_type']?.toString() ?? 'unknown',
      fileName: json['file_name'] ?? '',
      fileSize: json['file_size'],
      mimeType: json['mime_type'],
      durationSeconds: json['duration_seconds'],
      moduleId: json['module_id'],
      order: json['order'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'media_type': mediaType,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'duration_seconds': durationSeconds,
      'module_id': moduleId,
      'order': order,
      'created_at': createdAt,
    };
  }
}
