class TeacherModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? subject;
  final String? qualification;
  final int experienceYears;
  final String? photoUrl;
  final String? address;
  final DateTime? joiningDate;
  final double salary;
  final bool isActive;
  final List<String> assignedBatches; // batch names
  final DateTime? updatedAt;

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.subject,
    this.qualification,
    this.experienceYears = 0,
    this.photoUrl,
    this.address,
    this.joiningDate,
    this.salary = 0,
    this.isActive = true,
    this.assignedBatches = const [],
    this.updatedAt,
  });

  // Helpers
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  String get experienceDisplay =>
      experienceYears == 0 ? 'Fresher' :
      experienceYears == 1 ? '1 year' : '$experienceYears years';

  String get salaryDisplay =>
      salary == 0 ? 'Not set' : '₹${salary.toStringAsFixed(0)}/month';

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      subject: map['subject'],
      qualification: map['qualification'],
      experienceYears: map['experience_years'] ?? 0,
      photoUrl: map['photo_url'],
      address: map['address'],
      joiningDate: map['joining_date'] != null ? DateTime.parse(map['joining_date']) : null,
      salary: (map['salary'] ?? 0).toDouble(),
      isActive: map['is_active'] ?? true,
      assignedBatches: map['assigned_batches'] != null
          ? List<String>.from(map['assigned_batches'])
          : [],
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'subject': subject,
      'qualification': qualification,
      'experience_years': experienceYears,
      'photo_url': photoUrl,
      'address': address,
      'joining_date': joiningDate?.toIso8601String(),
      'salary': salary,
      'is_active': isActive,
    };
  }

  TeacherModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? subject,
    String? qualification,
    int? experienceYears,
    String? photoUrl,
    String? address,
    DateTime? joiningDate,
    double? salary,
    bool? isActive,
    List<String>? assignedBatches,
    DateTime? updatedAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      subject: subject ?? this.subject,
      qualification: qualification ?? this.qualification,
      experienceYears: experienceYears ?? this.experienceYears,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      joiningDate: joiningDate ?? this.joiningDate,
      salary: salary ?? this.salary,
      isActive: isActive ?? this.isActive,
      assignedBatches: assignedBatches ?? this.assignedBatches,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
