import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../../theme/design_system.dart';
import 'yearbook_filter_screen.dart';

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
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Explore Yearbooks', showLeading: false),
            const SizedBox(height: 8),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2233),
                  borderRadius: BorderRadius.circular(12),
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
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filters
            SizedBox(
              height: 40,
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
            const SizedBox(height: 12),
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
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.purpleAccent
              : const Color(0xFF1B2233),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF241228),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  color: Color(0xFF332236),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white10,
                  size: 48,
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
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
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
