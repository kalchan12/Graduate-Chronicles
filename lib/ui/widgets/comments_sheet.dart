import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/posts_state.dart';
import '../../theme/design_system.dart';
import '../../services/supabase/supabase_service.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  const CommentsSheet({super.key, required this.postId});

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;

  void _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);
    try {
      final service = ref.read(supabaseServiceProvider);
      await service.addComment(widget.postId, _commentController.text.trim());

      _commentController.clear();

      // Refresh comments and feed count (optimistic update needed in feed provider for count)
      ref.invalidate(commentsProvider(widget.postId));
      ref.read(feedProvider.notifier).incrementCommentCount(widget.postId);
    } catch (e) {
      // Show toast
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.postId));

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2E1A36), // Dark background matching theme
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Comments',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(color: Colors.white10),

              // Comments List
              Expanded(
                child: commentsAsync.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return const Center(
                        child: Text(
                          'No comments yet',
                          style: TextStyle(color: Colors.white38),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        final user = c['users'];
                        final content = c['content'];
                        final created = DateTime.parse(c['created_at']);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[800],
                                child: const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.white54,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user['full_name'] ??
                                              user['username'] ??
                                              'User',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _timeAgo(created),
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      content,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: DesignSystem.purpleAccent,
                    ),
                  ),
                  error: (e, __) => Center(
                    child: Text(
                      'Error: $e',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),

              // Input Area
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
                ),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                  color: Color(0xFF1F1025),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: _isPosting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: DesignSystem.purpleAccent,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color: DesignSystem.purpleAccent,
                            ),
                      onPressed: _isPosting ? null : _postComment,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
