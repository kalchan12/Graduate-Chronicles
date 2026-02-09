import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/reunion_state.dart';
import '../../../services/supabase/supabase_service.dart';
import '../../widgets/toast_helper.dart';
import '../../widgets/global_background.dart';

/*
  Reunion Events List Screen.
  
  Displays upcoming alumni gatherings.
  Features:
  - Featured Events carousel (horizontal scroll)
  - Vertical list of upcoming reunions
  - Filtering by Batch, Year, or Major
  - Floating action button to create new events
*/
class ReunionListScreen extends ConsumerStatefulWidget {
  const ReunionListScreen({super.key});

  @override
  ConsumerState<ReunionListScreen> createState() => _ReunionListScreenState();
}

class _ReunionListScreenState extends ConsumerState<ReunionListScreen> {
  String _selectedFilter = 'All';

  void _showToast(String message) {
    ToastHelper.show(context, message);
  }

  void _handleJoin(String reunionId) async {
    try {
      await ref.read(reunionProvider.notifier).joinReunion(reunionId);
      if (mounted) _showToast('Successfully joined reunion!');
    } catch (e) {
      if (mounted) _showToast('Failed to join: ${e.toString()}');
    }
  }

  void _handleLeave(String reunionId) async {
    try {
      await ref.read(reunionProvider.notifier).leaveReunion(reunionId);
      if (mounted) _showToast('You have left the reunion.');
    } catch (e) {
      if (mounted) _showToast('Failed to leave: ${e.toString()}');
    }
  }

  void _showParticipantsModal(String reunionId, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          _ParticipantsList(reunionId: reunionId, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reunionState = ref.watch(reunionProvider);
    final reunions = reunionState.reunions;

    // Simple filter logic for demonstration (backend filtering is preferred)
    final filteredReunions = _selectedFilter == 'All'
        ? reunions
        : reunions
              .where((r) => r['visibility'] == _selectedFilter.toLowerCase())
              .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => ref.read(reunionProvider.notifier).loadReunions(),
            color: DesignSystem.purpleAccent,
            backgroundColor: const Color(0xFF24122E),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reunions',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Reconnect with your batch',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // Removed duplicate Add button from here as requested
                        const SizedBox(
                          width: 48,
                        ), // Spacer to balance if needed, or just remove
                      ],
                    ),
                  ),

                  // -- Feature Image (Sample) --
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/placeholder_reunion.png',
                          ), // Placeholder or use colored box if asset missing
                          fit: BoxFit.cover,
                        ),
                        color: const Color(0xFF3B2F4D), // Fallback
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black54, Colors.transparent],
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 16,
                            left: 16,
                            child: Text(
                              "Batch '23 Reunion",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24122E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          hintStyle: TextStyle(color: Colors.white30),
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.white30),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _TabChip(
                          label: 'All',
                          isSelected: _selectedFilter == 'All',
                          onTap: () => setState(() => _selectedFilter = 'All'),
                        ),
                        const SizedBox(width: 8),
                        _TabChip(
                          label: 'My Batch',
                          isSelected: _selectedFilter == 'My Batch',
                          onTap: () =>
                              setState(() => _selectedFilter = 'My Batch'),
                        ),
                        const SizedBox(width: 8),
                        _TabChip(
                          label: 'Year',
                          isSelected: _selectedFilter == 'Year',
                          onTap: () => setState(() => _selectedFilter = 'Year'),
                        ),
                        const SizedBox(width: 8),
                        _TabChip(
                          label: 'Major',
                          isSelected: _selectedFilter == 'Major',
                          onTap: () =>
                              setState(() => _selectedFilter = 'Major'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Featured
                  if (reunions.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'See All',
                            style: TextStyle(
                              color: DesignSystem.purpleAccent.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 280, // Increased height for larger cards
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: reunions.length > 3 ? 3 : reunions.length,
                        itemBuilder: (context, index) {
                          final item = reunions[index];
                          final id = item['id'] as String;
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _FeaturedEventCard(
                              event: item,
                              color: index % 2 == 0
                                  ? const Color(0xFF5D28BC)
                                  : const Color(0xFFBC287B),
                              onJoin: () => _handleJoin(id),
                              onLeave: () => _handleLeave(id),
                              onShowParticipants: () =>
                                  _showParticipantsModal(id, item['title']),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Upcoming
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      reunionState.isLoading
                          ? 'Loading...'
                          : 'Upcoming Reunions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (reunionState.isLoading && reunions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(
                          color: DesignSystem.purpleAccent,
                        ),
                      ),
                    )
                  else if (reunions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          'No reunions found.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredReunions.length,
                      itemBuilder: (context, index) {
                        final item = filteredReunions[index];
                        final id = item['id'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _EventListItem(
                            event: item,
                            onJoin: () => _handleJoin(id),
                            onLeave: () => _handleLeave(id),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/community/reunion/create'),
        backgroundColor: DesignSystem.purpleAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ParticipantsList extends ConsumerStatefulWidget {
  final String reunionId;
  final String title;

  const _ParticipantsList({required this.reunionId, required this.title});

  @override
  ConsumerState<_ParticipantsList> createState() => _ParticipantsListState();
}

class _ParticipantsListState extends ConsumerState<_ParticipantsList> {
  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    try {
      final service = ref.read(supabaseServiceProvider);
      final data = await service.fetchReunionParticipants(widget.reunionId);
      if (mounted) {
        setState(() {
          _participants = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Going to ${widget.title}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: DesignSystem.purpleAccent,
              ),
            )
          else if (_participants.isEmpty)
            const Center(
              child: Text(
                'No one is going yet. Be the first!',
                style: TextStyle(color: Colors.white54),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _participants.length,
                itemBuilder: (context, index) {
                  final user =
                      _participants[index]; // Map with user details (full_name, etc)
                  // Note: Our service logic returns { "full_name": ..., "username": ... }
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: Text(
                        (user['full_name'] as String? ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      user['full_name'] ?? 'Unknown User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '@${user['username'] ?? ''}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.purpleAccent
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final Color color;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onShowParticipants;

  const _FeaturedEventCard({
    required this.event,
    required this.color,
    required this.onJoin,
    required this.onLeave,
    required this.onShowParticipants,
  });

  @override
  Widget build(BuildContext context) {
    final title = event['title'] ?? 'Untitled Event';
    final location = event['location_value'] ?? 'No Location';
    final date = event['event_date'] ?? 'No Date';
    final goingCount = event['going_count'] ?? 0;
    final isJoined = event['is_joined'] ?? false;

    // Creator Info
    final creator = event['creator'] as Map<String, dynamic>?;
    final creatorName = creator?['full_name'] ?? 'Organizer';
    final creatorImage = creator?['profile_picture'] as String?;

    return Container(
      width: 340, // Increased width (nearly full screen width usually)
      padding: const EdgeInsets.all(24), // Increased padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Date & Creator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Creator Avatar
              Row(
                children: [
                  Text(
                    'by $creatorName',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      image: creatorImage != null
                          ? DecorationImage(
                              image: NetworkImage(creatorImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: creatorImage == null
                        ? const Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.white70,
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Title
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24, // Larger font
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.1,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Location
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bottom Actions
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onShowParticipants,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.people_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$goingCount Going',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: isJoined ? onLeave : onJoin,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: isJoined
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: !isJoined
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    isJoined ? 'Joined' : 'Join',
                    style: TextStyle(
                      color: isJoined ? Colors.white : color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _EventListItem({
    required this.event,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final title = event['title'] ?? 'Untitled Event';
    final date = event['event_date'] ?? 'No Date';
    final location = event['location_value'] ?? 'No Location';
    final isOnline = event['location_type'] == 'virtual';
    final isJoined = event['is_joined'] ?? false;
    final goingCount = event['going_count'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF24122E).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DesignSystem.purpleAccent.withValues(alpha: 0.2),
                      DesignSystem.purpleAccent.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: DesignSystem.purpleAccent.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.event_note_rounded,
                    color: DesignSystem.purpleAccent.withValues(alpha: 0.8),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        if (isJoined)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Text(
                              'GOING',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          date,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.people_outline_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$goingCount',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOnline
                            ? Icons.laptop_mac_rounded
                            : Icons.location_on_outlined,
                        size: 14,
                        color: isOnline ? Colors.blueAccent : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isOnline ? 'Online Event' : location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: isJoined ? onLeave : onJoin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isJoined
                        ? Colors.white.withValues(alpha: 0.1)
                        : DesignSystem.purpleAccent,
                    foregroundColor: Colors.white,
                    elevation: isJoined ? 0 : 4,
                    shadowColor: DesignSystem.purpleAccent.withValues(
                      alpha: 0.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Text(
                    isJoined ? 'Leave' : 'Join',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isJoined ? Colors.white70 : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
