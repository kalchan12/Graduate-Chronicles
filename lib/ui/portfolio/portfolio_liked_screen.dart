import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/portfolio_state.dart';
import '../widgets/global_background.dart';

/*
  Portfolio Liked Screen.

  Displays a list of users who have liked the current user's portfolio.
  Features:
  - List of avatars and names.
  - Option to connect with admirers.
*/
class PortfolioLikedScreen extends ConsumerWidget {
  final String portfolioId;
  const PortfolioLikedScreen({super.key, required this.portfolioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesAsync = ref.watch(portfolioLikesProvider(portfolioId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Portfolio Likes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: likesAsync.when(
            data: (likes) {
              if (likes.isEmpty) {
                return const Center(
                  child: Text(
                    'No likes yet.',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: likes.length,
                itemBuilder: (context, index) {
                  final like = likes[index];
                  final user = like['users'] ?? {};
                  final name = user['full_name'] ?? 'Unknown User';
                  final role = user['role'] ?? 'Student';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.pinkAccent.withValues(
                              alpha: 0.1,
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: Colors.pinkAccent,
                            ),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$role • Liked your portfolio',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Connect logic is complex (needs User ID), for now hidden or implement later
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(
              child: Text(
                'Error: $e',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
