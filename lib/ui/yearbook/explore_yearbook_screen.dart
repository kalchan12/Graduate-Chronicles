import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_app_bar.dart';
import '../../theme/design_system.dart';
import '../../state/yearbook_state.dart';
import '../../models/yearbook_entry.dart';
import '../../state/profile_state.dart';
import 'yearbook_filter_screen.dart';
import 'yearbook_submission_screen.dart';
import '../widgets/toast_helper.dart';
import '../widgets/featured_carousel.dart';
import '../../services/supabase/supabase_service.dart';

import '../widgets/global_background.dart';

/*
  Explore Yearbook Screen.

  Main entry point for browsing yearbooks.
  Features:
  - Search functionality by batch year
  - Grid display of available yearbook batches from database
  - Real-time data fetching from Supabase
*/
class ExploreYearbookScreen extends ConsumerStatefulWidget {
  const ExploreYearbookScreen({super.key});

  @override
  ConsumerState<ExploreYearbookScreen> createState() =>
      _ExploreYearbookScreenState();
}

class _ExploreYearbookScreenState extends ConsumerState<ExploreYearbookScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Explicitly load batches when screen first loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(yearbookProvider.notifier).loadBatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final yearbookState = ref.watch(yearbookProvider);
    final profile = ref.watch(profileProvider);
    final isGraduate = profile.role.toLowerCase().contains('graduate');
    final isAdmin = profile.role.toLowerCase().contains('admin');

    final filteredBatches = yearbookState.batches.where((batch) {
      final yearStr = batch.batchYear.toString();
      final subtitle = batch.batchSubtitle ?? '';
      return yearStr.contains(_searchQuery) ||
          subtitle.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: SafeArea(
          child: Column(
            children: [
              const CustomAppBar(
                title: 'Explore Yearbooks',
                showLeading: false,
              ),
              const SizedBox(height: 8),

              // Featured Graduates Carousel
              FutureBuilder<List<Map<String, dynamic>>>(
                future: ref
                    .read(supabaseServiceProvider)
                    .fetchRandomYearbookEntries(limit: 5),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final items = snapshot.data!
                      .map((m) => FeaturedItem.fromMap(m))
                      .toList();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FeaturedCarousel(items: items, height: 140),
                  );
                },
              ),

              // CTA for Graduates
              if (isGraduate) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildGraduateCTA(context),
                ),
                const SizedBox(height: 16),
              ],

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search yearbooks by year...',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          cursorColor: DesignSystem.purpleAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (yearbookState.isLoading)
                const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  color: DesignSystem.purpleAccent,
                ),
              const SizedBox(height: 16),

              // Loading/Error/Content
              Expanded(
                child: yearbookState.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading yearbooks',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              yearbookState.errorMessage!,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : filteredBatches.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              color: Colors.white24,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No yearbooks available yet'
                                  : 'No yearbooks match your search',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                            if (isAdmin) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _showAddBatchDialog(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Create First Batch'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DesignSystem.purpleAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: filteredBatches.length,
                        itemBuilder: (context, i) {
                          final batch = filteredBatches[i];
                          return _BatchGridItem(batch: batch);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isAdmin && filteredBatches.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showAddBatchDialog(context),
              backgroundColor: DesignSystem.purpleAccent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showAddBatchDialog(BuildContext context) {
    final yearController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DesignSystem.purpleDark,
        title: const Text(
          'Create New Batch',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: yearController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Batch Year (e.g. 2025)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subtitleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Subtitle (Optional)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              final year = int.tryParse(yearController.text.trim());
              if (year != null) {
                try {
                  Navigator.pop(context);
                  await ref
                      .read(yearbookProvider.notifier)
                      .createBatch(
                        year,
                        subtitleController.text.trim().isEmpty
                            ? null
                            : subtitleController.text.trim(),
                      );
                  if (mounted) {
                    ToastHelper.show(context, 'Batch created successfully');
                  }
                } catch (e) {
                  if (mounted) {
                    ToastHelper.show(context, 'Error: $e', isError: true);
                  }
                }
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(color: DesignSystem.purpleAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraduateCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4A148C), // Deep Purple
            DesignSystem.purpleAccent.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: DesignSystem.purpleAccent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Graduate Edition',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your yearbook entry',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const YearbookSubmissionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: DesignSystem.purpleDark, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

class _BatchGridItem extends StatelessWidget {
  final YearbookBatch batch;
  const _BatchGridItem({required this.batch});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => YearbookFilterScreen(
            batchId: batch.id,
            batchTitle: 'Class of ${batch.batchYear}',
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF251029).withValues(alpha: 0.95),
              const Color(0xFF151019).withValues(alpha: 0.9),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: DesignSystem.purpleAccent.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.5,
                      colors: [
                        DesignSystem.purpleAccent.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF3A2738).withValues(alpha: 0.6),
                            const Color(0xFF251029).withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                DesignSystem.purpleAccent.withValues(
                                  alpha: 0.2,
                                ),
                                Colors.transparent,
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Info section with glassmorphic feel
                  Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.03),
                          Colors.white.withValues(alpha: 0.06),
                        ],
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: DesignSystem.purpleAccent.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: DesignSystem.purpleAccent.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${batch.batchYear}',
                                style: const TextStyle(
                                  color: DesignSystem.purpleAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Class of ${batch.batchYear}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (batch.batchSubtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            batch.batchSubtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              // Subtle shimmer overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
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

// Placeholder removed — navigation now goes to the real `YearbookFilterScreen` implementation.
