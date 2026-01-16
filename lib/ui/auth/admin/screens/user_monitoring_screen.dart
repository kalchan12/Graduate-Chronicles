import 'package:flutter/material.dart';

/*
  Admin: User Directory Screen.
  
  Allows admins to:
  - View list of all registered users
  - Filter by Role (Student, Alumni, Faculty)
  - Search (UI visual only, mock data)
  - See status indicators (Active, Inactive, Blocked)
*/
class UserMonitoringScreen extends StatefulWidget {
  const UserMonitoringScreen({super.key});

  @override
  State<UserMonitoringScreen> createState() => _UserMonitoringScreenState();
}

class _UserMonitoringScreenState extends State<UserMonitoringScreen> {
  // Mock data
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Sarah Jenkins',
      'role': 'Student',
      'email': 's.jenkins@uni.edu',
      'avatar': 'assets/images/avatar1.png',
      'status': 'active',
      'color': Colors.purpleAccent,
    },
    {
      'name': 'Dr. Aris Thorne',
      'role': 'Alumni',
      'email': 'a.thorne@uni.edu',
      'status': 'active',
      'color': Colors.blueAccent,
    },
    {
      'name': 'Marcus Chen',
      'role': 'Student',
      'email': 'm.chen23@uni.edu',
      'status': 'inactive',
      'color': Colors.orangeAccent,
    },
    {
      'name': 'Elena Rodriguez',
      'role': 'Faculty',
      'email': 'e.rodriguez@uni.edu',
      'status': 'blocked',
      'color': Colors.redAccent,
    },
    {
      'name': 'Priya Patel',
      'role': 'Student',
      'email': 'p.patel@uni.edu',
      'status': 'active',
      'color': Colors.tealAccent,
    },
    {
      'name': 'James Wilson',
      'role': 'Alumni',
      'email': 'j.wilson@tech.co',
      'status': 'inactive',
      'color': Colors.amber,
    },
  ];

  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    const bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF130F25), Color(0xFF1E1030)],
    );

    final filteredUsers = _selectedFilter == 'All'
        ? _users
        : _users
              .where(
                (u) => (u['role'] as String).contains(
                  _selectedFilter.replaceAll('s', ''),
                ),
              )
              .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF9B2CFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: bgGradient),
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
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'User Directory',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.white38),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search users by name, email...',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _FilterChip(
                      'All',
                      _selectedFilter == 'All',
                      () => setState(() => _selectedFilter = 'All'),
                    ),
                    _FilterChip(
                      'Students',
                      _selectedFilter == 'Students',
                      () => setState(() => _selectedFilter = 'Students'),
                    ),
                    _FilterChip(
                      'Alumni',
                      _selectedFilter == 'Alumni',
                      () => setState(() => _selectedFilter = 'Alumni'),
                    ),
                    _FilterChip(
                      'Faculty',
                      _selectedFilter == 'Faculty',
                      () => setState(() => _selectedFilter = 'Faculty'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredUsers.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _UserCard(user: user);
                  },
                ),
              ),
            ],
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

  const _FilterChip(this.label, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF9B2CFF)
                : const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final role = user['role'] as String;
    final status = user['status'] as String;

    Color statusColor = Colors.greenAccent;
    if (status == 'inactive') statusColor = Colors.grey;
    if (status == 'blocked') statusColor = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1F2A2438),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: (user['color'] as Color).withOpacity(0.2),
            child: Text(
              (user['name'] as String)[0],
              style: TextStyle(
                color: user['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'],
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1E1030), width: 2),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward_ios, color: Colors.white12, size: 14),
        ],
      ),
    );
  }
}
