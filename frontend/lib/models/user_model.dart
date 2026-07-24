class UserModel {
  final int id;
  final String? email;
  final String? matricNumber;
  final String role;
  final bool isActive;
  final bool isApproved;
  final bool mustChangePassword;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? profilePicture;
  final int? departmentId;
  final String? academicLevel;
  final int? vocationId;
  final String? bio;
  final String? specialization;
  final String createdAt;

  UserModel({
    required this.id,
    this.email,
    this.matricNumber,
    required this.role,
    required this.isActive,
    required this.isApproved,
    required this.mustChangePassword,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.profilePicture,
    this.departmentId,
    this.academicLevel,
    this.vocationId,
    this.bio,
    this.specialization,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  bool get isStudent => role == 'student';
  bool get isTutor => role == 'tutor';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle role - may come as enum string e.g. "UserRole.student" or "student"
    String roleStr = json['role']?.toString() ?? 'student';
    if (roleStr.contains('.')) {
      roleStr = roleStr.split('.').last;
    }

    // Handle academic_level - may come as enum string
    String? levelStr = json['academic_level']?.toString();
    if (levelStr != null && levelStr.contains('.')) {
      levelStr = levelStr.split('.').last;
    }

    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email']?.toString(),
      matricNumber: json['matric_number']?.toString(),
      role: roleStr,
      isActive: json['is_active'] == true,
      isApproved: json['is_approved'] == true,
      mustChangePassword: json['must_change_password'] == true,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      departmentId: json['department_id'] is int
          ? json['department_id']
          : int.tryParse(json['department_id']?.toString() ?? ''),
      academicLevel: levelStr,
      vocationId: json['vocation_id'] is int
          ? json['vocation_id']
          : int.tryParse(json['vocation_id']?.toString() ?? ''),
      bio: json['bio']?.toString(),
      specialization: json['specialization']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'matric_number': matricNumber,
      'role': role,
      'is_active': isActive,
      'is_approved': isApproved,
      'must_change_password': mustChangePassword,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'department_id': departmentId,
      'academic_level': academicLevel,
      'vocation_id': vocationId,
      'bio': bio,
      'specialization': specialization,
      'created_at': createdAt,
    };
  }
}
