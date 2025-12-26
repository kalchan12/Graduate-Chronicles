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
    12,
    (i) => {
      'name': 'Student ${i + 1}',
      'degree': i % 2 == 0 ? 'B.S. in Computer Science' : 'B.A. in Economics',
    },
  );

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _students.where((s) => s['name']!.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1222),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: widget.batchTitle, showLeading: true, onLeading: () => Navigator.of(context).pop()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by name, department',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF1B2233),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF1B2233), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.tune, color: Colors.white)),
              ]),
            ),

            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Align(alignment: Alignment.centerLeft, child: Text('Showing ${filtered.length} results', style: const TextStyle(color: Colors.white54)))),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.9, mainAxisSpacing: 12, crossAxisSpacing: 12),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final student = filtered[i];
                  return GestureDetector(
                    onTap: () => _showStudentDetail(student),
                    child: Container(
                      decoration: BoxDecoration(color: const Color(0xFF1C2130), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: Container(decoration: BoxDecoration(color: Colors.black26, borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))), child: const Center(child: Icon(Icons.person, color: Colors.white54, size: 40)))),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(student['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(student['degree']!, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
