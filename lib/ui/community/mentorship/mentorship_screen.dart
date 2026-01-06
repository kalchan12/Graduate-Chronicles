import 'package:flutter/material.dart';
import '../../../theme/design_system.dart';

class MentorshipScreen extends StatelessWidget {
  const MentorshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      appBar: AppBar(
        backgroundColor: DesignSystem.scaffoldBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mentorship',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                color: const Color(0xFF2A1727),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name, role, or company...',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white30),
                  suffixIcon: Icon(Icons.tune, color: Colors.white30),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: 'All', isSelected: true),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Career'),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Engineering'),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Design'),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Available Now'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Active Requests
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'View History',
                  style: TextStyle(
                    color: DesignSystem.purpleAccent,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RequestCard(
              name: 'James Chen',
              role: 'Startup Funding',
              status: 'Pending',
              date: 'Oct 28 • 10:00 AM',
            ),

            const SizedBox(height: 32),

            // Suggested Mentors
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Suggested Mentors',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.filter_list, color: Colors.white54),
              ],
            ),
            const SizedBox(height: 16),

            _MentorCard(
              name: 'Sarah Jenkins',
              role: 'Product Designer @ Google',
              tags: const ['UX Design', 'Big Tech'],
              available: true,
            ),
            const SizedBox(height: 16),
            _MentorCard(
              name: 'Dr. Aris Thorne',
              role: 'Research Lead @ OpenAI',
              tags: const ['AI Ethics', 'Academia'],
              available: false,
              isTopRated: true,
            ),
            const SizedBox(height: 16),
            _MentorCard(
              name: 'Maya Lin',
              role: 'VP of Strategy @ Chase',
              tags: const ['Finance', 'Leadership'],
              available: false,
              responseTime: 'Responds in 2 days',
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFBB00FF) : const Color(0xFF2B1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.white12,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String name;
  final String role;
  final String status;
  final String date;

  const _RequestCard({
    required this.name,
    required this.role,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF241228),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
              ), // Placeholder
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    role,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  'Requested for $date',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Awaiting response...',
              style: TextStyle(color: Colors.white30, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorCard extends StatelessWidget {
  final String name;
  final String role;
  final List<String> tags;
  final bool available;
  final bool isTopRated;
  final String? responseTime;

  const _MentorCard({
    required this.name,
    required this.role,
    required this.tags,
    this.available = false,
    this.isTopRated = false,
    this.responseTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF241228),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.teal,
              ), // Placeholder
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: const TextStyle(
                        color: Color(0xFFB04CFF),
                        fontSize: 14,
                      ),
                    ), // Purple text
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: tags
                          .map(
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (available) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Available Now',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.bookmark_border, color: Colors.white54),
            ],
          ),

          if (isTopRated || responseTime != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isTopRated)
                  const Row(
                    children: [
                      Icon(Icons.verified, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Text(
                        'Top Rated Mentor',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  )
                else if (responseTime != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        responseTime!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTopRated
                        ? Colors.transparent
                        : const Color(0xFFBB00FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    side: isTopRated
                        ? const BorderSide(color: Colors.white24)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(isTopRated ? 'View Profile' : 'Send Request'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
