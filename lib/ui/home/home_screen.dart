import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers.dart';
import '../../state/profile_state.dart';
import '../../theme/design_system.dart';
import '../../state/stories_state.dart';
import 'story_viewer_screen.dart';
import 'story_card.dart';
import '../stories/story_uploader.dart';
import '../../state/posts_state.dart';
import '../widgets/post_card.dart';

import '../profile/profile_screen.dart';
import '../../messaging/ui/discover_screen.dart';

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
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure profile data and stories are loaded on Home (first screen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).refresh();
      ref.read(storiesProvider.notifier).loadStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read providers for dynamic mock content.
    final profile = ref.watch(profileProvider);
    final batches = ref.watch(batchProvider);
    final feed = ref.watch(feedProvider);
    final stories = ref.watch(storiesProvider);

    // Initial Loading State (Skeleton)
    if (profile.id.isEmpty) {
      return const _HomeSkeleton();
    }

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
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(profileProvider.notifier).refresh();
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 96),
              physics: const AlwaysScrollableScrollPhysics(),
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
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final group = stories[index];
                      return StoryCard(
                        group: group,
                        onAddStory: () {
                          StoryUploader(context, ref).pickAndUpload();
                        },
                        onViewStory: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StoryViewerScreen(userGroup: group),
                            ),
                          );
                        },
                      );
                    },
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
                  child: feed.when(
                    data: (posts) {
                      if (posts.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No posts yet. Be the first to share!',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: posts
                            .map((post) => PostCard(post: post))
                            .toList(),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: DesignSystem.purpleAccent,
                      ),
                    ),
                    error: (e, st) => Center(
                      child: Text(
                        'Error loading feed: $e',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DiscoverScreen()),
                  );
                },
                icon: const Icon(Icons.search, color: Colors.white),
                splashRadius: 24,
                tooltip: 'Discover Classmates',
              ),
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

/*
  _StoryAvatar class removed in favor of the specialized StoryCard component.
*/

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

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.purpleDark,
      body: Container(
        decoration: const BoxDecoration(
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
              const _HomeAppBar(),
              const SizedBox(height: 12),
              // Stories Skeleton
              SizedBox(
                height: 110,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, __) => const _SkeletonAvatar(),
                ),
              ),
              const SizedBox(height: 24),
              // Featured Skeleton
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 24,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Batch Skeleton
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 24,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, __) => Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
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

class _SkeletonAvatar extends StatefulWidget {
  const _SkeletonAvatar();

  @override
  State<_SkeletonAvatar> createState() => _SkeletonAvatarState();
}

class _SkeletonAvatarState extends State<_SkeletonAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 0.6).animate(_controller),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Container(width: 60, height: 10, color: Colors.white),
        ],
      ),
    );
  }
}
