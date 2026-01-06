import 'package:flutter/material.dart';

class ReunionListScreen extends StatelessWidget {
  const ReunionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1c1a3c), // Strict requirement
      appBar: AppBar(
        backgroundColor: const Color(0xFF1c1a3c),
        elevation: 0,
        leading:
            const SizedBox(), // Hide default back if managed by custom or bottom nav? Wait, this is pushed, so needs back.
        // Actually typically "Community > Reunion", so yes back button.
        automaticallyImplyLeading:
            false, // Custom implementation usually better for control
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              'Reunions',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
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
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search events, batches, year...',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white30),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tab Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TabChip(label: 'All', isSelected: true),
                  const SizedBox(width: 8),
                  _TabChip(label: 'My Batch'),
                  const SizedBox(width: 8),
                  _TabChip(label: 'Mentorship Mixers'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Featured Event
            const Row(
              children: [
                Icon(Icons.star, color: Color(0xFFBB00FF)),
                SizedBox(width: 8),
                Text(
                  'Featured Event',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _FeaturedEventCard(),

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
              imageColor: Colors.greenAccent,
            ),
            const SizedBox(height: 16),
            const _EventListItem(
              title: 'Batch \'21 Virtual Hangout',
              type: 'SOCIAL',
              date: 'Sat, Dec 05 • 8:00 PM',
              count: 'Jessica + 5 others',
              imageColor: Colors.pink,
              isOnline: true,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, '/community/reunion/create'),
        backgroundColor: const Color(0xFFBB00FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _TabChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFBB00FF) : const Color(0xFF2B1F3E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  const _FeaturedEventCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.grey, // Placeholder for image
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/gala.png'), // Placeholder
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFBB00FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'OFFICIAL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Class of 2024 Grand Gala',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white70, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Grand Ballroom • ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'Sat, Nov 12',
                      style: TextStyle(
                        color: Color(0xFFBB00FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Avatars placeholder
                    const SizedBox(
                      width: 80,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue,
                          ),
                          Positioned(
                            left: 20,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.red,
                            ),
                          ),
                          Positioned(
                            left: 40,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '+45',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFBB00FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'RSVP Now',
                        style: TextStyle(fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF24122E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: imageColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: isOnline
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      color: Colors.black54,
                      child: const Text(
                        'Online',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  )
                : null,
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
                Text(
                  type,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFFBB00FF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  count,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(Icons.bookmark_border, color: Colors.white54),
              SizedBox(height: 24),
              if (!isOnline)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF4A1070),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Interested',
                    style: TextStyle(
                      color: Color(0xFFBB00FF),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFBB00FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Join Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
