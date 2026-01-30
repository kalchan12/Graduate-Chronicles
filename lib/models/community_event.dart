class CommunityEvent {
  final String id;
  final String userId;
  final List<String> mediaUrls; // Changed from single String
  final String mediaType; // 'image' or 'video'
  final String? caption;
  final String? category; // '100 Day', '50 Day', 'Other'

  // Metadata from joins
  final int? batchYear;
  final String? school;
  final String? major;
  final String? program; // 'Regular', 'Extension'

  final DateTime createdAt;
  final String? username;
  final String? userFullName;
  final String? userProfilePic;
  final int likeCount;
  final bool isLikedByMe;

  CommunityEvent({
    required this.id,
    required this.userId,
    required this.mediaUrls,
    required this.mediaType,
    this.caption,
    this.category,
    this.batchYear,
    this.school,
    this.major,
    this.program,
    required this.createdAt,
    this.username,
    this.userFullName,
    this.userProfilePic,
    this.likeCount = 0,
    this.isLikedByMe = false,
  });

  factory CommunityEvent.fromJson(Map<String, dynamic> json) {
    // Handle nested user data if joined
    final userData = json['users'] as Map<String, dynamic>?;

    return CommunityEvent(
      id: json['id'],
      userId: json['user_id'],
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
      mediaType: json['media_type'],
      caption: json['caption'],
      category: json['category'],
      batchYear: json['batch_year'],
      school: json['school'],
      major: json['major'],
      program: json['program'],
      createdAt: DateTime.parse(json['created_at']),
      username: userData?['username'],
      userFullName: userData?['full_name'],
      userProfilePic: userData?['profile_picture'],
      likeCount: json['like_count'] ?? 0,
      isLikedByMe: json['is_liked_by_me'] ?? false,
    );
  }
}
