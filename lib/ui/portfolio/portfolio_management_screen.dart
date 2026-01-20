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
              if (userId == null)
                return const Center(child: Text("Not logged in"));
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: DesignSystem.purpleAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.white),
          onPressed: onAdd,
        ),
      ],
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

    return Card(
      color: Colors.white10,
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () {
            ref
                .read(portfolioProvider.notifier)
                .deleteItem(item['portfolio_id'], type);
          },
        ),
      ),
    );
  }
}
