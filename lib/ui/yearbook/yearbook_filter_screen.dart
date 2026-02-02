import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_app_bar.dart';
import '../../theme/design_system.dart';
import '../../state/yearbook_state.dart';
import '../../models/yearbook_entry.dart';
import 'widgets/yearbook_profile_dialog.dart';

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
  String _selectedSchool = 'All';
  String _selectedMajor = 'All';
  String _selectedProgram = 'All';

  final List<String> _schools = ['All', 'SoEE', 'SoMCME', 'SoCEA', 'SoANS'];
  final List<String> _programs = ['All', 'Regular', 'Extension', 'Weekend'];

  // Majors Map (Matches Signup Logic)
  static const Map<String, List<String>> _schoolMajors = {
    'SoEE': [
      'Computer Science and Engineering',
      'Software Engineering',
      'Electrical and Computer Engineering',
      'Electrical Power and Control Engineering',
    ],
    'SoMCME': [
      'Mechanical Engineering',
      'Chemical Engineering',
      'Materials Science and Engineering',
    ],
    'SoCEA': [
      'Architecture',
      'Water Resources Engineering',
      'Civil Engineering',
    ],
    'SoANS': ['Physics', 'Chemistry', 'Biology', 'Geology'],
  };

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

      final matchesSchool =
          _selectedSchool == 'All' || entry.school == _selectedSchool;

      final program = _getProgramFromId(entry.institutionalId);
      final matchesProgram =
          _selectedProgram == 'All' || program == _selectedProgram;

      // When filtering by school, only show majors from that school if 'All' major is selected
      // But if a specific major is selected, match strictly.
      final matchesMajor =
          _selectedMajor == 'All' || entry.major == _selectedMajor;

      return matchesQuery && matchesSchool && matchesProgram && matchesMajor;
    }).toList();
  }

  String _getProgramFromId(String? id) {
    if (id == null || id.isEmpty) return 'Regular'; // Default fallback
    final prefix = id.toUpperCase();
    if (prefix.startsWith('UGE')) return 'Extension';
    if (prefix.startsWith('UGW')) return 'Weekend';
    if (prefix.startsWith('UGR')) return 'Regular';
    return 'Regular'; // Default for others
  }

  @override
  Widget build(BuildContext context) {
    final yearbookState = ref.watch(yearbookProvider);
    final filteredList = _filteredEntries;

    // Majors list including "All"
    // Majors list logic
    List<String> majorsList = ['All'];
    if (_selectedSchool != 'All') {
      majorsList.addAll(_schoolMajors[_selectedSchool] ?? []);
    } else {
      // If no school selected, maybe show all? Or keep empty?
      // Existing code showed all but that might be overwhelming.
      // Let's stick to dependent logic: Select school -> Select Major.
      // If All schools, major filter is effectively disabled or limited.
      // Or we can aggregate all.
      for (var list in _schoolMajors.values) {
        for (var major in list) {
          if (!majorsList.contains(major)) majorsList.add(major);
        }
      }
      majorsList.sort();
    }

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
                  ],
                ),
              ),

              // Filter Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    // School Filter
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSchool,
                            isExpanded: true,
                            dropdownColor: DesignSystem.scaffoldBg,
                            style: const TextStyle(color: Colors.white),
                            icon: const Icon(
                              Icons.school_outlined,
                              color: Colors.white54,
                              size: 18,
                            ),
                            items: _schools.map((school) {
                              return DropdownMenuItem<String>(
                                value: school,
                                child: Text(
                                  school == 'All' ? 'School' : school,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedSchool = val;
                                  _selectedMajor = 'All'; // Reset major
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Program Filter
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedProgram,
                            isExpanded: true,
                            dropdownColor: DesignSystem.scaffoldBg,
                            style: const TextStyle(color: Colors.white),
                            icon: const Icon(
                              Icons.category_outlined,
                              color: Colors.white54,
                              size: 18,
                            ),
                            items: _programs.map((prog) {
                              return DropdownMenuItem<String>(
                                value: prog,
                                child: Text(
                                  prog == 'All' ? 'Program' : prog,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedProgram = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Major Filter
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                              size: 18,
                            ),
                            items: majorsList.map((major) {
                              return DropdownMenuItem<String>(
                                value: major,
                                child: Text(
                                  major == 'All' ? 'All Majors' : major,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedMajor = val);
                              }
                            },
                          ),
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
                            onTap: () => _openStudentProfile(entry),
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

  void _openStudentProfile(YearbookEntry entry) {
    // Explicitly show the new YearbookProfileDialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => YearbookProfileDialog(entry: entry),
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
      behavior: HitTestBehavior.opaque, // Ensure tap is caught
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
                  // Quote (Bio)
                  if (entry.yearbookBio != null &&
                      entry.yearbookBio!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '"${entry.yearbookBio}"',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
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
