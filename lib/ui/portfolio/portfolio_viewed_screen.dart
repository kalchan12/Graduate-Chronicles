import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/portfolio_state.dart';
import '../widgets/global_background.dart';

/*
  Portfolio Visitors Screen.

  Displays a history of users who have viewed the portfolio.
  Features:
  - List of recent visitors.
  - Option to view visitor profiles.
*/
class PortfolioViewedScreen extends ConsumerWidget {
  final String portfolioId;
  const PortfolioViewedScreen({super.key, required this.portfolioId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewsAsync = ref.watch(portfolioViewsProvider(portfolioId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Portfolio Visitors'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: viewsAsync.when(
            data: (views) {
              if (views.isEmpty) {
                return const Center(
                  child: Text(
                    'No visitors yet.',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: views.length,
                itemBuilder: (context, index) {
                  final view = views[index];
                  final user = view['users'] ?? {};
                  final name = user['full_name'] ?? 'Unknown User';
                  final role = user['role'] ?? 'Student';
                  // Format time relative approx
                  final time = view['created_at'] != null
                      ? DateTime.parse(
                          view['created_at'],
                        ).toLocal().toString().split('.')[0]
                      : '';

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
                            backgroundColor: Colors.white10,
                            child: Icon(Icons.person, color: Colors.white54),
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
                                  '$role • Viewed $time',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // View Profile button could go here
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
