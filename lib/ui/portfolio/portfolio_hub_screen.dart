import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
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
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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

    // Listen to profile changes to auto-load if we were waiting for ID
    ref.listen<UserProfile>(profileProvider, (previous, next) {
      if (widget.userId == null &&
          previous?.id != next.id &&
          next.id.isNotEmpty) {
        // User ID just became available, try loading again
        _loadData();
      }
    });

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
                                    blendMode: BlendMode.dstOut,
                                    child: portfolio.coverImageUrl != null
                                        ? CachedNetworkImage(
                                            imageUrl: portfolio.coverImageUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  color: Colors.black26,
                                                ),
                                            errorWidget: (c, e, s) => Image.asset(
                                              'assets/images/user_placeholder.png',
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.asset(
                                            'assets/images/user_placeholder.png',
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
                                (portfolio.ownerName ?? userProfile.name),
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
                      (portfolio.ownerName != null &&
                              portfolio.ownerName!.isNotEmpty)
                          ? portfolio.ownerName!
                          : (isOwner && userProfile.name.isNotEmpty
                                ? userProfile.name
                                : 'Student'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        _buildSubtitle(portfolio, userProfile, isOwner),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: DesignSystem.purpleAccent.withValues(
                            alpha: 0.9,
                          ),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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

  String _buildSubtitle(
    PortfolioState portfolio,
    dynamic userProfile,
    bool isOwner,
  ) {
    final degree =
        portfolio.ownerDegree ?? (isOwner ? userProfile.degree : null);
    final batchYear = portfolio.ownerBatchYear;

    if (degree == null || degree.isEmpty) {
      return batchYear != null ? 'Batch of $batchYear' : 'Graduate Student';
    }

    if (batchYear != null && batchYear.isNotEmpty) {
      return '$degree • Batch of $batchYear';
    }

    return degree;
  }

  Widget _buildAvatar(String? imageUrl, bool isOwner, String name) {
    // Get initials from name
    String initials = 'U';
    if (name.isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

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
            child: imageUrl != null
                ? CircleAvatar(
                    radius: 54,
                    backgroundColor: const Color(0xFF2A2A35),
                    backgroundImage: CachedNetworkImageProvider(imageUrl),
                  )
                : Container(
                    width: 108,
                    height: 108,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFF8B5CF6),
                          Color(0xFFA855F7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, PortfolioState portfolio) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF151019).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // VIEWS
            GestureDetector(
              onTap: () {
                if (portfolio.id != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PortfolioViewedScreen(portfolioId: portfolio.id!),
                    ),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${portfolio.views}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        color: DesignSystem.purpleAccent.withValues(alpha: 0.7),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'VIEWS',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
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
              width: 32,
            ),

            // LIKES
            GestureDetector(
              onTap: () {
                ref.read(portfolioProvider.notifier).toggleLike();
              },
              onLongPress: () {
                if (portfolio.id != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PortfolioLikedScreen(portfolioId: portfolio.id!),
                    ),
                  ).then((_) {
                    // Update stats when coming back
                    // (Ideally simpler refresh)
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${portfolio.likes}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        portfolio.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: portfolio.isLiked
                            ? Colors.pinkAccent
                            : DesignSystem.purpleAccent.withValues(alpha: 0.7),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIKES',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: DesignSystem.purpleAccent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.purpleAccent.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (trailing.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                trailing,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(List<Map<String, dynamic>> items) {
    return SizedBox(
      height: 120, // Increased height to prevent overflow
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
              downloadUrl: item['evidence_url'],
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
    String? downloadUrl,
  }) {
    return _GlassCard(
      width: 280,
      padding: const EdgeInsets.all(18),
      onTap: downloadUrl != null ? () => _launchUrl(downloadUrl) : null,
      child: Row(
        children: [
          // Image/Icon with glow effect
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: imageUrl == null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DesignSystem.purpleAccent.withValues(alpha: 0.2),
                        DesignSystem.purpleAccent.withValues(alpha: 0.05),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              image: imageUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              border: Border.all(
                color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: DesignSystem.purpleAccent.withValues(alpha: 0.15),
                  blurRadius: 12,
                ),
              ],
            ),
            child: imageUrl == null
                ? Icon(icon, color: DesignSystem.purpleAccent, size: 26)
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
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          // Download icon indicator
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: DesignSystem.purpleAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.download_rounded,
              color: DesignSystem.purpleAccent.withValues(alpha: 0.8),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumesList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: _GlassCard(
            padding: const EdgeInsets.all(18),
            onTap: () {
              if (item['file_url'] != null) {
                _launchUrl(item['file_url']);
              }
            },
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DesignSystem.purpleAccent.withValues(alpha: 0.25),
                        DesignSystem.purpleAccent.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: DesignSystem.purpleAccent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: DesignSystem.purpleAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['file_name'] ?? 'Resume',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item['notes'] != null && item['notes'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            item['notes'],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DesignSystem.purpleAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    size: 16,
                    color: DesignSystem.purpleAccent.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCertsGrid(List<Map<String, dynamic>> items) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final hasImage =
              item['certificate_url'] != null &&
              (item['certificate_url'].endsWith('.jpg') ||
                  item['certificate_url'].endsWith('.png'));

          return Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: _GlassCard(
              width: 150,
              padding: const EdgeInsets.all(14),
              onTap: () {
                if (item['certificate_url'] != null) {
                  _launchUrl(item['certificate_url']);
                }
              },
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: !hasImage
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(
                                      0xFF81C784,
                                    ).withValues(alpha: 0.2),
                                    const Color(
                                      0xFF81C784,
                                    ).withValues(alpha: 0.05),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(14),
                          image: hasImage
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    item['certificate_url'],
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          border: Border.all(
                            color: const Color(
                              0xFF81C784,
                            ).withValues(alpha: 0.25),
                          ),
                        ),
                        child: !hasImage
                            ? const Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFF81C784),
                                size: 26,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['certificate_name'] ?? 'Certificate',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Download indicator badge
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF81C784).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.download_rounded,
                        size: 12,
                        color: const Color(0xFF81C784).withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
        color: const Color(0xFF151019).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double width;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const _GlassCard({
    required this.child,
    this.width = double.infinity,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: width,
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF252535).withValues(alpha: 0.7),
                  const Color(0xFF1A1A28).withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
