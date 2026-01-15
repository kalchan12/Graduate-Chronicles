import 'package:flutter/material.dart';
import '../../../theme/design_system.dart';
import '../../widgets/global_background.dart';

class MentorshipScreen extends StatefulWidget {
  const MentorshipScreen({super.key});

  @override
  State<MentorshipScreen> createState() => _MentorshipScreenState();
}

class _MentorshipScreenState extends State<MentorshipScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final List<String> _filters = [
    'All',
    'Career',
    'Engineering',
    'Design',
    'Available Now',
  ];

  // Mock Data
  final List<Map<String, dynamic>> _mentors = [
    {
      'name': 'Sarah Jenkins',
      'role': 'Product Designer @ Google',
      'tags': ['UX Design', 'Big Tech'],
      'available': true,
      'isTopRated': false,
      'responseTime': null,
      'category': 'Design',
      'isSaved': false,
      'requestSent': false,
    },
    {
      'name': 'Dr. Aris Thorne',
      'role': 'Research Lead @ OpenAI',
      'tags': ['AI Ethics', 'Academia'],
      'available': false,
      'isTopRated': true,
      'responseTime': null,
      'category': 'Engineering',
      'isSaved': true,
      'requestSent': false,
    },
    {
      'name': 'Maya Lin',
      'role': 'VP of Strategy @ Chase',
      'tags': ['Finance', 'Leadership'],
      'available': false,
      'isTopRated': false,
      'responseTime': 'Responds in 2 days',
      'category': 'Career',
      'isSaved': false,
      'requestSent': false,
    },
  ];

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1727),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter Logic
    final filteredMentors = _mentors.where((mentor) {
      final matchesSearch =
          mentor['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          mentor['role'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesFilter =
          _selectedFilter == 'All' ||
          (_selectedFilter == 'Available Now' && mentor['available'] == true) ||
          mentor['category'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: GlobalBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1727),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Search by name, role, or company...',
                      hintStyle: TextStyle(color: Colors.white30),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.white30),
                      suffixIcon: Icon(Icons.tune, color: Colors.white30),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: filter,
                          isSelected: _selectedFilter == filter,
                          onTap: () => setState(() => _selectedFilter = filter),
                        ),
                      );
                    }).toList(),
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
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _RequestCard(
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

                if (filteredMentors.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        "No mentors found.",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  )
                else
                  ...filteredMentors.map(
                    (mentor) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _MentorCard(
                        name: mentor['name'],
                        role: mentor['role'],
                        tags: List<String>.from(mentor['tags']),
                        available: mentor['available'],
                        isTopRated: mentor['isTopRated'],
                        responseTime: mentor['responseTime'],
                        isSaved: mentor['isSaved'],
                        requestSent: mentor['requestSent'],
                        onSave: () {
                          setState(() {
                            mentor['isSaved'] = !mentor['isSaved'];
                          });
                          _showToast(
                            mentor['isSaved']
                                ? 'Mentor saved'
                                : 'Mentor removed',
                          );
                        },
                        onRequest: () {
                          setState(() {
                            mentor['requestSent'] = true;
                          });
                          _showToast('Request sent to ${mentor['name']}');
                        },
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.purpleAccent
              : const Color(0xFF2B1F2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
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
  final bool isSaved;
  final bool requestSent;
  final VoidCallback onSave;
  final VoidCallback onRequest;

  const _MentorCard({
    required this.name,
    required this.role,
    required this.tags,
    this.available = false,
    this.isTopRated = false,
    this.responseTime,
    this.isSaved = false,
    this.requestSent = false,
    required this.onSave,
    required this.onRequest,
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
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
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
                        fontSize: 13,
                      ),
                    ), // Purple text
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                                  fontSize: 11,
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
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? DesignSystem.purpleAccent : Colors.white54,
                ),
                onPressed: onSave,
              ),
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
                  onPressed: requestSent ? null : onRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isTopRated
                        ? Colors.transparent
                        : DesignSystem.purpleAccent,
                    disabledBackgroundColor: Colors.white12,
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
                  child: Text(
                    requestSent
                        ? 'Pending'
                        : (isTopRated ? 'View Profile' : 'Send Request'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
