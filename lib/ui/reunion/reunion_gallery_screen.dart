import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class ReunionGalleryScreen extends StatelessWidget {
  const ReunionGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1A3C),
      body: SafeArea(
        child: Column(children: [
          CustomAppBar(title: 'Reunion Photos', showLeading: true, onLeading: () => Navigator.of(context).pop()),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 180, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1),
                itemCount: 12,
                itemBuilder: (_, i) => Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: NetworkImage('https://picsum.photos/seed/$i/400'), fit: BoxFit.cover))),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
