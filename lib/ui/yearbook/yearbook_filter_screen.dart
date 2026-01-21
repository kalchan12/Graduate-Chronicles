import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_app_bar.dart';
import '../../theme/design_system.dart';
import '../../state/yearbook_state.dart';
import '../../models/yearbook_entry.dart';
import '../profile/profile_screen.dart';

import '../widgets/global_background.dart';

/*
  Yearbook Filter Screen.

  Displays yearbook entries for a specific batch.
  Features:
  - Search students by name or major
  - Filter by major
  - Real data from Supabase with JOIN to users table
  - Navigates to student profile
*/
class YearbookFilterScreen extends ConsumerStatefulWidget {
  final String batchId;
  final String batchTitle;

  const YearbookFilterScreen({
    super.key,
    required this.batchId,
    required this.batchTitle,
  });

  @override
  ConsumerState<YearbookFilterScreen> createState() =>
      _YearbookFilterScreenState();
}

class _YearbookFilterScreenState extends ConsumerState<YearbookFilterScreen> {
  String _query = '';
  String _selectedMajor = 'All';

  @override
  void initState() {
    super.initState();
    // Load entries for this batch
    Future.microtask(() {
      ref.read(yearbookProvider.notifier).loadEntriesForBatch(widget.batchId);
    });
  }

  List<YearbookEntry> get _filteredEntries {
    final state = ref.watch(yearbookProvider);
    return state.entries.where((entry) {
      final matchesQuery =
          (entry.fullName?.toLowerCase().contains(_query.toLowerCase()) ??
              false) ||
          (entry.major?.toLowerCase().contains(_query.toLowerCase()) ?? false);
      final matchesMajor =
          _selectedMajor == 'All' || entry.major == _selectedMajor;
      return matchesQuery && matchesMajor;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final yearbookState = ref.watch(yearbookProvider);
    final filteredList = _filteredEntries;

    // Majors list including "All"
    final majorsList = ['All', ...yearbookState.majors];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlobalBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                title: widget.batchTitle,
                showLeading: true,
                onLeading: () => Navigator.of(context).pop(),
              ),

              // Search & Filter Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.search,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _query = v),
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Search student name...',
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

                    const SizedBox(height: 12),

                    // Major Filter Dropdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: majorsList.contains(_selectedMajor)
                              ? _selectedMajor
                              : 'All',
                          isExpanded: true,
                          dropdownColor: DesignSystem.scaffoldBg,
                          style: const TextStyle(color: Colors.white),
                          icon: const Icon(
                            Icons.class_outlined,
                            color: Colors.white54,
                          ), // Filter icon
                          items: majorsList.map((major) {
                            return DropdownMenuItem<String>(
                              value: major,
                              child: Text(
                                major == 'All' ? 'All Majors' : major,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedMajor = val);
                              // Ideally trigger a backend filter too if dataset is large,
                              // but client side is fine for now as per previous logic.
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Removed Chip List
              const SizedBox(height: 8),

              // Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  yearbookState.isLoading
                      ? 'Loading...'
                      : 'Showing ${filteredList.length} ${filteredList.length == 1 ? 'entry' : 'entries'}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Content
              Expanded(
                child: yearbookState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: DesignSystem.purpleAccent,
                        ),
                      )
                    : yearbookState.errorMessage != null
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
                              'Error loading entries',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredList.isEmpty
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
                              _query.isEmpty
                                  ? 'No yearbook entries yet'
                                  : 'No matches found',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                        itemBuilder: (context, i) {
                          final entry = filteredList[i];
                          return _StudentCard(
                            entry: entry,
                            onTap: () => _showStudentDetail(entry),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentDetail(YearbookEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.50,
        minChildSize: 0.30,
        maxChildSize: 0.85,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: DesignSystem.scaffoldBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            controller: controller,
            children: [
              // Yearbook Photo
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: entry.yearbookPhotoUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(entry.yearbookPhotoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: entry.yearbookPhotoUrl.isEmpty
                        ? Colors.white.withValues(alpha: 0.05)
                        : null,
                  ),
                  child: entry.yearbookPhotoUrl.isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          color: Colors.white24,
                          size: 48,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Center(
                child: Text(
                  entry.fullName ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Major
              if (entry.major != null)
                Center(
                  child: Text(
                    entry.major!,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),

              // Bio
              if (entry.yearbookBio != null &&
                  entry.yearbookBio!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.yearbookBio!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Actions
              Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.purpleAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: const Text('View Profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final YearbookEntry entry;
  final VoidCallback onTap;
  const _StudentCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: DesignSystem.cardDecoration().copyWith(
          color: const Color(0xFF1E0A25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  image: entry.yearbookPhotoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(entry.yearbookPhotoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  gradient: entry.yearbookPhotoUrl.isEmpty
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF2E1A36),
                            const Color(0xFF1E0A25),
                          ],
                        )
                      : null,
                ),
                child: entry.yearbookPhotoUrl.isEmpty
                    ? Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white24,
                            size: 40,
                          ),
                        ),
                      )
                    : null,
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.fullName ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (entry.major != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.major!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
