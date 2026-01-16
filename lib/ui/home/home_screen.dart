import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/providers.dart';
import '../../theme/design_system.dart';
import '../../state/stories_state.dart';
import 'story_viewer_screen.dart';
import '../profile/profile_screen.dart';

// Home feed screen implemented to match the provided static HTML layout.
/*
  Main Home Screen.
  
  The landing page after login.
  Features:
  - Stories Carousel (top)
  - Featured Graduate Spotlight
  - Batch Highlights (horizontal scroll)
  - Main News Feed (vertical scroll)
*/
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
      backgroundColor: DesignSystem.purpleDark,
      body: Container(
        decoration: const BoxDecoration(
          // Subtle gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E0F3A),
              DesignSystem.purpleDark,
              Color(0xFF150518),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              // Top App Bar
              const _HomeAppBar(),

              // Story carousel (horizontal avatars)
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: stories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) =>
                      _StoryAvatar(story: stories[index]),
                ),
              ),

              // Featured Graduate section header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  'Featured Graduate',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ),

              // Featured Graduate card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _FeaturedCard(
                  profileName: profile.name,
                  degreeLine: '${profile.degree} | ${profile.year}',
                ),
              ),

              // Batch Highlights header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Text(
                  "Batch Highlights: Class of '24",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ),

              // Batch highlights carousel
              SizedBox(
                height: 150,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: batches.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) => _BatchCard(
                    title: batches[index].title,
                    subtitle: batches[index].subtitle,
                  ),
                ),
              ),

              // Feed
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: List.generate(
                    feed.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
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
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.purpleAccent.withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: DesignSystem.purpleAccent,
                  child: Icon(
                    Icons.auto_stories,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Chronicles',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 4),
              IconButton(
                // Message
                onPressed: () => Navigator.pushNamed(context, '/messages'),
                icon: const Icon(
                  Icons.messenger_outline_rounded,
                  color: Colors.white,
                ),
                splashRadius: 24,
                tooltip: 'Messages',
              ),
              const SizedBox(width: 4),
              IconButton(
                // Notification
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                splashRadius: 24,
                tooltip: 'Notifications',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
          child: Container(
            width: 74, // size + border spacing
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: story.isMe && story.image == null
                    ? Colors
                          .white24 // Subtle for add
                    : DesignSystem.purpleAccent, // Highlight for stories
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(
              3,
            ), // Spacing between border and image
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
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
                          child: Icon(Icons.person, color: Colors.white54),
                        ),
                        if (story.isMe)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: DesignSystem.purpleAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 74,
          child: Text(
            story.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String profileName;
  final String degreeLine;
  const _FeaturedCard({required this.profileName, required this.degreeLine});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DesignSystem.cardDecoration().copyWith(
        color: const Color(0xFF251029), // Richer dark purple
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: const Color(0xFF3A2738),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.image, size: 48, color: Colors.white12),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  degreeLine,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Meet $profileName and discover their journey.',
                        style: const TextStyle(
                          color: Color(0xFFD6C9E6),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Profile
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'View Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
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

class _BatchCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _BatchCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: DesignSystem.cardDecoration().copyWith(
        color: const Color(0xFF1F0B26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Decorative gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    DesignSystem.purpleAccent.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
  final List<String> _comments = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A0B20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: 400,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text('Comments', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Expanded(
              child: _comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No comments yet.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: DesignSystem.purpleAccent,
                                  child: Icon(
                                    Icons.person,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'You',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _comments[index],
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
                          ),
                        );
                      },
                    ),
            ),
            TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: DesignSystem.purpleAccent,
                  ),
                  onPressed: () {
                    if (_commentController.text.trim().isNotEmpty) {
                      setState(() {
                        _comments.add(_commentController.text.trim());
                        _commentController.clear();
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShare() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A0B20),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share to',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _shareOption(Icons.link, 'Copy Link'),
                _shareOption(Icons.share, 'More'),
                _shareOption(Icons.send, 'Direct'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white10,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DesignSystem.cardDecoration().copyWith(
        color: const Color(0xFF1F0C24), // Darker card bg
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF3A2738),
                  child: Icon(Icons.person, color: Colors.white70),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Class of 2024 • Computer Science',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.white38),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.subtitle,
              style: const TextStyle(
                color: Color(0xFFE0D4F5),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 240,
            color: const Color(0xFF2D1636),
          ), // Placeholder image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleLike,
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.redAccent : Colors.white70,
                  ),
                ),
                Text(
                  '$_likeCount',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _showComments,
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white70,
                  ),
                ),
                const Text(
                  '12',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _showShare,
                  icon: const Icon(Icons.share_outlined, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
