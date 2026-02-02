import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_system.dart';
import '../../state/portfolio_state.dart';
import '../../ui/widgets/global_background.dart';
import '../../services/supabase/supabase_service.dart';
import 'add_achievement_screen.dart';
import 'add_cv_screen.dart';
import 'add_certificate_screen.dart';
import 'add_link_screen.dart';

class PortfolioManagementScreen extends ConsumerWidget {
  const PortfolioManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current User Logic
    final AsyncValue<String?> currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Manage Portfolio',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: currentUser.when(
            data: (userId) {
              if (userId == null) {
                return const Center(child: Text("Not logged in"));
              }
              // Trigger load if not loaded?
              // Better: Just use a FutureBuilder or useEffect.
              // We'll rely on the provider having data or loading it.
              // But we need to load it for the CURRENT public ID.
              // This is tricky if we don't have the public ID available easily in state.
              // However, SupabaseService.getCurrentUserId() is what we need.

              return _PortfolioManager(publicUserId: userId);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text("Error: $e")),
          ),
        ),
      ),
    );
  }
}

final currentUserProvider = FutureProvider<String?>((ref) async {
  return ref.read(supabaseServiceProvider).getCurrentUserId();
});

class _PortfolioManager extends ConsumerStatefulWidget {
  final String publicUserId;
  const _PortfolioManager({required this.publicUserId});

  @override
  ConsumerState<_PortfolioManager> createState() => _PortfolioManagerState();
}

class _PortfolioManagerState extends ConsumerState<_PortfolioManager> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(portfolioProvider.notifier).loadPortfolio(widget.publicUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(portfolioProvider);

    if (portfolio.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(
          title: 'Achievements',
          onAdd: () => _addItem('achievement'),
        ),
        ...portfolio.achievements.map(
          (item) => _ItemCard(item: item, type: 'achievement'),
        ),

        const SizedBox(height: 20),
        _SectionHeader(title: 'Resumes', onAdd: () => _addItem('resume')),
        ...portfolio.resumes.map(
          (item) => _ItemCard(item: item, type: 'resume'),
        ),

        const SizedBox(height: 20),
        _SectionHeader(
          title: 'Certificates',
          onAdd: () => _addItem('certificate'),
        ),
        ...portfolio.certificates.map(
          (item) => _ItemCard(item: item, type: 'certificate'),
        ),

        const SizedBox(height: 20),
        _SectionHeader(title: 'Links', onAdd: () => _addItem('link')),
        ...portfolio.links.map((item) => _ItemCard(item: item, type: 'link')),
      ],
    );
  }

  void _addItem(String type) {
    Widget? screen;
    switch (type) {
      case 'achievement':
        screen = const AddAchievementScreen();
        break;
      case 'resume':
        screen = const AddCvScreen();
        break;
      case 'certificate':
        screen = const AddCertificateScreen();
        break;
      case 'link':
        screen = const AddLinkScreen();
        break;
    }

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen!));
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;
  const _SectionHeader({required this.title, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: DesignSystem.purpleAccent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: DesignSystem.purpleAccent.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DesignSystem.purpleAccent.withValues(alpha: 0.1),
                border: Border.all(
                  color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add,
                    color: DesignSystem.purpleAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "ADD",
                    style: TextStyle(
                      color: DesignSystem.purpleAccent.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends ConsumerWidget {
  final Map<String, dynamic> item;
  final String type;
  const _ItemCard({required this.item, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String title =
        item['title'] ??
        item['certificate_name'] ??
        item['file_name'] ??
        'Item';
    String subtitle =
        item['description'] ??
        item['url'] ??
        item['issuing_organization'] ??
        '';

    String? imageUrl = item['cover_image_url'];

    // Define colors and icons for each type
    IconData icon;
    Color primaryColor;
    Color secondaryColor;
    String typeLabel;

    switch (type) {
      case 'achievement':
        icon = Icons.emoji_events_rounded;
        primaryColor = const Color(0xFFFFD700);
        secondaryColor = const Color(0xFFFFA000);
        typeLabel = 'ACHIEVEMENT';
        break;
      case 'resume':
        icon = Icons.description_rounded;
        primaryColor = const Color(0xFF00D4FF);
        secondaryColor = const Color(0xFF0099CC);
        typeLabel = 'RESUME';
        break;
      case 'certificate':
        icon = Icons.workspace_premium_rounded;
        primaryColor = const Color(0xFF00FF88);
        secondaryColor = const Color(0xFF00CC6A);
        typeLabel = 'CERTIFICATE';
        break;
      case 'link':
        icon = Icons.link_rounded;
        primaryColor = const Color(0xFFBB86FC);
        secondaryColor = const Color(0xFF9C64FF);
        typeLabel = 'LINK';
        break;
      default:
        icon = Icons.article_rounded;
        primaryColor = Colors.white70;
        secondaryColor = Colors.white54;
        typeLabel = 'ITEM';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E1E2E).withValues(alpha: 0.95),
            const Color(0xFF0D0D14).withValues(alpha: 0.98),
          ],
        ),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: -2,
          ),
          // Inner shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Edit functionality placeholder
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: Icon Container with Glow
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withValues(alpha: 0.2),
                        secondaryColor.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Icon(icon, color: primaryColor, size: 30),
                          ),
                        )
                      : Icon(icon, color: primaryColor, size: 30),
                ),

                const SizedBox(width: 16),

                // Middle: Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withValues(alpha: 0.2),
                              secondaryColor.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Title with gradient text effect
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withValues(alpha: 0.8),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Right: Delete Button with glow
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    onPressed: () {
                      // Show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1E2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Delete Item?',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: Text(
                            'Are you sure you want to delete "$title"?',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ref
                                    .read(portfolioProvider.notifier)
                                    .deleteItem(item['portfolio_id'], type);
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
