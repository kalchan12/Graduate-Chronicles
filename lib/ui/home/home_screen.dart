import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/providers.dart';
import '../../theme/design_system.dart';
import '../../state/stories_state.dart';
import 'story_viewer_screen.dart';

// Home feed screen implemented to match the provided static HTML layout.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read providers for dynamic mock content.
    final profile = ref.watch(profileProvider);
    final batches = ref.watch(batchProvider);
    final feed = ref.watch(feedProvider);
    final stories = ref.watch(storiesProvider);

    return Scaffold(
      // Use shared scaffold background from DesignSystem.
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            // Top App Bar (reusable widget)
            const _HomeAppBar(),

            // Story carousel (horizontal avatars)
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: stories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) =>
                    _StoryAvatar(story: stories[index]),
              ),
            ),

            // Featured Graduate section header
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                'Featured Graduate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Featured Graduate card using profile provider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FeaturedCard(
                profileName: profile.name,
                degreeLine: '${profile.degree} | ${profile.year}',
              ),
            ),

            // Batch Highlights header
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 6),
              child: Text(
                "Batch Highlights: Class of '24",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Batch highlights carousel driven by batchProvider
            SizedBox(
              height: 140,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: batches.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _BatchCard(
                  title: batches[index].title,
                  subtitle: batches[index].subtitle,
                ),
              ),
            ),

            // Standard post cards - render feed items from feedProvider
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(
                  feed.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _PostCard(
                      title: feed[i].title,
                      subtitle: feed[i].subtitle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable app bar widget matching the HTML header visuals.
class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: DesignSystem.scaffoldBg.withValues(alpha: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              // School icon placeholder
              CircleAvatar(
                radius: 20,
                backgroundColor: DesignSystem.purpleAccent,
                child: Icon(Icons.school, color: Colors.white),
              ),
              SizedBox(width: 10),
              Text(
                'Chronicles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Message and notifications icons
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/messages'),
                child: const _IconCircle(icon: Icons.mail_outline),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
                child: const _IconCircle(icon: Icons.notifications_none),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Small circular icon used in the app bar (visual only).
class _IconCircle extends StatelessWidget {
  final IconData icon;
  const _IconCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: DesignSystem.purpleMid,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

// Story avatar widget used in the horizontal story carousel.
class _StoryAvatar extends ConsumerWidget {
  final Story story;
  const _StoryAvatar({required this.story});

  Future<void> _pickImage(WidgetRef ref) async {
    final status = await Permission.photos.request();
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ref.read(storiesProvider.notifier).addStory(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (story.isMe && story.image == null) {
              _pickImage(ref);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => StoryViewerScreen(storyId: story.id),
                ),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: story.isMe && story.image == null
                    ? DesignSystem.purpleAccent
                    : Colors.transparent,
                width: 2,
              ),
              color: const Color(0xFF2B2630),
              image: story.image != null
                  ? DecorationImage(
                      image: FileImage(story.image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: story.image == null
                ? Stack(
                    children: [
                      const Center(
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      if (story.isMe)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
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
                    ],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 72,
          child: Text(
            story.name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFD6C9E6), fontSize: 12),
          ),
        ),
      ],
    );
  }
}

// Featured graduate card widget using profile data supplied externally.
class _FeaturedCard extends StatelessWidget {
  final String profileName;
  final String degreeLine;
  const _FeaturedCard({required this.profileName, required this.degreeLine});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A1727),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image placeholder (aspect video)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(color: const Color(0xFF3A2738)),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  degreeLine,
                  style: const TextStyle(color: Color(0xFFBDB1C9)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Meet $profileName; discover her journey.',
                        style: const TextStyle(
                          color: Color(0xFFBDB1C9),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: DesignSystem.purpleAccent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'View Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Batch highlight card widget (horizontal carousel item).
class _BatchCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _BatchCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF332236),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Color(0xFFBDB1C9))),
          ],
        ),
      ),
    );
  }
}

// Standard post card used for feed items; uses dynamic title/subtitle.
class _PostCard extends StatefulWidget {
  final String title;
  final String subtitle;
  const _PostCard({required this.title, required this.subtitle});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _isLiked = false;
  int _likeCount = 128;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        backgroundColor: DesignSystem.purpleMid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A1727),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3A2738),
                  ),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Class of 2024 • Computer',
                        style: TextStyle(
                          color: Color(0xFFBDB1C9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: Colors.white54),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              widget.subtitle,
              style: const TextStyle(color: Color(0xFFD6C9E6)),
            ),
          ),
          const SizedBox(height: 8),
          // Image placeholder (square)
          Container(height: 180, color: const Color(0xFF3A2738)),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Like
                InkWell(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_likeCount',
                        style: const TextStyle(color: Color(0xFFBDB1C9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => _showComingSoon('Comments'),
                  child: Row(
                    children: const [
                      Icon(Icons.chat_bubble_outline, color: Colors.white54),
                      SizedBox(width: 8),
                      Text('12', style: TextStyle(color: Color(0xFFBDB1C9))),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white54),
                  onPressed: () => _showComingSoon('Sharing'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
