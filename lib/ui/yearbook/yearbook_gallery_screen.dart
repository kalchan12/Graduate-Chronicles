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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('$studentName • Photos', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: GridView.builder(
          itemCount: images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemBuilder: (context, i) => GestureDetector(
            onTap: () {
              // Optional preview behaviour: open simple fullscreen dialog
              showDialog(context: context, builder: (_) => Dialog(backgroundColor: Colors.transparent, child: Container(color: Colors.black87, child: const Center(child: Icon(Icons.photo, color: Colors.white, size: 64)))));
            },
            child: Container(decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8))),
          ),
        ),
      ),
    );
  }
}
