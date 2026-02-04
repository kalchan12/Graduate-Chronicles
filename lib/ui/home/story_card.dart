import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/stories_state.dart';
import '../../theme/design_system.dart';
import 'story_viewer_screen.dart';
import '../stories/story_uploader.dart';

class StoryCard extends ConsumerWidget {
  final UserStoryGroup group;

  const StoryCard({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Logic:
    // If it's me:
    //   - If I have stories: View them (click circle).
    //   - If NO stories: Tap circle -> Add.
    // If other:
    //   - Tap circle -> View.

    final bool isMe = group.isMe;
    final bool hasStories = group.hasStories;

    void onViewStory() {
      if (!hasStories) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => StoryViewerScreen(userGroup: group)),
      );
    }

    void onAddStory() {
      // StoryUploader is a helper class, not a screen.
      // We trigger the pick and upload flow directly.
      StoryUploader(context, ref).pickAndUpload();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (hasStories) {
                    onViewStory();
                  } else if (isMe) {
                    // If it's me and no stories, tapping circle triggers add
                    onAddStory();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        hasStories &&
                            !group
                                .isLiked // "Unseen" color
                        ? const LinearGradient(
                            colors: [Color(0xFFE94CFF), Color(0xFF7B2CBF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: !hasStories && !isMe
                        ? Border.all(color: Colors.white24, width: 2)
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[900],
                      backgroundImage: group.profilePicUrl != null
                          ? CachedNetworkImageProvider(group.profilePicUrl!)
                          : null,
                      child: group.profilePicUrl == null
                          ? const Icon(Icons.person, color: Colors.white54)
                          : null,
                    ),
                  ),
                ),
              ),
              if (isMe)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap:
                        onAddStory, // STRICT: Always opens upload, never viewer
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: DesignSystem.purpleAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            group.username.length > 10
                ? '${group.username.substring(0, 9)}...'
                : group.username,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
