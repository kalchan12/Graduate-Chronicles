import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../widgets/custom_app_bar.dart';
import 'yearbook_filter_screen.dart';

class ExploreYearbookScreen extends StatelessWidget {
  const ExploreYearbookScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> _batches = const [
    {'title': 'Class of 2025', 'subtitle': 'The Visionaries'},
    {'title': 'Class of 2024', 'subtitle': 'The Unstoppables'},
    {'title': 'Class of 2023', 'subtitle': 'Forging New Paths'},
    {'title': 'Class of 2022', 'subtitle': 'The Resilient'},
    {'title': 'Class of 2021', 'subtitle': 'Connected from Afar'},
    {'title': 'Class of 2020', 'subtitle': 'The Trailblazers'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1222),
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Explore Yearbooks', showLeading: false),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFF1B2233), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: const [Icon(Icons.search, color: Colors.white54), SizedBox(width: 8), Expanded(child: Text('Search yearbooks', style: TextStyle(color: Colors.white54)))]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: _batches.length,
                itemBuilder: (context, i) {
                  final batch = _batches[i];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => YearbookFilterScreen(batchTitle: batch['title']!))),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(colors: [Color(0xFF231235), Color(0xFF2C1630)]),
                      ),
                      child: Stack(
                        children: [
                          // subtle image placeholder
                          Positioned.fill(child: Container(decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(14)))),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(batch['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(batch['subtitle']!, style: const TextStyle(color: Color(0xFFB9C0D8), fontSize: 12)),
                              ],
                            ),
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
}

// Keep the filter screen reference local to avoid exposing unnecessary symbols.
class YearbookFilterScreen extends StatelessWidget {
  final String batchTitle;
  const YearbookFilterScreen({Key? key, required this.batchTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1222),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(batchTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: const Center(child: Text('Yearbook Filter (navigates to student grid)', style: TextStyle(color: Colors.white54))),
    );
  }
}
