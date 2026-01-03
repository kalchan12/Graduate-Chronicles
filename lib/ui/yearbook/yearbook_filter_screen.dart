import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../../theme/design_system.dart';
import '../profile/profile_screen.dart';
import 'yearbook_gallery_screen.dart';

class YearbookFilterScreen extends StatefulWidget {
  final String batchTitle;
  const YearbookFilterScreen({super.key, required this.batchTitle});

  @override
  State<YearbookFilterScreen> createState() => _YearbookFilterScreenState();
}

class _YearbookFilterScreenState extends State<YearbookFilterScreen> {
  final List<Map<String, String>> _students = List.generate(
    24,
    (i) => {
      'name':
          '${['Olivia Chen', 'Benjamin Carter', 'Sophia Rodriguez', 'Liam Goldberg', 'Ava Nguyen', 'Noah Williams', 'Elijah Smith', 'Isabella Jones'][i % 8]} ${i + 1}',
      'degree': i % 3 == 0
          ? 'B.S. in Computer Science'
          : i % 3 == 1
          ? 'B.A. in Economics'
          : 'M.Arch in Architecture',
      'category': i % 4 == 0
          ? 'Major'
          : i % 4 == 1
          ? 'Club'
          : i % 4 == 2
          ? 'Achievement'
          : 'Location',
    },
  );

  String _query = '';
  String _selectedCategory = 'All';

  List<Map<String, String>> get _filtered {
    return _students.where((s) {
      final matchesQuery =
          s['name']!.toLowerCase().contains(_query.toLowerCase()) ||
          s['degree']!.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All' || s['category'] == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              title: widget.batchTitle,
              showLeading: true,
              onLeading: () => Navigator.of(context).pop(),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2233),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      Icons.search,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Search by name or degree...',
                          hintStyle: TextStyle(color: Colors.white30),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _navChip('All'),
                  const SizedBox(width: 10),
                  _navChip('Major'),
                  const SizedBox(width: 10),
                  _navChip('Club'),
                  const SizedBox(width: 10),
                  _navChip('Achievement'),
                  const SizedBox(width: 10),
                  _navChip('Location'),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Showing ${_filtered.length} students',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, i) {
                  final s = _filtered[i];
                  return _StudentCard(
                    student: s,
                    onTap: () => _showStudentDetail(s),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.purpleAccent
              : const Color(0xFF1B2233),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white10,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _showStudentDetail(Map<String, String> student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.45,
        minChildSize: 0.30,
        maxChildSize: 0.85,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DesignSystem.scaffoldBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white54,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  student['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  student['degree']!,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.purpleAccent,
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
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => YearbookGalleryScreen(
                            studentName: student['name']!,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View Photo Gallery',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Map<String, String> student;
  final VoidCallback onTap;
  const _StudentCard({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF241228),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF332236),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white10, size: 56),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student['degree']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
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
