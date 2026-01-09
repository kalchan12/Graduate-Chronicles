import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

class YearbookGalleryScreen extends StatefulWidget {
  final String studentName;
  const YearbookGalleryScreen({super.key, required this.studentName});

  @override
  State<YearbookGalleryScreen> createState() => _YearbookGalleryScreenState();
}

class _YearbookGalleryScreenState extends State<YearbookGalleryScreen> {
  // Simulate some photos with categories
  final List<Map<String, dynamic>> _allPhotos = List.generate(
    20,
    (i) => {
      'id': i,
      'category': i % 3 == 0
          ? 'Graduation Day'
          : i % 3 == 1
          ? 'Formal'
          : 'Candids',
    },
  );

  String _selectedCategory = 'All';
  bool _isSearching = false;
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredPhotos {
    return _allPhotos.where((photo) {
      final matchesCategory =
          _selectedCategory == 'All' || photo['category'] == _selectedCategory;
      // Search simulation: in a real app, maybe search by tags or description.
      // Here, we'll just pretend search always matches unless it's very specific,
      // or we can filtering by category text if user types it.
      final matchesSearch =
          _searchQuery.isEmpty ||
          photo['category'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  if (_isSearching)
                    Expanded(
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search gallery...',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Center(
                        child: Text(
                          'Class Gallery',
                          style: DesignSystem.theme.textTheme.titleMedium
                              ?.copyWith(fontSize: 18),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) _searchQuery = '';
                      });
                    },
                  ),
                ],
              ),
            ),

            // Filter chips row
            SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _chip('All'),
                  const SizedBox(width: 8),
                  _chip('Graduation Day'),
                  const SizedBox(width: 8),
                  _chip('Formal'),
                  const SizedBox(width: 8),
                  _chip('Sports'),
                  const SizedBox(width: 8),
                  _chip('Candids'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Image grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _filteredPhotos.isEmpty
                    ? Center(
                        child: Text(
                          'No photos found',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                        itemCount: _filteredPhotos.length,
                        itemBuilder: (context, i) {
                          final photo = _filteredPhotos[i];
                          final index = photo['id'] as int;
                          // Make a couple of tiles visually larger by changing internal aspect (simulation)
                          final isLarge = index % 7 == 0 || index % 9 == 0;

                          return GestureDetector(
                            onTap: () =>
                                _showPreview(context, index, photo['category']),
                            child: Container(
                              decoration: BoxDecoration(
                                // Placeholder gradient
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.05),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      size: 48,
                                    ),
                                  ),
                                  if (isLarge)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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

  Widget _chip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Center(
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
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  void _showPreview(BuildContext context, int i, String category) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DesignSystem.purpleDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.photo, color: Colors.white24, size: 84),
              ),
              const SizedBox(height: 16),
              Text(
                'Photo ${i + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.purpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
