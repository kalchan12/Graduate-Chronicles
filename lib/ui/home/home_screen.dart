import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../state/profile_state.dart';
import '../../state/notification_state.dart';
import '../../theme/design_system.dart';
import '../../state/stories_state.dart';
import 'story_card.dart';
import '../../state/post_recommendation_state.dart';
import '../widgets/post_card.dart';

import '../widgets/announcement_carousel.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/skeleton.dart';

import '../../services/supabase/supabase_service.dart';
import '../../messaging/providers/messaging_provider.dart';

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
    final feed = ref.watch(personalizedFeedProvider);
    final stories = ref.watch(storiesProvider);

    // Initial Loading State (Skeleton)
    if (profile.id.isEmpty) {
      return const _HomeSkeleton();
    }

    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBackground(context),
      body: Container(
        decoration: BoxDecoration(
          // Theme-aware gradient background
          gradient: DesignSystem.backgroundGradient(context),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                ref.read(profileProvider.notifier).refresh(),
                ref.read(personalizedFeedProvider.notifier).refresh(),
              ]);
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
                      return StoryCard(group: group);
                    },
                  ),
                ),

                // Featured Graduate section header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    'Featured Graduates',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 20),
                  ),
                ),

                // Featured Graduate carousel (data-driven from yearbook entries)
                // Uses current user's graduation year for batch filtering
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Builder(
                    builder: (context) {
                      // Get dynamic batch year from current user's profile
                      final batchYear =
                          int.tryParse(profile.year) ?? DateTime.now().year;

                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: ref
                            .read(supabaseServiceProvider)
                            .fetchRandomYearbookEntries(
                              limit: 10,
                              batchYear: batchYear,
                            ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: 450,
                              child: PageView.builder(
                                controller: PageController(
                                  viewportFraction: 0.85,
                                ),
                                itemCount: 3,
                                itemBuilder: (_, _) =>
                                    const SkeletonFeaturedCard(),
                              ),
                            );
                          }

                          // Empty state
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              height: 100,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'No featured graduates for $batchYear yet',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }

                          final items = snapshot.data!
                              .map((m) => FeaturedItem.fromMap(m))
                              .toList();
                          return FeaturedCarousel(
                            items: items,
                            height: 450,
                            onItemTap: (item) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProfileScreen(userId: item.id),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // Announcements Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  child: Row(
                    children: [
                      Text(
                        'Latest Updates',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.redAccent.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: const Text(
                          'NEWS',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Announcements Carousel
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: ref
                      .read(supabaseServiceProvider)
                      .fetchLatestAnnouncements(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 200,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: 2,
                          separatorBuilder: (_, _) => const SizedBox(width: 16),
                          itemBuilder: (_, _) => Container(
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      );
                    }

                    final announcements = snapshot.data ?? [];
                    return AnnouncementCarousel(
                      announcements: announcements,
                      onItemTap: (item) {
                        // TODO: Navigate to detail view or expand
                        // For now just show a simple bottom sheet or dialog
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: const Color(0xFF1E1E2E),
                          isScrollControlled:
                              true, // Allow full height flexibility
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (context) {
                            final description = item['description'] ?? '';
                            final List<dynamic> mediaUrls =
                                item['media_urls'] ?? [];
                            final String? image = mediaUrls.isNotEmpty
                                ? mediaUrls.first as String
                                : null;

                            return DraggableScrollableSheet(
                              initialChildSize: 0.85,
                              minChildSize: 0.5,
                              maxChildSize: 0.95,
                              expand: false,
                              builder: (context, scrollController) {
                                return Column(
                                  children: [
                                    // Drag Handle
                                    Center(
                                      child: Container(
                                        width: 40,
                                        height: 4,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Content
                                    Expanded(
                                      child: ListView(
                                        controller: scrollController,
                                        padding: const EdgeInsets.fromLTRB(
                                          20,
                                          0,
                                          20,
                                          32,
                                        ),
                                        children: [
                                          // Title (Catchy & Large)
                                          Text(
                                            'ANNOUNCEMENT',
                                            style: GoogleFonts.outfit(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const SizedBox(height: 24),

                                          // Image (if available)
                                          if (image != null)
                                            Container(
                                              height: 240,
                                              width: double.infinity,
                                              margin: const EdgeInsets.only(
                                                bottom: 24,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                                image: DecorationImage(
                                                  image: NetworkImage(image),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),

                                          // Description text with Background Container
                                          Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF2E1A47,
                                              ).withValues(alpha: 0.5),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.05,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              description,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white70,
                                                fontSize: 18,
                                                height: 1.6,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ),

                                          // Bottom padding
                                          const SizedBox(height: 32),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                // Feed
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              DesignSystem.purpleAccent,
                              DesignSystem.purpleAccent.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'For You',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Personalized Feed',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
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
                        children: posts.map((post) {
                          // Conditional rendering based on contentKind
                          if (post.contentKind == 'announcement') {
                            debugPrint(
                              '[FEED] Skipping announcement in main feed (id=${post.id})',
                            );
                            return const SizedBox.shrink(); // Hide from feed as it's in carousel
                          } else if (post.contentKind != 'post') {
                            debugPrint(
                              '[FEED_RENDER] Warning: Unknown contentKind "${post.contentKind}" for post ${post.id}. Rendering as PostCard.',
                            );
                          }
                          return PostCard(
                            post: post,
                            onLike: (id) {
                              ref
                                  .read(personalizedFeedProvider.notifier)
                                  .toggleLike(id);
                              // Feedback instantly provided by local state in PostCard + this provider update
                            },
                            onComment: (id) {
                              ref
                                  .read(personalizedFeedProvider.notifier)
                                  .incrementCommentCount(id);
                            },
                          );
                        }).toList(),
                      );
                    },
                    loading: () => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 2,
                      itemBuilder: (_, _) => const SkeletonPostCard(),
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

class _HomeAppBar extends ConsumerWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch notifications state
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadNotificationsCount =
        notificationsAsync.asData?.value.where((n) => !n.isRead).length ?? 0;

    // Watch unread message count
    final unreadCountAsync = ref.watch(unreadMessageCountProvider);
    final unreadCount = unreadCountAsync.asData?.value ?? 0;

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
                  color: DesignSystem.textPrimary(context),
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
                icon: Icon(
                  Icons.search,
                  color: DesignSystem.textPrimary(context),
                ),
                splashRadius: 24,
                tooltip: 'Discover Classmates',
              ),
              const SizedBox(width: 4),
              Stack(
                children: [
                  IconButton(
                    // Message
                    onPressed: () => Navigator.pushNamed(context, '/messages'),
                    icon: Icon(
                      Icons.messenger_outline_rounded,
                      color: DesignSystem.textPrimary(context),
                    ),
                    splashRadius: 24,
                    tooltip: 'Messages',
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2E0F3A),
                            width: 1.5,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
              Stack(
                children: [
                  IconButton(
                    // Notification
                    onPressed: () =>
                        Navigator.pushNamed(context, '/notifications'),
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: DesignSystem.textPrimary(context),
                    ),
                    splashRadius: 24,
                    tooltip: 'Notifications',
                  ),
                  if (unreadNotificationsCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2E0F3A),
                            width: 1.5,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadNotificationsCount > 9
                              ? '9+'
                              : unreadNotificationsCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
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
  _FeaturedCard class removed in favor of FeaturedCarousel widget.
*/

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBackground(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: DesignSystem.backgroundGradient(context),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const _HomeAppBar(),
              const SizedBox(height: 12),
              // Stories Skeleton
              SizedBox(
                height: 110,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  itemBuilder: (_, _) => const SkeletonStoryCard(),
                ),
              ),
              const SizedBox(height: 24),
              // Featured Header Skeleton
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const SkeletonBase(
                  height: 24,
                  width: 200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Featured Carousel Skeleton
              SizedBox(
                height: 450,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  itemCount: 3,
                  itemBuilder: (_, _) => const SkeletonFeaturedCard(),
                ),
              ),
              const SizedBox(height: 32),
              // Feed Header Skeleton
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const SkeletonBase(
                  height: 24,
                  width: 150,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Feed Skeleton
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 2,
                itemBuilder: (_, _) => const SkeletonPostCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
