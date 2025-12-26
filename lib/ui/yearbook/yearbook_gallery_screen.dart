import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class YearbookGalleryScreen extends StatelessWidget {
  final String studentName;
  const YearbookGalleryScreen({Key? key, required this.studentName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = List.generate(20, (i) => i);
    return Scaffold(
      backgroundColor: const Color(0xFF0F1222),
      body: SafeArea(
        child: Column(
          children: [
            // Header similar to HTML
            Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.arrow_back, color: Colors.white)),
                  const Expanded(child: Center(child: Text('Class Gallery', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)))),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.white)),
                ],
              ),
            ),

            // Filter chips row
            SizedBox(
              height: 52,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                children: [
                  _chipSelected('All'),
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
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1),
                  itemCount: images.length,
                  itemBuilder: (context, i) {
                    // Make a couple of tiles visually larger by changing internal aspect
                    final isLarge = i % 7 == 0 || i % 9 == 0;
                    return GestureDetector(
                      onTap: () => _showPreview(context, i),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                        child: Builder(builder: (ctx) {
                          if (isLarge) {
                            return Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                                  ),
                                ),
                                const Padding(padding: EdgeInsets.all(8), child: SizedBox.shrink()),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        }),
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

  Widget _chip(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 14), margin: const EdgeInsets.only(top: 6), height: 36, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(999)), child: Center(child: Text(text, style: const TextStyle(color: Colors.white))));

  Widget _chipSelected(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 14), margin: const EdgeInsets.only(top: 6), height: 36, decoration: BoxDecoration(color: const Color(0xFF062FF9), borderRadius: BorderRadius.circular(999)), child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))));

  void _showPreview(BuildContext context, int i) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          color: Colors.black87,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 24),
            const Icon(Icons.photo, color: Colors.white, size: 84),
            const SizedBox(height: 24),
            Text('Photo ${i + 1}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 18),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close', style: TextStyle(color: Colors.white))),
          ]),
        ),
      ),
    );
  }
}

