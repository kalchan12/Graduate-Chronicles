import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../../theme/design_system.dart';
import '../profile/profile_screen.dart';
import 'yearbook_gallery_screen.dart';

class YearbookFilterScreen extends StatefulWidget {
  final String batchTitle;
  const YearbookFilterScreen({Key? key, required this.batchTitle}) : super(key: key);

  @override
  State<YearbookFilterScreen> createState() => _YearbookFilterScreenState();
}

class _YearbookFilterScreenState extends State<YearbookFilterScreen> {
  final List<Map<String, String>> _students = List.generate(
    20,
    (i) => {
      'name': ['Olivia Chen', 'Benjamin Carter', 'Sophia Rodriguez', 'Liam Goldberg', 'Ava Nguyen', 'Noah Williams'][i % 6] + ' ${i + 1}',
      'degree': i % 3 == 0 ? 'B.S. in Computer Science' : i % 3 == 1 ? 'B.A. in Economics' : 'M.Arch in Architecture',
    },
  );

  String _query = '';

  List<Map<String, String>> get _filtered => _students.where((s) => s['name']!.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1222),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar matching HTML layout
            CustomAppBar(title: 'Search Graduates', showLeading: true, onLeading: () => Navigator.of(context).pop()),

            // Search Bar (HTML-like)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0xFFe6e6e6).withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                              ),
                              child: const Icon(Icons.search, color: Colors.white54),
                            ),
                            Expanded(
                              child: TextField(
                                onChanged: (v) => setState(() => _query = v),
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  hintText: 'Search by name, hometown, etc.',
                                  hintStyle: TextStyle(color: Colors.white54),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips (matches HTML spacing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    _chipAllFilters(),
                    const SizedBox(width: 8),
                    _chipPrimary('Major'),
                    const SizedBox(width: 8),
                    _chip('Club'),
                    const SizedBox(width: 8),
                    _chip('Achievement'),
                    const SizedBox(width: 8),
                    _chip('Location'),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),

            // Meta text
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Showing ${_filtered.length} results', style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ),

            const SizedBox(height: 8),

            // Responsive grid to match HTML's auto-fit minmax(158px, 1fr)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: GridView.builder(
                  itemCount: _filtered.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, i) {
                    final s = _filtered[i];
                    return GestureDetector(
                      onTap: () => _showStudentDetail(s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black26,
                              ),
                              child: const Center(child: Icon(Icons.person, color: Colors.white54, size: 40)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(s['name']!, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(s['degree']!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
          decoration: const BoxDecoration(color: Color(0xFF0F1222), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          child: ListView(controller: controller, children: [
            Center(child: Container(width: 84, height: 84, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: Colors.white54, size: 44))),
            const SizedBox(height: 12),
            Center(child: Text(student['name']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
            const SizedBox(height: 8),
            Center(child: Text(student['degree']!, style: const TextStyle(color: Colors.white54))),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.purpleAccent),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileScreen()));
                },
                child: const Text('View Profile'),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24)),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => YearbookGalleryScreen(studentName: student['name']!)));
                },
                child: const Text('View Photo Gallery', style: TextStyle(color: Colors.white)),
              ),
            ])
          ]),
        ),
      ),
    );
  }
}

  Widget _chipAllFilters() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 40,
        decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
        child: Row(children: const [Icon(Icons.tune, color: Colors.white54), SizedBox(width: 8), Text('All Filters', style: TextStyle(color: Colors.white))]),
      );

  Widget _chipPrimary(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 40,
        decoration: BoxDecoration(color: DesignSystem.purpleAccent, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Text(text, style: const TextStyle(color: Colors.white)), const SizedBox(width: 6), const Icon(Icons.arrow_drop_down, color: Colors.white)]),
      );

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 40,
        decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Text(text, style: const TextStyle(color: Colors.white)), const SizedBox(width: 6), const Icon(Icons.arrow_drop_down, color: Colors.white54)]),
      );
