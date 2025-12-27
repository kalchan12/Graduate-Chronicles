import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class MyReunionsScreen extends StatelessWidget {
  const MyReunionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1A3C),
      body: SafeArea(
        child: Column(children: [
          CustomAppBar(title: 'My Reunions', showLeading: true, onLeading: () => Navigator.of(context).pop()),
          const SizedBox(height: 12),
          Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
            // Example joined reunion
            InkWell(onTap: () => Navigator.pushNamed(context, '/reunion/details'), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF2C2946), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Class of '24 Homecoming Bash", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text('Sat, Oct 26, 2024 • University Grand Hall', style: const TextStyle(color: Colors.white70))]))),
            const SizedBox(height: 12),
            // Empty state example
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF24203A), borderRadius: BorderRadius.circular(12)), child: Column(children: [const Icon(Icons.celebration, size: 48, color: Colors.white54), const SizedBox(height: 8), const Text('No Reunions Yet?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 6), const Text('Find your next get-together and reconnect with classmates.', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center), const SizedBox(height: 12), ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/reunion/find'), child: const Text('Explore Events'))]))
          ]))
        ]),
      ),
    );
  }
}
