import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/design_system.dart';
import '../widgets/global_background.dart';
import 'portfolio_viewed_screen.dart';
import 'portfolio_liked_screen.dart';
import 'portfolio_management_screen.dart'; // Changed to management screen directly for editing
import '../../state/portfolio_state.dart';
import '../../state/profile_state.dart';
import '../../services/supabase/supabase_service.dart';
import '../widgets/toast_helper.dart';

/*
  Portfolio Hub Screen.

  The main profile/portfolio showcase for the user.
  Features:
  - Custom visual design with overlapping avatar and cover image.
  - Stats display (Views, Likes).
  - Sections for Achievements, Resumes, Certificates, and Social Links.
  - Floating action button to manage portfolio items.
*/
class PortfolioHubScreen extends ConsumerStatefulWidget {
  final String? userId; // Optional: If null, shows current user (owner)
  const PortfolioHubScreen({super.key, this.userId});

  @override
  ConsumerState<PortfolioHubScreen> createState() => _PortfolioHubScreenState();
}

class _PortfolioHubScreenState extends ConsumerState<PortfolioHubScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // Determine target ID
    final myProfile = ref.read(profileProvider);
    final targetId = widget.userId ?? myProfile.id;

    if (targetId.isNotEmpty) {
      if (widget.userId == null) {
        // Owner/Default
        ref.read(portfolioProvider.notifier).loadCurrentPortfolio();
      } else {
        // Visitor
        ref.read(portfolioProvider.notifier).loadPortfolio(targetId);
      }
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _pickAndUploadImage(String type) async {
    // Safety check: Only owner can upload
    final myProfile = ref.read(profileProvider);
    final isOwner = widget.userId == null || widget.userId == myProfile.id;
    if (!isOwner) return;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isUploading = true);

      final service = ref.read(supabaseServiceProvider);
      // We need the portfolio ID. We can get it from fetching current portfolio again or storing it in state.
      // Ideally PortfolioState should have portfolioId, but currently it doesn't.
      // We can fetch it quickly or refactor state.
      // For now, let's just fetch it wrapper or rely on service finding it?
      // The uploadPortfolioPicture needs portfolioId.

      final user = service.currentUser;
      if (user == null) throw Exception("User not found");

      // Quick fetch to get ID (optimized path would be to put ID in state)
      final data = await service.fetchPortfolio(user.id);
      final portfolioId = data['portfolio_id'];

      if (portfolioId == null) throw Exception("Portfolio not init");

      await service.uploadPortfolioPicture(
        path: image.path,
        type: type,
        portfolioId: portfolioId,
      );

      // Refresh
      await ref.read(portfolioProvider.notifier).loadCurrentPortfolio();

      if (mounted) {
        // Use Unified Toast
        ToastHelper.show(context, 'Image updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.show(context, 'Upload failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider);
    final userProfile = ref.watch(profileProvider);

    final myProfile = ref.watch(profileProvider);
    final isOwner = widget.userId == null || widget.userId == myProfile.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: Stack(
          children: [
            // -- Main Scrollable Content --
            RefreshIndicator(
              onRefresh: () async {
                await _loadData();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // -- Header Area (Image + TopBar + Avatar) --
                    SizedBox(
                      height: 320, // Taller header
                      child: Stack(
                        children: [
                          // Cover Image
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 240, // Taller cover
                            child: GestureDetector(
                              onTap: isOwner
                                  ? () => _pickAndUploadImage('cover')
                                  : null,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (rect) {
                                      return const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors
                                              .black45, // Darker top for text visibility
                                          Colors.transparent,
                                          Colors
                                              .black, // Fade into background at bottom
                                        ],
                                        stops: [0.0, 0.5, 1.0],
                                      ).createShader(rect);
                                    },
                                    blendMode: BlendMode
                                        .dstOut, // logic inverse? No, let's use srcOver with gradient overlay instead for better control.
                                    // Actually, simple gradient overlay is better than shadermask for this.
                                    child: portfolio.coverImageUrl != null
                                        ? Image.network(
                                            portfolio.coverImageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                Image.asset(
                                                  'assets/images/dog.png',
                                                  fit: BoxFit.cover,
                                                ),
                                          )
                                        : Image.asset(
                                            'assets/images/dog.png',
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  // Gradient Overlay for text protection & smooth transition
                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black54,
                                          Colors.transparent,
                                          Color(
                                            0xFF0D0D12,
                                          ), // Match Global Background mostly
                                        ],
                                        stops: [0.0, 0.6, 1.0],
                                      ),
                                    ),
                                  ),

                                  // Edit Overlay hint (Floating) - Moved to Top Right
                                  if (isOwner)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 8,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add_a_photo,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                  if (_isUploading)
                                    Container(
                                      color: Colors.black54,
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // Top Bar
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: SafeArea(child: _buildTopBar(context)),
                          ),

                          // Avatar
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: _buildAvatar(
                                portfolio.profileImageUrl,
                                isOwner,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // -- Name & Role (Dynamic from Portfolio State) --
                    // Uses ownerName if available (other user), otherwise falls back to userProfile (me) or "Student"
                    Text(
                      (portfolio.ownerName != null && portfolio.ownerName!.isNotEmpty)
                          ? portfolio.ownerName!
                          : (isOwner && userProfile.name.isNotEmpty
                              ? userProfile.name
                              : 'Student'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (portfolio.ownerDegree != null && portfolio.ownerDegree!.isNotEmpty)
                          ? '${portfolio.ownerDegree} @ Graduate Chronicles'
                          : (isOwner && userProfile.degree.isNotEmpty
                              ? '${userProfile.degree} @ Graduate Chronicles'
                              : 'Graduate Student'),
                      style: TextStyle(
                        color: DesignSystem.purpleAccent.withValues(alpha: 0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildStatsRow(
                      context,
                      portfolio,
                    ), // Pass portfolio for stats

                    const SizedBox(height: 32),

                    if (portfolio.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      // ACHIEVEMENTS
                      if (portfolio.achievements.isNotEmpty) ...[
                        _buildSectionHeader(
                          'ACHIEVEMENTS',
                          '${portfolio.achievements.length} items',
                        ),
                        const SizedBox(height: 16),
                        _buildAchievementsList(portfolio.achievements),
                        const SizedBox(height: 32),
                      ],

                      // RESUMES
                      if (portfolio.resumes.isNotEmpty) ...[
                        _buildSectionHeader('RESUMES', ''),
                        const SizedBox(height: 16),
                        _buildResumesList(portfolio.resumes),
                        const SizedBox(height: 32),
                      ],

                      // CERTIFICATES
                      if (portfolio.certificates.isNotEmpty) ...[
                        _buildSectionHeader('CERTS', ''),
                        const SizedBox(height: 16),
                        _buildCertsGrid(portfolio.certificates),
                        const SizedBox(height: 32),
                      ],

                      // LINKS
                      if (portfolio.links.isNotEmpty) ...[
                        _buildSectionHeader('CONNECTED NETWORK', ''),
                        const SizedBox(height: 16),
                        _buildNetworkRow(portfolio.links),
                      ],
                    ],

                    if (!portfolio.isLoading &&
                        portfolio.achievements.isEmpty &&
                        portfolio.resumes.isEmpty &&
                        portfolio.certificates.isEmpty &&
                        portfolio.links.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          isOwner
                              ? "No portfolio items yet. Tap + to add!"
                              : "No portfolio items shared.",
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // -- Floating Add Button --
            if (isOwner)
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: () {
                    // Navigate to Portfolio Management Screen to add items
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PortfolioManagementScreen(),
                      ),
                    ).then((_) {
                      // Refresh on return
                      ref
                          .read(portfolioProvider.notifier)
                          .loadCurrentPortfolio();
                    });
                  },
                  backgroundColor: DesignSystem.purpleAccent,
                  elevation: 8,
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
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
              // Settings/More Icon placeholder on right if needed, else empty width
              const SizedBox(width: 40),
            ],
          ),
          Text(
            'PROFILE HUB',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 2,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl, bool isOwner) {
    return GestureDetector(
      onTap: isOwner ? () => _pickAndUploadImage('profile') : null,
      child: Stack(
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
            child: CircleAvatar(
              radius: 54,
              backgroundColor: const Color(0xFFC7A069),
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.person, size: 64, color: Colors.white24)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, PortfolioState portfolio) {
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
            // VIEWS
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
                      Text(
                        '${portfolio.views}',
                        style: const TextStyle(
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

            // LIKES
            GestureDetector(
              onTap: () {
                // Toggle Like
                ref.read(portfolioProvider.notifier).toggleLike();
              },
              onLongPress: () {
                // View Liked Screen (if we want to keep it accessible)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PortfolioLikedScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(
                    portfolio.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: portfolio.isLiked
                        ? Colors.pinkAccent
                        : Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${portfolio.likes}',
                        style: const TextStyle(
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

  Widget _buildAchievementsList(List<Map<String, dynamic>> items) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildAchieveCard(
              item['cover_image_url'] != null ? null : Icons.emoji_events,
              item['title'] ?? 'Achievement',
              item['description'] ?? '',
              imageUrl: item['cover_image_url'],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchieveCard(
    IconData? icon,
    String title,
    String subtitle, {
    String? imageUrl,
  }) {
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
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? Icon(icon, color: DesignSystem.purpleAccent)
                : null,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

  Widget _buildResumesList(List<Map<String, dynamic>> items) {
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
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: () {
                  if (item['file_url'] != null) {
                    _launchUrl(item['file_url']);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['file_name'] ?? 'Resume',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item['notes'] != null &&
                                item['notes'].isNotEmpty)
                              Text(
                                item['notes'],
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11,
                                ),
                              ),
                          ],
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
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCertsGrid(List<Map<String, dynamic>> items) {
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
                  'CERTIFICATES',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return InkWell(
                  onTap: () {
                    if (item['certificate_url'] != null) {
                      _launchUrl(item['certificate_url']);
                    }
                  },
                  child: Tooltip(
                    message: item['certificate_name'] ?? 'Certificate',
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF151019),
                          width: 2,
                        ),
                        image:
                            item['certificate_url'] != null &&
                                (item['certificate_url'].endsWith('.jpg') ||
                                    item['certificate_url'].endsWith('.png'))
                            ? DecorationImage(
                                image: NetworkImage(item['certificate_url']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child:
                          item['certificate_url'] != null &&
                              (item['certificate_url'].endsWith('.jpg') ||
                                  item['certificate_url'].endsWith('.png'))
                          ? null
                          : const Icon(
                              Icons.insert_drive_file,
                              color: Colors.white70,
                              size: 20,
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkRow(List<Map<String, dynamic>> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: items.map((item) {
          Color color = Colors.white;
          String title = item['title'] ?? 'Link';
          if (title.toLowerCase().contains('linkedin')) color = Colors.blue;
          if (title.toLowerCase().contains('behance')) color = Colors.pink;
          if (title.toLowerCase().contains('github')) color = Colors.white;

          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () {
                if (item['url'] != null) _launchUrl(item['url']);
              },
              borderRadius: BorderRadius.circular(16),
              child: _socialChip(title.toUpperCase(), color),
            ),
          );
        }).toList(),
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
