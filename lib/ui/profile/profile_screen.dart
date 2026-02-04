import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/supabase/supabase_service.dart';
import '../../theme/design_system.dart';
import '../../state/profile_state.dart';
import '../../state/portfolio_state.dart';
import '../../core/providers/current_user_provider.dart'; // Added
import '../widgets/custom_app_bar.dart';
import '../widgets/post_card.dart';
import '../widgets/announcement_card.dart';
import '../../state/posts_state.dart';
import '../../settings/settings_main_screen.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../../messaging/ui/chat_screen.dart';
import 'posts/create_post_screen.dart';
import '../announcements/create_announcement_screen.dart';

import '../widgets/global_background.dart';

// Profile screen implemented to match the static HTML profile design.
/*
  User Profile Screen.
  
  Displays the user's personal information and portfolio.
  Features:
  - Header with Profile Picture, Name, Degree
  - Action buttons: Connect (toggle) and Message
  - Tabbed content: Achievements, Projects, Memories
  - Custom toast notification for actions
*/
class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId; // Optional: If null, shows current user
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTab = 0;
  bool _isConnectionLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // 1. Refresh current user regardless (for My Profile check)
    ref.read(profileProvider.notifier).refresh();
    ref.read(currentUserProvider.notifier).refresh();

    // 2. Determine whose profile we are viewing
    final myProfile = ref.read(profileProvider);
    final targetId = widget.userId ?? myProfile.id;

    // 3. Load Portfolio
    if (targetId.isNotEmpty) {
      ref.read(portfolioProvider.notifier).loadPortfolio(targetId);
    }
  }

  void _showCustomToast(String message) {
    // ... existing toast code ...
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 30,
        left: 40,
        right: 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E1A36).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: DesignSystem.purpleAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Determine Current User (Me)
    final myProfile = ref.watch(profileProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    // 2. Determine Target Profile (Displayed User)
    final targetId = widget.userId ?? myProfile.id;
    final isOwner = targetId == myProfile.id || widget.userId == null;

    // 3. Fetch logic
    UserProfile displayProfile = myProfile; // Default to me
    AsyncValue<UserProfile?>? visitedProfileAsync;

    if (!isOwner) {
      // If visiting, watch the other profile provider
      visitedProfileAsync = ref.watch(otherUserProfileProvider(targetId));
      if (visitedProfileAsync?.value != null) {
        displayProfile = visitedProfileAsync!.value!;
      }
    }

    // 4. Connection Status (If visiting)
    String connectionStatus = 'none';
    if (!isOwner && displayProfile.authUserId != null) {
      final statusAsync = ref.watch(
        connectionStatusProvider(displayProfile.authUserId!),
      );
      connectionStatus = statusAsync.value ?? 'none';
    }

    // Handle Loading
    if (!isOwner && visitedProfileAsync?.isLoading == true) {
      return const Scaffold(
        backgroundColor: DesignSystem.scaffoldBg,
        body: Center(
          child: CircularProgressIndicator(color: DesignSystem.purpleAccent),
        ),
      );
    }

    // Safety check if profile not found
    if (!isOwner &&
        visitedProfileAsync?.value == null &&
        visitedProfileAsync?.isLoading == false) {
      return const Scaffold(
        backgroundColor: DesignSystem.scaffoldBg,
        body: Center(
          child: Text('User not found', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            if (isOwner) {
              await ref.read(profileProvider.notifier).refresh();
            } else {
              // Invalidate to force refetch
              ref.invalidate(otherUserProfileProvider(targetId));
              if (displayProfile.authUserId != null) {
                ref.invalidate(
                  connectionStatusProvider(displayProfile.authUserId!),
                );
              }
            }
            if (targetId.isNotEmpty) {
              await ref
                  .read(portfolioProvider.notifier)
                  .loadPortfolio(targetId);
            }
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // App Bar matching design
              CustomAppBar(
                title: 'Profile',
                showLeading: true,
                onLeading: () => Navigator.of(context).pop(),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Owner Only Actions
                    if (isOwner) ...[
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsMainScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              // Profile header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // PART 3: UI Rendering (Provider State)
                    // NOTE: Use displayProfile instead of profile
                    GestureDetector(
                      onTap: () {
                        // Show image
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              backgroundColor: Colors.black,
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                leading: const BackButton(color: Colors.white),
                              ),
                              body: Center(
                                child: Hero(
                                  tag: 'profile_image',
                                  child: displayProfile.profileImage != null
                                      ? Image.network(
                                          displayProfile.profileImage!,
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 150,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'profile_image',
                        child: Container(
                          width: 120,
                          height: 120,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(
                                0xFFE94CFF,
                              ).withValues(alpha: 0.6),
                              width: 2,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2B1F2E),
                              border: Border.all(
                                color: const Color(0xFFE94CFF),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: displayProfile.profileImage != null
                                  ? Image.network(
                                      displayProfile.profileImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 60,
                                              ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayProfile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (displayProfile.username.isNotEmpty) ...[
                      Text(
                        displayProfile.username,
                        style: const TextStyle(
                          color: DesignSystem.purpleAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      '${displayProfile.degree} | ${displayProfile.year}',
                      style: const TextStyle(
                        color: Color(0xFFBDB1C9),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Connection count display
                    Builder(
                      builder: (context) {
                        final countAsync = ref.watch(
                          connectionCountProvider(displayProfile.authUserId),
                        );
                        return countAsync.when(
                          data: (count) => Text(
                            '$count Connection${count == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                if (isOwner) {
                                  // Post Action
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CreatePostScreen(),
                                    ),
                                  );
                                } else {
                                  // Connect Action
                                  if (connectionStatus == 'none') {
                                    // Send Request
                                    try {
                                      setState(
                                        () => _isConnectionLoading = true,
                                      );
                                      final service = ref.read(
                                        supabaseServiceProvider,
                                      );
                                      if (displayProfile.authUserId != null) {
                                        await service.sendConnectionRequest(
                                          displayProfile.authUserId!,
                                        );
                                        _showCustomToast('Request Sent');
                                        ref.invalidate(
                                          connectionStatusProvider(
                                            displayProfile.authUserId!,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      _showCustomToast('Failed to send');
                                    } finally {
                                      if (mounted) {
                                        setState(
                                          () => _isConnectionLoading = false,
                                        );
                                      }
                                    }
                                  } else if (connectionStatus == 'accepted') {
                                    // Disconnect Logic
                                    // Confirm disconnect?
                                    // For now, just disconnect on tap for simplicity or show options
                                    try {
                                      setState(
                                        () => _isConnectionLoading = true,
                                      );
                                      final service = ref.read(
                                        supabaseServiceProvider,
                                      );
                                      if (displayProfile.authUserId != null) {
                                        await service.removeConnection(
                                          displayProfile.authUserId!,
                                        );
                                        _showCustomToast('Disconnected');
                                        // Invalidate status and count
                                        ref.invalidate(
                                          connectionStatusProvider(
                                            displayProfile.authUserId!,
                                          ),
                                        );
                                        ref.invalidate(
                                          connectionCountProvider(
                                            displayProfile.authUserId!,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      _showCustomToast('Failed to disconnect');
                                    } finally {
                                      if (mounted) {
                                        setState(
                                          () => _isConnectionLoading = false,
                                        );
                                      }
                                    }
                                  } else if (connectionStatus ==
                                      'pending_sent') {
                                    // Maybe cancel? For now, just show toast
                                    _showCustomToast('Request already sent');
                                  }
                                }
                              },
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isOwner
                                      ? DesignSystem.purpleAccent
                                      : (connectionStatus == 'accepted'
                                            ? const Color(0xFF2D2433)
                                            : DesignSystem.purpleAccent),
                                  borderRadius: BorderRadius.circular(21),
                                  border:
                                      (connectionStatus == 'accepted' ||
                                          connectionStatus == 'pending_sent')
                                      ? Border.all(color: Colors.white24)
                                      : null,
                                ),
                                child: Center(
                                  child: _isConnectionLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          isOwner
                                              ? 'Post'
                                              : (connectionStatus == 'accepted'
                                                    ? 'Connected'
                                                    : (connectionStatus ==
                                                              'pending_sent'
                                                          ? 'Sent'
                                                          : 'Connect')),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          // Announcement button (owner only + restricted roles)
                          if (isOwner &&
                              (displayProfile.role.toLowerCase() == 'staff' ||
                                  displayProfile.role.toLowerCase() ==
                                      'alumni' ||
                                  displayProfile.role.toLowerCase() ==
                                      'graduate')) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const CreateAnnouncementScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2D1F3D),
                                    borderRadius: BorderRadius.circular(21),
                                    border: Border.all(
                                      color: DesignSystem.purpleAccent
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.campaign_rounded,
                                          color: DesignSystem.purpleAccent,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Announce',
                                          style: TextStyle(
                                            color: DesignSystem.purpleAccent,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (!isOwner) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final authUserId = displayProfile.authUserId;
                                  if (authUserId == null) {
                                    _showCustomToast('User not found');
                                    return;
                                  }

                                  try {
                                    final convoId = await ref
                                        .read(conversationsProvider.notifier)
                                        .startConversation(authUserId);

                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatScreen(
                                            conversationId: convoId,
                                            participantName:
                                                displayProfile.name,
                                            participantAvatar:
                                                displayProfile.profileImage,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      _showCustomToast('Could not start chat');
                                    }
                                  }
                                },
                                child: Container(
                                  height: 42, // Reduced height
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF231B26),
                                    borderRadius: BorderRadius.circular(21),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Message',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bio Section
              if (displayProfile.bio.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B141E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      displayProfile.bio,
                      style: const TextStyle(
                        color: Color(0xFFD6C9E6),
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              // Interests/Skills Chips
              if (displayProfile.interests.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: displayProfile.interests.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) =>
                        _interestChip(displayProfile.interests[index]),
                  ),
                ),

              const SizedBox(height: 32),

              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF2D2433), width: 1),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _tabItem(0, 'Announcements'),
                      _tabItem(1, 'Achievements'),
                      _tabItem(2, 'Resumes'),
                      _tabItem(3, 'Certificates'),
                      _tabItem(4, 'Links'),
                      _tabItem(5, 'Posts'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Content based on tab
              // Use portfolioProvider state
              Builder(
                builder: (context) {
                  final portfolio = ref.watch(portfolioProvider);

                  if (portfolio.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: DesignSystem.purpleAccent,
                        ),
                      ),
                    );
                  }

                  // Handle Announcements tab (index 0)
                  if (_selectedTab == 0) {
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: ref
                          .read(supabaseServiceProvider)
                          .fetchAnnouncementsByUser(targetId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: DesignSystem.purpleAccent,
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No announcements yet.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          );
                        }
                        final announcements = snapshot.data!.map((p) {
                          return PostItem.fromMap(p);
                        }).toList();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: announcements
                                .map((a) => AnnouncementCard(announcement: a))
                                .toList(),
                          ),
                        );
                      },
                    );
                  }

                  // Handle Posts tab (index 5) separately
                  if (_selectedTab == 5) {
                    // Fetch and display user's posts
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: ref
                          .read(supabaseServiceProvider)
                          .fetchPostsByUser(targetId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: DesignSystem.purpleAccent,
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No posts yet.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          );
                        }
                        final posts = snapshot.data!.map((p) {
                          return PostItem.fromMap(p);
                        }).toList();
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: posts
                                .map((post) => PostCard(post: post))
                                .toList(),
                          ),
                        );
                      },
                    );
                  }

                  List<Map<String, dynamic>> items = [];
                  if (_selectedTab == 1) {
                    items = portfolio.achievements;
                  } else if (_selectedTab == 2) {
                    items = portfolio.resumes;
                  } else if (_selectedTab == 3) {
                    items = portfolio.certificates;
                  } else if (_selectedTab == 4) {
                    items = portfolio.links;
                  }

                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No items found.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: items.map((item) {
                        // Map fields based on type
                        String title = '';
                        String subtitle = '';

                        if (_selectedTab == 0) {
                          title = item['title'] ?? 'Untitled';
                          subtitle = item['description'] ?? 'No description';
                        } else if (_selectedTab == 1) {
                          title = item['file_name'] ?? 'Resume';
                          subtitle = item['notes'] ?? '';
                        } else if (_selectedTab == 2) {
                          title = item['certificate_name'] ?? 'Certificate';
                          subtitle = item['issuing_organization'] ?? '';
                        } else if (_selectedTab == 3) {
                          title = item['title'] ?? 'Link';
                          subtitle = item['url'] ?? '';
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _AchievementCard(
                            title: title,
                            subtitle: subtitle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _interestChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B1F2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFFE94CFF), fontSize: 13),
        ),
      ),
    );
  }

  Widget _tabItem(int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3D1F47) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE94CFF)
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFE94CFF)
                : const Color(0xFFBDB1C9),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _AchievementCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B141E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2D1B36),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: Color(0xFFE94CFF),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFBDB1C9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
