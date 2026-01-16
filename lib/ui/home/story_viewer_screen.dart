import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/stories_state.dart';
import '../../theme/design_system.dart';

/*
  Full Screen Story Viewer.
  
  Displays a story for a limited time (10s) with a progress bar.
  Features:
  - Auto-advance timer
  - Full screen image
  - Like interaction
  - Swipe down to close
*/
class StoryViewerScreen extends ConsumerStatefulWidget {
  final String storyId;
  const StoryViewerScreen({super.key, required this.storyId});

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _progressController.addListener(() {
      if (_progressController.isCompleted) {
        Navigator.of(context).pop();
      }
    });

    _progressController.forward();

    // Increment views when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storiesProvider.notifier).incrementViews(widget.storyId);
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stories = ref.watch(storiesProvider);
    final story = stories.firstWhere(
      (s) => s.id == widget.storyId,
      orElse: () => stories.first,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 500) {
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: story.image != null
                  ? Image.file(story.image!, fit: BoxFit.contain)
                  : Container(
                      color: DesignSystem.purpleDark,
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white10,
                          size: 120,
                        ),
                      ),
                    ),
            ),

            // Top Progress Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              right: 10,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _progressController.value,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                minHeight: 4,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        story.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Actions
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${story.views}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ref.read(storiesProvider.notifier).toggleLike(story.id);
                    },
                    child: AnimatedScale(
                      scale: story.isLiked ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        story.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: story.isLiked ? Colors.red : Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
