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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<StoryItem> storyItems = widget.userGroup.stories.map((story) {
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
          GestureDetector(
            onVerticalDragUpdate: (details) {
              // Simple swipe down to dismiss
              if (details.delta.dy > 10) {
                Navigator.pop(context);
              }
            },
            child: StoryView(
              storyItems: storyItems,
              controller: _controller,
              onComplete: () {
                Navigator.pop(context);
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
              onStoryShow: (s, index) {
                // Potential analytics or state updates
              },
            ),
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
                      widget.userGroup.profilePicUrl != null &&
                          widget.userGroup.profilePicUrl!.isNotEmpty
                      ? NetworkImage(widget.userGroup.profilePicUrl!)
                      : null,
                  child: widget.userGroup.profilePicUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.userGroup.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Bottom Liquid UI state (Like button overlay)
          // Since story_view covers the screen, we can overlay buttons if needed.
          // Note: story_view has its own tap handlers, so we must ensure overlays don't block navigation taps
          // unless specifically needed.
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white12,
              onPressed: () {
                // Local UI like interaction - state update via provider
                // In a real app, this would update Supabase
              },
              child: const Icon(Icons.favorite_border, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
