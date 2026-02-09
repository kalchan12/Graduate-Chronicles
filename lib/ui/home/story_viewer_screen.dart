import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_view/story_view.dart';
import '../../state/stories_state.dart';

class StoryViewerScreen extends ConsumerStatefulWidget {
  final UserStoryGroup userGroup;
  const StoryViewerScreen({super.key, required this.userGroup});

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  final StoryController _controller = StoryController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get the latest data for this user group to ensure reactivity
    final allGroups = ref.watch(storiesProvider);
    final currentGroup = allGroups.firstWhere(
      (g) => g.userId == widget.userGroup.userId,
      orElse: () => widget.userGroup,
    );

    // If no stories left (e.g. after delete), close viewer
    if (currentGroup.stories.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }

    final List<StoryItem> storyItems = currentGroup.stories.map((story) {
      if (story.mediaType == StoryMediaType.video) {
        return StoryItem.pageVideo(
          story.mediaUrl,
          controller: _controller,
          duration: const Duration(
            seconds: 15,
          ), // or actual dynamic duration if available
          caption: story.caption != null
              ? Text(
                  story.caption!,
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        );
      } else {
        return StoryItem.pageImage(
          url: story.mediaUrl,
          controller: _controller,
          duration: const Duration(seconds: 5),
          caption: story.caption != null
              ? Text(
                  story.caption!,
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        );
      }
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The main StoryView
          StoryView(
            storyItems: storyItems,
            controller: _controller,
            onComplete: () {
              Navigator.pop(context);
            },
            // Removed onVerticalSwipeComplete to avoid potential null/bool type error in package
            // Removed outer GestureDetector as StoryView handles gestures
            onStoryShow: (s, index) {
              // Defer state update to avoid build conflicts
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              });
            },
          ),

          // Top overlay: User info and Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 16,
            right: 16,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[900],
                  backgroundImage:
                      currentGroup.profilePicUrl != null &&
                          currentGroup.profilePicUrl!.isNotEmpty
                      ? NetworkImage(currentGroup.profilePicUrl!)
                      : null,
                  child: currentGroup.profilePicUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  currentGroup.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                // Delete Option (Only if it's me)
                if (currentGroup.isMe)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      _controller.pause();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Story?'),
                          content: const Text(
                            'Are you sure you want to delete this story?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                _controller.play();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                final story =
                                    currentGroup.stories[_currentIndex];
                                await ref
                                    .read(storiesProvider.notifier)
                                    .deleteStory(story.id);
                                // The reactive build will handle the update (rebuild or pop if empty)
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Bottom Liquid UI state (Like button overlay)
          // Hide like button if it's my own story? Usually you don't like your own story, but let's allow it or hide it.
          // Common pattern: Viewers list for me, Like button for others.
          if (!currentGroup.isMe)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white12,
                onPressed: () {
                  final story = currentGroup.stories[_currentIndex];
                  ref
                      .read(storiesProvider.notifier)
                      .toggleStoryLike(currentGroup.userId, story.id);
                },
                child: Icon(
                  currentGroup.stories.isNotEmpty &&
                          currentGroup.stories[_currentIndex].isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color:
                      currentGroup.stories.isNotEmpty &&
                          currentGroup.stories[_currentIndex].isLiked
                      ? Colors.red
                      : Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
