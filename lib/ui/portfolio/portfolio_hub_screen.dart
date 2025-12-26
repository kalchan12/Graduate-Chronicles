import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'portfolio_select_screen.dart';

class PortfolioHubScreen extends StatelessWidget {
  const PortfolioHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'My Portfolio', showLeading: true),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _section('Achievements', ['Dean\'s List 2023', 'Google UX Design Certificate', 'Agile Methodology Intro']),
                    const SizedBox(height: 12),
                    _section('CVs / Resumes', ['Design_Portfolio_CV.pdf', 'General_Resume_2024.pdf']),
                    const SizedBox(height: 12),
                    _section('Certificates', ['Google UX Design Certificate', 'Agile Methodology Intro', 'Dean\'s List 2023']),
                    const SizedBox(height: 12),
                    _section('Links', ['GitHub Profile', 'LinkedIn Profile', 'Behance Portfolio']),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [Expanded(child: ElevatedButton(onPressed: () {
                // go back to select screen
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PortfolioSelectScreen()));
              }, child: const Text('Add More')))]),
            )
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF121018), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)), const Spacer(), IconButton(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.white))]),
        const SizedBox(height: 8),
        ...items.map((i) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Icon(Icons.circle, size: 8, color: Colors.white54), const SizedBox(width: 8), Expanded(child: Text(i, style: const TextStyle(color: Colors.white70)))]))).toList(),
      ]),
    );
  }
}
