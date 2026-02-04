import 'package:flutter/material.dart';
import '../../state/posts_state.dart';
import '../../theme/design_system.dart';
import '../profile/profile_screen.dart';

/// Announcement Card Widget
///
/// Displays announcements with a distinct visual style.
/// - No like/comment buttons (broadcast mode)
/// - Shows author info prominently
/// - Formal styling
class AnnouncementCard extends StatelessWidget {
  final PostItem announcement;

  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    debugPrint('[ANNOUNCEMENT_RENDER] id=${announcement.id}');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF2D1F3D), const Color(0xFF1A1225)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.purpleAccent.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: DesignSystem.purpleAccent.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Announcement Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignSystem.purpleAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: DesignSystem.purpleAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Announcement Label
                const Text(
                  'ANNOUNCEMENT',
                  style: TextStyle(
                    color: DesignSystem.purpleAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                // Timestamp
                Text(
                  _timeAgo(announcement.createdAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Author Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: announcement.userId),
                  ),
                );
              },
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DesignSystem.purpleAccent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: announcement.userAvatar != null
                          ? Image.network(
                              announcement.userAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person,
                                    color: Colors.white54,
                                    size: 24,
                                  ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Colors.white54,
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.userName ?? 'Unknown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Author',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Media (if any)
          if (announcement.mediaUrls.isNotEmpty) _buildMedia(),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              announcement.description,
              style: const TextStyle(
                color: Color(0xFFE0D6EB),
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia() {
    final mediaUrl = announcement.mediaUrls.first;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          mediaUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 150,
            color: Colors.grey[900],
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
