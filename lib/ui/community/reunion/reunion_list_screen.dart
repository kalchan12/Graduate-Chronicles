import 'package:flutter/material.dart';
import '../../../theme/design_system.dart';

class ReunionListScreen extends StatefulWidget {
  const ReunionListScreen({super.key});

  @override
  State<ReunionListScreen> createState() => _ReunionListScreenState();
}

class _ReunionListScreenState extends State<ReunionListScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      appBar: AppBar(
        backgroundColor: DesignSystem.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reunions',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, '/community/reunion/create'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search events, batches, year...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white38),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tab Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
                    onTap: () => setState(() => _selectedFilter = 'My Batch'),
                  ),
                  const SizedBox(width: 8),
                  _TabChip(
                    label: 'Mentorship Mixers',
                    isSelected: _selectedFilter == 'Mentorship Mixers',
                    onTap: () =>
                        setState(() => _selectedFilter = 'Mentorship Mixers'),
                  ),
                  const SizedBox(width: 8),
                  _TabChip(
                    label: 'Major',
                    isSelected: _selectedFilter == 'Major',
                    onTap: () => setState(() => _selectedFilter = 'Major'),
                  ),
                  const SizedBox(width: 8),
                  _TabChip(
                    label: 'Location',
                    isSelected: _selectedFilter == 'Location',
                    onTap: () => setState(() => _selectedFilter = 'Location'),
                  ),
                  const SizedBox(width: 8),
                  _TabChip(
                    label: 'Year',
                    isSelected: _selectedFilter == 'Year',
                    onTap: () => setState(() => _selectedFilter = 'Year'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Featured Event Header
            const Row(
              children: [
                Icon(Icons.star, color: DesignSystem.purpleAccent),
                SizedBox(width: 8),
                Text(
                  'Featured Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Horizontal Featured List
            SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _FeaturedEventCard(
                    title: 'Class of 2024 Grand Gala',
                    location: 'Grand Ballroom',
                    date: 'Sat, Nov 12',
                    goingCount: 45,
                    primaryColor: DesignSystem.purpleAccent,
                  ),
                  SizedBox(width: 16),
                  _FeaturedEventCard(
                    title: 'Global Tech Summit',
                    location: 'Convention Center',
                    date: 'Fri, Dec 10',
                    goingCount: 120,
                    primaryColor: Color(0xFF536DFE),
                    isSecondary: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Upcoming Reunions
            const Text(
              'Upcoming Reunions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            const _EventListItem(
              title: 'Design Alumni Coffee',
              type: 'MENTORSHIP',
              date: 'Sun, Nov 20 • 10:00 AM',
              count: '12 going',
              imageColor: Colors.brown,
            ),
            const SizedBox(height: 16),
            const _EventListItem(
              title: 'Tech Innovators Mixer',
              type: 'NETWORKING',
              date: 'Fri, Nov 18 • 6:30 PM',
              count: '28 going',
              imageColor: Colors.teal,
            ),
            const SizedBox(height: 16),
            const _EventListItem(
              title: 'Batch \'21 Virtual Hangout',
              type: 'SOCIAL',
              date: 'Sat, Dec 05 • 8:00 PM',
              count: 'Jessica + 5 others',
              imageColor: Colors.pinkAccent,
              isOnline: true,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/community/reunion/create'),
        backgroundColor: DesignSystem.purpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
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
  final Color primaryColor;
  final bool isSecondary;

  const _FeaturedEventCard({
    required this.title,
    required this.location,
    required this.date,
    required this.goingCount,
    required this.primaryColor,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF2A1727),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          // Background Placeholder
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: const Center(
              child: Icon(Icons.image, color: Colors.white10, size: 48),
            ),
          ),
          // Gradient Overlay
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFF2A1727).withValues(alpha: 0.9),
                  const Color(0xFF2A1727),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'FEATURED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white54, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '$location • ',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      Text(
                        date,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+$goingCount going',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          minimumSize: const Size(0, 36),
                        ),
                        child: Text(
                          'Join',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
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

class _EventListItem extends StatelessWidget {
  final String title;
  final String type;
  final String date;
  final String count;
  final Color imageColor;
  final bool isOnline;

  const _EventListItem({
    required this.title,
    required this.type,
    required this.date,
    required this.count,
    required this.imageColor,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF241228), // Matches card color in system
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: imageColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                Center(child: Icon(Icons.event, color: imageColor, size: 28)),
                if (isOnline)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Online',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 9),
                      ),
                    ),
                  ),
              ],
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: DesignSystem.purpleAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isOnline)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: DesignSystem.purpleAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Interested',
                    style: TextStyle(
                      color: DesignSystem.purpleAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.purpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Join', style: TextStyle(fontSize: 11)),
                ),
              const SizedBox(height: 8),
              Text(
                count,
                style: const TextStyle(color: Colors.white30, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
