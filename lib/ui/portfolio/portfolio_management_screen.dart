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

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'achievement':
        icon = Icons.emoji_events_rounded;
        iconColor = const Color(0xFFFFD700);
        break;
      case 'resume':
        icon = Icons.description_rounded;
        iconColor = const Color(0xFF64B5F6);
        break;
      case 'certificate':
        icon = Icons.workspace_premium_rounded;
        iconColor = const Color(0xFF81C784);
        break;
      case 'link':
        icon = Icons.link_rounded;
        iconColor = DesignSystem.purpleAccent;
        break;
      default:
        icon = Icons.article_rounded;
        iconColor = Colors.white70;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1F1F2E).withValues(alpha: 0.8),
            const Color(0xFF151019).withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Optional: Edit functionality could go here
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Delete Action
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 20,
                  ),
                  onPressed: () {
                    ref
                        .read(portfolioProvider.notifier)
                        .deleteItem(item['portfolio_id'], type);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
