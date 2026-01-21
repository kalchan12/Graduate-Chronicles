import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/reunion_state.dart';
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
                        Container(
                          decoration: BoxDecoration(
                            color: DesignSystem.purpleAccent.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: DesignSystem.purpleAccent,
                            ),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/community/reunion/create',
                            ),
                          ),
                        ),
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
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: reunions.length > 3 ? 3 : reunions.length,
                        itemBuilder: (context, index) {
                          final item = reunions[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _FeaturedEventCard(
                              title: item['title'] ?? 'Untitled Event',
                              location: item['location_value'] ?? 'No Location',
                              date: item['event_date'] ?? 'No Date',
                              goingCount: 0, // Mocked for now
                              color: index % 2 == 0
                                  ? const Color(0xFF5D28BC)
                                  : const Color(0xFFBC287B),
                              onJoin: () =>
                                  _showToast('Joined ${item['title']}'),
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _EventListItem(
                            title: item['title'] ?? 'Untitled Event',
                            date: item['event_date'] ?? 'No Date',
                            location: item['location_value'] ?? 'No Location',
                            isOnline: item['location_type'] == 'virtual',
                            onJoin: () =>
                                _showToast('Request sent to join event'),
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
  final String title;
  final String location;
  final String date;
  final int goingCount;
  final Color color;
  final VoidCallback onJoin;

  const _FeaturedEventCard({
    required this.title,
    required this.location,
    required this.date,
    required this.goingCount,
    required this.color,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 24,
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.person,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          left: 16,
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white38,
                            child: Icon(
                              Icons.person,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 32,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Text(
                              '+${goingCount > 99 ? '99' : goingCount}',
                              style: TextStyle(
                                color: color,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$goingCount Going',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
  final String title;
  final String date;
  final String location;
  final bool isOnline;
  final VoidCallback onJoin;

  const _EventListItem({
    required this.title,
    required this.date,
    required this.location,
    this.isOnline = false,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF24122E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.event, color: Colors.white54),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: DesignSystem.purpleAccent.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isOnline ? Icons.laptop : Icons.location_on,
                      size: 12,
                      color: isOnline ? Colors.greenAccent : Colors.white54,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isOnline ? 'Online Event' : location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isOnline ? Colors.greenAccent : Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.purpleAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Join', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
