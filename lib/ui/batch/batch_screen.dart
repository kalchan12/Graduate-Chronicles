import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theme/design_system.dart';
import '../widgets/custom_app_bar.dart';

// Batch / Directory screen implemented to match provided HTML design.
class BatchScreen extends ConsumerWidget {
  const BatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directory = ref.watch(directoryProvider);

    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Directory', showLeading: true),
            // Search bar area
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1727),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 12),
                    Icon(Icons.search, color: Colors.white54),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search for classmates...',
                        style: TextStyle(color: Color(0xFFBDB1C9)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips (visual only)
            SizedBox(
              height: 56,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChip(label: 'All', active: true),
                  const SizedBox(width: 8),
                  _FilterChip(label: "Batch of '24"),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Alumni'),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Computer Science'),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'Business'),
                ],
              ),
            ),

            // Directory list
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.separated(
                  itemCount: directory.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = directory[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1727),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF3A2738),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${p.year} • ${p.degree}',
                                  style: const TextStyle(
                                    color: Color(0xFFBDB1C9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFBDB1C9),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  const _FilterChip({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? DesignSystem.purpleAccent : const Color(0xFF3A2738),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFFBDB1C9),
        ),
      ),
    );
  }
}
