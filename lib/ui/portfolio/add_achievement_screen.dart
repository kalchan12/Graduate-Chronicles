import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'portfolio_hub_screen.dart';

class AddAchievementScreen extends StatelessWidget {
  const AddAchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(children: [
          CustomAppBar(title: 'Add Achievement', showLeading: true, onLeading: () => Navigator.of(context).pop()),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  TextField(decoration: InputDecoration(hintText: "e.g., Dean's List - Fall 2024", hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF121018), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                  const SizedBox(height: 12),
                  const Text('Description', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  TextField(maxLines: 5, decoration: InputDecoration(hintText: 'Describe your achievement...', hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF121018), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                  const SizedBox(height: 12),
                  const Text('Date Achieved', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Container(height: 48, decoration: BoxDecoration(color: const Color(0xFF121018), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('2024-12-26', style: TextStyle(color: Colors.white54)))),
                  const SizedBox(height: 16),
                  Container(height: 140, decoration: BoxDecoration(color: const Color(0xFF121018), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.add_a_photo, color: Colors.white54, size: 40))),
                  const SizedBox(height: 20),
                  Row(children: [Expanded(child: ElevatedButton(onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioHubScreen()));
                  }, child: const Text('Save Achievement')))])
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
