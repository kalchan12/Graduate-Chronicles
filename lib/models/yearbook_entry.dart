class YearbookBatch {
  final String id;
  final int batchYear;
  final String? batchSubtitle;
  final DateTime createdAt;

  const YearbookBatch({
    required this.id,
    required this.batchYear,
    this.batchSubtitle,
    required this.createdAt,
  });

  factory YearbookBatch.fromMap(Map<String, dynamic> map) {
    return YearbookBatch(
      id: map['id'] as String,
      batchYear: map['batch_year'] as int,
      batchSubtitle: map['batch_subtitle'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batch_year': batchYear,
      'batch_subtitle': batchSubtitle,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class YearbookEntry {
  final String id;
  final String userId;
  final String batchId;
  final String yearbookPhotoUrl;
  final String? yearbookBio;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> morePictures;

  // User data from JOIN (NOT stored in yearbook_entries table)
  final String? fullName;
  final String? username;
  final String? major;
  final String? school;

  const YearbookEntry({
    required this.id,
    required this.userId,
    required this.batchId,
    required this.yearbookPhotoUrl,
    this.yearbookBio,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.morePictures = const [],
    // Joined data
    this.fullName,
    this.username,
    this.major,
    this.school,
  });

  factory YearbookEntry.fromMap(Map<String, dynamic> map) {
    return YearbookEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      batchId: map['batch_id'] as String,
      yearbookPhotoUrl: map['yearbook_photo_url'] as String,
      yearbookBio: map['yearbook_bio'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      morePictures: map['more_pictures'] == null
          ? []
          : List<String>.from(map['more_pictures']),
      // Joined user data (may be null if not included in query)
      fullName: map['full_name'] as String?,
      username: map['username'] as String?,
      major: map['major'] as String?,
      school: map['school'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'batch_id': batchId,
      'yearbook_photo_url': yearbookPhotoUrl,
      'yearbook_bio': yearbookBio,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'more_pictures': morePictures,
    };
  }

  YearbookEntry copyWith({
    String? id,
    String? userId,
    String? batchId,
    String? yearbookPhotoUrl,
    String? yearbookBio,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? morePictures,
    String? fullName,
    String? username,
    String? major,
    String? school,
  }) {
    return YearbookEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      batchId: batchId ?? this.batchId,
      yearbookPhotoUrl: yearbookPhotoUrl ?? this.yearbookPhotoUrl,
      yearbookBio: yearbookBio ?? this.yearbookBio,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      morePictures: morePictures ?? this.morePictures,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      major: major ?? this.major,
      school: school ?? this.school,
    );
  }
}
