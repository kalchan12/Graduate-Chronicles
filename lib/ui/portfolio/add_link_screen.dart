import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'portfolio_hub_screen.dart';

class AddLinkScreen extends StatelessWidget {
  const AddLinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(children: [
          CustomAppBar(title: 'Add New Link', showLeading: true, onLeading: () => Navigator.of(context).pop()),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Link Title', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              TextField(decoration: InputDecoration(hintText: 'e.g., Personal Website', hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF121018), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
              const SizedBox(height: 12),
              const Text('URL', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              TextField(decoration: InputDecoration(hintText: 'https://', hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF121018), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
              const SizedBox(height: 12),
              const Text('Notes (optional)', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              TextField(decoration: InputDecoration(hintText: 'Description', hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF121018), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
              const SizedBox(height: 20),
              Row(children: [Expanded(child: ElevatedButton(onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioHubScreen()));
              }, child: const Text('Save Link')))])
            ]),
          )
        ]),
      ),
    );
  }
}
