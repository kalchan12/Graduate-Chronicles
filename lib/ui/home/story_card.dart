import 'package:flutter/material.dart';
import '../../state/stories_state.dart';
import '../../theme/design_system.dart';

class StoryCard extends StatelessWidget {
  final UserStoryGroup group;
  final VoidCallback onAddStory;
  final VoidCallback onViewStory;

  const StoryCard({
    super.key,
    required this.group,
    required this.onAddStory,
    required this.onViewStory,
  });

  @override
  Widget build(BuildContext context) {
    const double size =
        72; // External size matching existing design if possible

    final hasStories = group.hasStories;
    final isMe = group.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Main interaction zone (Big Circle)
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
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Gradient border if has active stories
                    border:
                        hasStories &&
                            !group
                                .isMe // My story logic might differ, but usually gradient if stories exist
                        ? Border.all(
                            color: Colors.transparent,
                            width: 2,
                          ) // handled by gradient container usually
                        : null,
                    gradient: hasStories
                        ? const LinearGradient(
                            colors: [Color(0xFF8A3FFC), Color(0xFFDA1E28)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.all(
                    2.5,
                  ), // gap between border and image
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          Colors.black, // background between border and image
                    ),
                    padding: const EdgeInsets.all(
                      2,
                    ), // another small gap or just fit
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[900],
                      backgroundImage: group.profilePicUrl != null
                          ? NetworkImage(group.profilePicUrl!)
                          : null,
                      child: group.profilePicUrl == null
                          ? const Icon(Icons.person, color: Colors.white54)
                          : null,
                    ),
                  ),
                ),
              ),

              // 2. Plus Icon (Only for "Me")
              if (isMe)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap:
                        onAddStory, // STRICT: Always opens upload, never viewer
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: DesignSystem.purpleAccent, // Purple
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Username
          SizedBox(
            width: size + 10,
            child: Text(
              group.username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
