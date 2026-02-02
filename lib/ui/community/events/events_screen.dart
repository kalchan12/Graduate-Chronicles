import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../services/supabase/supabase_service.dart';
import '../../../theme/design_system.dart';
import '../../../models/community_event.dart';
import '../../widgets/global_background.dart';
import '../../widgets/featured_carousel.dart';

/*
  EventsScreen
  
  Landing page for Events.
  - Shows 3 Category Cards: 100 Day, 50 Day, Other.
  - Navigates to a feed view for the selected category.
*/
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String? _selectedCategory; // If null, show categories. If set, show feed.

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _backToCategories() {
    setState(() {
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (_selectedCategory != null) {
                          _backToCategories();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCategory ?? 'Events Gallery',
                      style: DesignSystem.theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _selectedCategory == null
                    ? _CategorySelection(onSelect: _selectCategory)
                    : EventsFeed(category: _selectedCategory!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySelection extends StatelessWidget {
  final Function(String) onSelect;

  const _CategorySelection({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        _CategoryCard(
          title: "100 Day",
          subtitle: "Centennial Celebration",
          icon: Icons.star_rate_rounded,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ], // Deep Purple -> Royal Blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () => onSelect('100 Day'),
        ),
        const SizedBox(height: 24),
        _CategoryCard(
          title: "50 Day",
          subtitle: "Halfway There!",
          icon: Icons.hourglass_top_rounded,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF416C),
              Color(0xFFFF4B2B),
            ], // Hot Pink -> Red Orange
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () => onSelect('50 Day'),
        ),
        const SizedBox(height: 24),
        _CategoryCard(
          title: "Other",
          subtitle: "Special Moments & Memories",
          icon: Icons.auto_awesome_mosaic_rounded,
          gradient: const LinearGradient(
            colors: [
              Color(0xFF11998E),
              Color(0xFF38EF7D),
            ], // Deep Teal -> Bright Green
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () => onSelect('Other'),
        ),
        const SizedBox(height: 40), // Bottom padding
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: const Color(0xff8E2DE2).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative Big Icon Background
            Positioned(
              right: -30,
              bottom: -30,
              child: Transform.rotate(
                angle: -0.2,
                child: Icon(
                  icon,
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),

            // Glass/Noise Effect Overlay (Optional, simulated with gradient)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Material Splash
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: Colors.white.withValues(alpha: 0.1),
                  highlightColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
  EventsFeed
  
  Displays the masonry grid for a specific category.
  Handles filtering and fetching.
*/
class EventsFeed extends ConsumerStatefulWidget {
  final String category;

  const EventsFeed({super.key, required this.category});

  @override
  ConsumerState<EventsFeed> createState() => _EventsFeedState();
}

class _EventsFeedState extends ConsumerState<EventsFeed> {
  // Filters
  int? _selectedBatch;
  String? _selectedSchool;
  String? _selectedMajor;
  String? _selectedProgram;

  // Data
  bool _isLoading = true;
  List<CommunityEvent> _events = [];

  // User Role Check
  bool _canPost = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _fetchEvents();
  }

  Future<void> _checkUserRole() async {
    final user = ref.read(supabaseServiceProvider).currentUser;
    if (user != null) {
      final profile = await ref
          .read(supabaseServiceProvider)
          .fetchUserProfile(user.id);
      if (profile != null && profile['role'] == 'Graduate') {
        setState(() {
          _canPost = true;
        });
      }
    }
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final rawData = await ref
          .read(supabaseServiceProvider)
          .fetchCommunityEvents(
            category: widget.category,
            batchYear: _selectedBatch,
            school: _selectedSchool,
            major: _selectedMajor,
            program: _selectedProgram,
          );

      if (mounted) {
        setState(() {
          _events = rawData.map((e) => CommunityEvent.fromJson(e)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        // Show error snackbar instead of showing error screen?
        // User asked for "flutter error handling mechanism".
        // A snackbar is a mechanism, but let's also show an error state widget if empty.
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load events: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSheet(
        initialBatch: _selectedBatch,
        initialSchool: _selectedSchool,
        initialMajor: _selectedMajor,
        initialProgram: _selectedProgram,
        onApply: (batch, school, major, program) {
          setState(() {
            _selectedBatch = batch;
            _selectedSchool = school;
            _selectedMajor = major;
            _selectedProgram = program;
          });
          _fetchEvents();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Featured Events Carousel
          FutureBuilder<List<Map<String, dynamic>>>(
            future: ref
                .read(supabaseServiceProvider)
                .fetchRandomEvents(limit: 5),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }
              final items = snapshot.data!
                  .map((m) => FeaturedItem.fromMap(m))
                  .toList();
              return Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 12),
                child: FeaturedCarousel(items: items, height: 140),
              );
            },
          ),

          // Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_selectedBatch != null ||
                    _selectedSchool != null ||
                    _selectedMajor != null ||
                    _selectedProgram != null)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedBatch != null)
                            _buildFilterChip('Batch: $_selectedBatch'),
                          if (_selectedSchool != null)
                            _buildFilterChip('$_selectedSchool'),
                          if (_selectedMajor != null)
                            _buildFilterChip('$_selectedMajor'),
                          if (_selectedProgram != null)
                            _buildFilterChip('$_selectedProgram'),
                          IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedBatch = null;
                                _selectedSchool = null;
                                _selectedMajor = null;
                                _selectedProgram = null;
                              });
                              _fetchEvents();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: _showFilterSheet,
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_busy,
                          color: Colors.white38,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No ${widget.category} events yet.",
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        return _EventCard(event: _events[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _canPost
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/community/events/create',
                  arguments: {
                    'category': widget.category,
                  }, // Pass category context
                );
                if (result == true) {
                  _fetchEvents(); // Refresh after post
                }
              },
              backgroundColor: DesignSystem.purpleAccent,
              icon: const Icon(Icons.add_a_photo, color: Colors.white),
              label: const Text("Post", style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: DesignSystem.purpleAccent.withValues(alpha: 0.2),
        side: const BorderSide(color: DesignSystem.purpleAccent),
        padding: const EdgeInsets.all(4),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final CommunityEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final coverImage = event.mediaUrls.isNotEmpty
        ? event.mediaUrls.first
        : 'https://placehold.co/400x400/png?text=No+Image';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // More rounded
        color: const Color(
          0xFF1E1E1E,
        ), // Slightly lighter, closer to DesignSystem.surface
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Stack(
            children: [
              // Display first image
              AspectRatio(
                // Dynamically adjust ratio if possible, or fixed for grid
                aspectRatio: 1,
                child: Image.network(
                  coverImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey.shade900),
                ),
              ),
              if (event.mediaType == 'video')
                const Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white70,
                      size: 48,
                    ),
                  ),
                ),
              if (event.mediaUrls.length > 1)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.grid_view_rounded, // Better icon
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${event.mediaUrls.length - 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.caption != null && event.caption!.isNotEmpty)
                  Text(
                    event.caption!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12, // Slightly larger
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: NetworkImage(
                        event.userProfilePic ??
                            'https://ui-avatars.com/api/?name=${event.username ?? "User"}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.username ?? "Unknown",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _LikeButton(
                      eventId: event.id,
                      initialCount: event.likeCount,
                      initialLiked: event.isLikedByMe,
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

class _LikeButton extends ConsumerStatefulWidget {
  final String eventId;
  final int initialCount;
  final bool initialLiked;

  const _LikeButton({
    required this.eventId,
    required this.initialCount,
    required this.initialLiked,
  });

  @override
  ConsumerState<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<_LikeButton> {
  late bool isLiked;
  late int count;

  @override
  void initState() {
    super.initState();
    isLiked = widget.initialLiked;
    count = widget.initialCount;
  }

  Future<void> _toggle() async {
    setState(() {
      isLiked = !isLiked;
      count += isLiked ? 1 : -1;
    });

    try {
      await ref.read(supabaseServiceProvider).toggleEventLike(widget.eventId);
    } catch (e) {
      setState(() {
        isLiked = !isLiked;
        count += isLiked ? 1 : -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Row(
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: isLiked ? Colors.redAccent : Colors.white54,
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final int? initialBatch;
  final String? initialSchool;
  final String? initialMajor;
  final String? initialProgram;
  final Function(int?, String?, String?, String?) onApply;

  const _FilterSheet({
    this.initialBatch,
    this.initialSchool,
    this.initialMajor,
    this.initialProgram,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  int? batch;
  String? school;
  String? major;
  String? program;

  @override
  void initState() {
    super.initState();
    batch = widget.initialBatch;
    school = widget.initialSchool;
    major = widget.initialMajor;
    program = widget.initialProgram;
  }

  // NOTE: In a real app, these should be fetched from Supabase via FutureBuilder or Riverpod
  // For now, hardcoding common options to avoid async complexity in the sheet.
  // The user requested: Batch, School, Major, Program.

  final List<int> batches = [2022, 2023, 2024, 2025, 2026];
  final List<String> schools = ['SoEE', 'SoMCME', 'SoCEA', 'SoANS'];
  final List<String> programs = ['Regular', 'Extension', 'Weekend'];
  final List<String> majors = [
    'Software Engineering',
    'Computer Science',
    'Civil Engineering',
    'Mechanical Engineering',
  ]; // Simplified

  Widget _buildSection(
    String title,
    List<dynamic> options,
    dynamic selectedValue,
    Function(dynamic) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((opt) {
              final isSelected = selectedValue == opt;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$opt'),
                  selected: isSelected,
                  onSelected: (val) => onSelect(val ? opt : null),
                  backgroundColor: Colors.white10,
                  selectedColor: DesignSystem.purpleAccent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filter Events",
                style: DesignSystem.theme.textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    batch = null;
                    school = null;
                    major = null;
                    program = null;
                  });
                },
                child: const Text(
                  "Reset",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSection(
                    "Batch Year",
                    batches,
                    batch,
                    (v) => setState(() => batch = v),
                  ),
                  _buildSection(
                    "School",
                    schools,
                    school,
                    (v) => setState(() => school = v),
                  ),
                  _buildSection(
                    "Major",
                    majors,
                    major,
                    (v) => setState(() => major = v),
                  ),
                  _buildSection(
                    "Program",
                    programs,
                    program,
                    (v) => setState(() => program = v),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onApply(batch, school, major, program);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.purpleAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Apply Filters"),
            ),
          ),
        ],
      ),
    );
  }
}
