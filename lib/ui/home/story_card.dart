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
                child: CustomPaint(
                  painter: StoryRingPainter(
                    storyCount: group.stories.length,
                    isLiked: group.isLiked,
                    isMe: group.isMe,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        backgroundImage: group.profilePicUrl != null && group.profilePicUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(group.profilePicUrl!)
                            : null,
                        child: group.profilePicUrl == null || group.profilePicUrl!.isEmpty
                            ? Icon(
                                Icons.person,
                                color: DesignSystem.textSubtle(context),
                              )
                            : null,
                      ),
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
            style: TextStyle(
              color: DesignSystem.textSubtle(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class StoryRingPainter extends CustomPainter {
  final int storyCount;
  final bool isLiked;
  final bool isMe;

  StoryRingPainter({
    required this.storyCount,
    required this.isLiked,
    required this.isMe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (storyCount == 0) {
      if (!isMe) {
        // Draw dull border for others with no stories
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = Colors.white24;
        canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
      }
      return;
    }

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final double strokeWidth = 3.0;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (isLiked) {
      paint.color = Colors.grey.withValues(alpha: 0.8);
    } else {
      paint.shader = const LinearGradient(
        colors: [Color(0xFFE94CFF), Color(0xFF7B2CBF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    }

    final double totalSweep = 2 * 3.14159265;
    // Spacing between segments (approx 6 degrees if multiple)
    final double space = storyCount > 1 ? (6 * 3.14159265 / 180) : 0.0;
    final double sweepAngle = (totalSweep - (space * storyCount)) / storyCount;

    double startAngle = -3.14159265 / 2; // Start at top

    for (int i = 0; i < storyCount; i++) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width - strokeWidth,
          height: size.height - strokeWidth,
        ),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle + space;
    }
  }

  @override
  bool shouldRepaint(covariant StoryRingPainter oldDelegate) {
    return oldDelegate.storyCount != storyCount || oldDelegate.isLiked != isLiked;
  }
}
