import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import 'portfolio_viewed_screen.dart';
import 'portfolio_liked_screen.dart';
import 'portfolio_select_screen.dart';

class PortfolioHubScreen extends StatelessWidget {
  const PortfolioHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: Stack(
        children: [
          // -- Main Scrollable Content --
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // -- Header Area (Image + TopBar + Avatar) --
                SizedBox(
                  height: 250, // Reduced height (was 420)
                  child: Stack(
                    children: [
                      // Cover Image
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 180, // Reduced height (was 350)
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                              stops: [0.6, 1.0],
                            ).createShader(
                              Rect.fromLTRB(0, 0, rect.width, rect.height),
                            );
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.asset(
                            'assets/images/dog.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Top Bar (Wrapped in SafeArea to avoid status bar overlap)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(child: _buildTopBar(context)),
                      ),

                      // Avatar (Positioned at bottom center)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(child: _buildAvatar()),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // -- Name & Role --
                const Text(
                  'Abebe Kebede',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Crafting digital experiences @ University',
                  style: TextStyle(
                    color: DesignSystem.purpleAccent.withValues(alpha: 0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SENIOR YEAR',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.circle,
                        size: 4,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    Text(
                      'GLOBAL TECH ACADEMY',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildStatsRow(context),

                const SizedBox(height: 32),

                _buildSectionHeader('ACHIEVEMENTS', '3 items'),
                const SizedBox(height: 16),
                _buildAchievementsList(),

                const SizedBox(height: 32),

                _buildSectionHeader('RESUMES', ''),
                const SizedBox(height: 16),
                _buildResumesGrid(),

                const SizedBox(height: 32),

                _buildSectionHeader('CERTS', ''),
                const SizedBox(height: 16),
                _buildCertsGrid(),

                const SizedBox(height: 32),

                _buildSectionHeader('CONNECTED NETWORK', ''),
                const SizedBox(height: 16),
                _buildNetworkRow(),
              ],
            ),
          ),

          // -- Floating Add Button --
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PortfolioSelectScreen(),
                  ),
                );
              },
              backgroundColor: DesignSystem.purpleAccent,
              elevation: 8,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          Text(
            'PROFILE HUB',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 3,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings, color: Colors.white, size: 20),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: DesignSystem.purpleAccent.withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: DesignSystem.purpleAccent.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 54,
            backgroundColor: Color(0xFFC7A069),
            child: Icon(Icons.person, size: 64, color: Colors.white24),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 6, bottom: 6),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1E1E2E), width: 3),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PortfolioViewedScreen(),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    color: DesignSystem.purpleAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1.2k',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'VIEWS',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            VerticalDivider(
              color: Colors.white.withValues(alpha: 0.1),
              thickness: 1,
            ),

            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PortfolioLikedScreen()),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Colors.pinkAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '458',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'LIKES',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            size: 16,
            color: DesignSystem.purpleAccent.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: TextStyle(
                color: DesignSystem.purpleAccent.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildAchieveCard(
            Icons.emoji_events,
            "Dean's Honor List",
            "ACADEMIC 2023",
          ),
          const SizedBox(width: 12),
          _buildAchieveCard(
            Icons.star,
            "Hackathon Winner",
            "TECHNICAL EXCELLENCE",
          ),
        ],
      ),
    );
  }

  Widget _buildAchieveCard(IconData icon, String title, String subtitle) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151019),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: DesignSystem.purpleAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF151019),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: DesignSystem.purpleAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'MAIN RESUME',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Main_V3.pdf",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  Icon(
                    Icons.download,
                    size: 16,
                    color: DesignSystem.purpleAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF151019),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: DesignSystem.purpleAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'RECENT CERTIFICATES',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _miniFileIcon(),
                const SizedBox(width: 8),
                _miniFileIcon(),
                const SizedBox(width: 8),
                _miniFileIcon(),
                const SizedBox(width: 8),
                Text(
                  '+3 more',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniFileIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF151019), width: 2),
      ),
      child: const Icon(
        Icons.insert_drive_file,
        color: Colors.white70,
        size: 16,
      ),
    );
  }

  Widget _buildNetworkRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _socialChip("LINKEDIN", Colors.blue),
          const SizedBox(width: 12),
          _socialChip("GITHUB", Colors.white),
          const SizedBox(width: 12),
          _socialChip("BEHANCE", Colors.pink),
        ],
      ),
    );
  }

  Widget _socialChip(String label, Color dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: dotColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
