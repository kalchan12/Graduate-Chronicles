import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../../theme/design_system.dart';
import 'yearbook_filter_screen.dart';

import '../widgets/global_background.dart';

/*
  Explore Yearbook Screen.

  Main entry point for browsing yearbooks.
  Features:
  - Search functionality (by batch name).
  - Filter by batch type (Regular, Weekend, etc.).
  - Grid display of available yearbooks/batches.
*/
class ExploreYearbookScreen extends StatefulWidget {
  const ExploreYearbookScreen({super.key});

  @override
  State<ExploreYearbookScreen> createState() => _ExploreYearbookScreenState();
}

class _ExploreYearbookScreenState extends State<ExploreYearbookScreen> {
  final List<Map<String, String>> _allBatches = const [
    {
      'title': 'Class of 2025',
      'subtitle': 'The Visionaries',
      'type': 'Regular',
    },
    {
      'title': 'Class of 2024',
      'subtitle': 'The Unstoppables',
      'type': 'Regular',
    },
    {
      'title': 'Class of 2023',
      'subtitle': 'Forging New Paths',
      'type': 'Extension',
    },
    {'title': 'Class of 2022', 'subtitle': 'The Resilient', 'type': 'Weekend'},
    {
      'title': 'Class of 2021',
      'subtitle': 'Connected from Afar',
      'type': 'Regular',
    },
    {
      'title': 'Class of 2020',
      'subtitle': 'The Trailblazers',
      'type': 'Weekend',
    },
  ];

  String _searchQuery = '';
  String _selectedFilter = 'All';

  List<Map<String, String>> get _filteredBatches {
    return _allBatches.where((batch) {
      final matchesSearch =
          batch['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          batch['subtitle']!.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _selectedFilter == 'All' || batch['type'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                            hintText: 'Search yearbooks',
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
              const SizedBox(height: 16),
              // Filters
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _filterChip('All'),
                    const SizedBox(width: 8),
                    _filterChip('Regular'),
                    const SizedBox(width: 8),
                    _filterChip('Extension'),
                    const SizedBox(width: 8),
                    _filterChip('Weekend'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _filteredBatches.length,
                  itemBuilder: (context, i) {
                    final batch = _filteredBatches[i];
                    return _BatchGridItem(batch: batch);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.purpleAccent
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _BatchGridItem extends StatelessWidget {
  final Map<String, String> batch;
  const _BatchGridItem({required this.batch});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              YearbookFilterScreen(batchTitle: batch['title']!),
        ),
      ),
      child: Container(
        decoration: DesignSystem.cardDecoration().copyWith(
          color: const Color(0xFF1E0A25), // Match card base
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF2E1A36), const Color(0xFF1E0A25)],
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white24,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batch['title']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    batch['subtitle']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder removed — navigation now goes to the real `YearbookFilterScreen` implementation.
