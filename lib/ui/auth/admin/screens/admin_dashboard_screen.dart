import 'package:flutter/material.dart';

/*
  The central hub for Administrators.
  
  Provides an overview of:
  - Total user statistics
  - Recent activity and alerts
  
  Navigation to:
  - User Directory/Management
  - Content Monitoring
  - System Logs
*/
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using dark theme consistent with designs
    const bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF130F25), Color(0xFF1E1030)],
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B1E54),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.security,
                        color: Color(0xFF9B2CFF),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Hub',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'MONITORING & CONTROL',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Exit Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.2),
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          // Logout and go to login
                          // For now just navigate
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/login', (route) => false);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Exit',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.logout,
                                size: 14,
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader('Overview'),
                      const SizedBox(height: 12),

                      // Total Users Card (Big)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0x14FFFFFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TOTAL USERS',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Text(
                                        '15,284',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.greenAccent.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          '+12%',
                                          style: TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B1E54),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.people_outline,
                                color: Color(0xFF9B2CFF),
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Mini Cards
                      Row(
                        children: [
                          Expanded(
                            child: _MiniCard(
                              title: 'STUDENTS',
                              value: '12.5k',
                              icon: Icons.school_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniCard(
                              title: 'ALUMNI',
                              value: '2.7k',
                              icon: Icons.history_edu,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniCard(
                              title: 'ACTIVE EVENTS',
                              value: '24',
                              isEvents: true,
                              icon: Icons.event,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniCard(
                              title: 'PENDING REPORTS',
                              value: '8',
                              isAlert: true,
                              icon: Icons.flag_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      _SectionHeader('Control Panel'),
                      const SizedBox(height: 12),

                      _NavTile(
                        title: 'User Directory',
                        subtitle: 'Manage students, alumni & faculty',
                        icon: Icons.supervised_user_circle_outlined,
                        color: Colors.blueAccent,
                        onTap: () =>
                            Navigator.of(context).pushNamed('/admin/users'),
                      ),
                      const SizedBox(height: 10),
                      _NavTile(
                        title: 'Content Monitoring',
                        subtitle: 'Review reported posts & activity',
                        icon: Icons.shield_outlined,
                        color: Colors.orangeAccent,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed('/admin/monitoring'),
                      ),
                      const SizedBox(height: 10),
                      _NavTile(
                        title: 'System Logs',
                        subtitle: 'View access & security logs',
                        icon: Icons.data_usage,
                        color: Colors.tealAccent,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 18, color: const Color(0xFF9B2CFF)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isAlert;
  final bool isEvents;

  const _MiniCard({
    required this.title,
    required this.value,
    required this.icon,
    this.isAlert = false,
    this.isEvents = false,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.white10;
    Color iconColor = Colors.white38;

    if (isAlert) {
      borderColor = Colors.redAccent.withOpacity(0.3);
      iconColor = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isEvents)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isAlert ? Colors.redAccent : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x1F2A2438),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
