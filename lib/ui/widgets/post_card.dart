import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/posts_state.dart';
import '../../state/profile_state.dart';
import '../../theme/design_system.dart';
import '../profile/profile_screen.dart';
import '../../services/supabase/supabase_service.dart';
import 'comments_sheet.dart';
import 'toast_helper.dart';

class PostCard extends ConsumerStatefulWidget {
  final PostItem post;
  final Function(String postId)? onLike;
  final Function(String postId)? onComment;

  const PostCard({super.key, required this.post, this.onLike, this.onComment});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _likeController;
  late Animation<double> _likeScale;
  int _currentMediaIndex = 0;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _likeScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.easeOutBack),
    );

    _likeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _likeController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _handleLike() {
    if (!widget.post.isLikedByMe) {
      _likeController.forward();
    }

    if (widget.onLike != null) {
      widget.onLike!(widget.post.id);
    } else {
      ref.read(feedProvider.notifier).toggleLike(widget.post.id);
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(postId: widget.post.id),
    );
  }

  void _showOptions() {
    final myProfile = ref.read(profileProvider);
    final isOwner = myProfile.id == widget.post.userId;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1224),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (isOwner)
                _optionTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete Post',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete();
                  },
                ),
              _optionTile(
                icon: Icons.flag_outlined,
                label: 'Report Post',
                color: Colors.orangeAccent,
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog();
                },
              ),
              _optionTile(
                icon: Icons.share_outlined,
                label: 'Share via...',
                color: Colors.white,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color == Colors.white ? Colors.white.withOpacity(0.9) : color,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1224),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete post?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will permanently remove this post from your profile.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final service = ref.read(supabaseServiceProvider);
                await service.deletePost(widget.post.id);
                // We utilize the passed callback logic ideally, but delete is simpler to be global
                // Or we inform feed.
                // For now, assume feed refreshes or handles removal.
                // But specifically for 'feedProvider' vs 'personalizedFeedProvider',
                // we might need a callback for delete too.
                // Let's stick to simple implementation: invalidate feeds.
                ref.read(feedProvider.notifier).removePost(widget.post.id);
                // Also invalidate personalized feed if possible, or let user refresh
                // ref.invalidate(personalizedFeedProvider); // Optional but clean

                if (mounted) ToastHelper.show(context, 'Post deleted');
              } catch (e) {
                if (mounted) {
                  ToastHelper.show(context, 'Delete failed: $e', isError: true);
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    String? selectedReason;
    final reasons = [
      'Spam or misleading',
      'Harassment or bullying',
      'Inappropriate content',
      'Violence',
      'Other',
    ];
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1224),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Report Post',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: reasons.map((reason) {
              return RadioListTile<String>(
                title: Text(
                  reason,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 15,
                  ),
                ),
                value: reason,
                groupValue: selectedReason,
                activeColor: DesignSystem.purpleAccent,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) =>
                    setDialogState(() => selectedReason = value),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
            ElevatedButton(
              onPressed: selectedReason == null
                  ? null
                  : () async {
                      Navigator.pop(dialogContext);
                      try {
                        final service = ref.read(supabaseServiceProvider);
                        await service.reportPost(
                          widget.post.id,
                          selectedReason!,
                          widget.post.userId,
                        );
                        if (mounted) {
                          ToastHelper.show(
                            scaffoldContext,
                            'Report submitted. Thank you.',
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ToastHelper.show(
                            scaffoldContext,
                            'Report failed',
                            isError: true,
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.purpleAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF180D1D), // Dark, clean background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.04), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfileScreen(userId: widget.post.userId),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF2E1A36),
                        backgroundImage: widget.post.userAvatar != null
                            ? CachedNetworkImageProvider(
                                widget.post.userAvatar!,
                              )
                            : null,
                        child: widget.post.userAvatar == null
                            ? Icon(
                                Icons.person,
                                color: Colors.white.withOpacity(0.5),
                                size: 20,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.userName ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _timeAgo(widget.post.createdAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  onPressed: _showOptions,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Caption
          if (widget.post.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                widget.post.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

          // Media
          if (widget.post.mediaUrls.isNotEmpty) _buildMediaCarousel(),

          // Action Toolbar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              children: [
                _InteractionButton(
                  icon: widget.post.isLikedByMe
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: '${widget.post.likesCount}',
                  color: widget.post.isLikedByMe
                      ? const Color(0xFFE94CFF)
                      : Colors.white.withOpacity(
                          0.6,
                        ), // Updated to correct purple
                  onTap: _handleLike,
                  animation: _likeScale,
                ),
                const SizedBox(width: 20),
                _InteractionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '${widget.post.commentsCount}',
                  color: Colors.white.withOpacity(0.6),
                  onTap: _showComments,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    color: Colors.white.withOpacity(0.6),
                    size: 22,
                  ),
                  onPressed: () {}, // Share placeholder
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCarousel() {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        width: double.infinity,
        color: Colors.black,
        child: widget.post.mediaUrls.length == 1
            ? CachedNetworkImage(
                imageUrl: widget.post.mediaUrls.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildLoadingState(),
                errorWidget: (_, __, ___) => _buildErrorState(),
              )
            : Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.post.mediaUrls.length,
                    onPageChanged: (index) =>
                        setState(() => _currentMediaIndex = index),
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.post.mediaUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => _buildLoadingState(),
                        errorWidget: (_, __, ___) => _buildErrorState(),
                      );
                    },
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentMediaIndex + 1}/${widget.post.mediaUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: DesignSystem.purpleAccent.withOpacity(0.3),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Icon(
        Icons.broken_image_rounded,
        color: Colors.white.withOpacity(0.2),
        size: 48,
      ),
    );
  }

  String _timeAgo(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays > 365) return "${(diff.inDays / 365).floor()}y";
    if (diff.inDays > 30) return "${(diff.inDays / 30).floor()}mo";
    if (diff.inDays > 0) return "${diff.inDays}d";
    if (diff.inHours > 0) return "${diff.inHours}h";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m";
    return "now";
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Animation<double>? animation;

  const _InteractionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(icon, color: color, size: 24);
    if (animation != null) {
      iconWidget = ScaleTransition(scale: animation!, child: iconWidget);
    }

    return GestureDetector(
      onTap: () {
        print('🖱️ DEBUG: InteractionButton tapped: $label');
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent, // Ensures the entire area is tappable
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ), // Increase touch target
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
