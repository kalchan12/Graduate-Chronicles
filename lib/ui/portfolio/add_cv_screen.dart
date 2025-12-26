import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import 'portfolio_hub_screen.dart';

class AddCvScreen extends StatelessWidget {
  const AddCvScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'Upload Your CV', showLeading: true, onLeading: () => Navigator.of(context).pop()),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(color: const Color(0xFF121018), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.upload_file, size: 48, color: Colors.white54), SizedBox(height: 8), Text('Tap to Upload Your CV', style: TextStyle(color: Colors.white54))])),
                  ),
                  const SizedBox(height: 16),
                  TextField(decoration: InputDecoration(hintText: 'File name (e.g., jane_doe_cv.pdf)', hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF121018), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                  const SizedBox(height: 12),
                  TextField(decoration: InputDecoration(hintText: 'Notes (optional)', hintStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF121018), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // pop AddCvScreen -> returns to select
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PortfolioHubScreen()));
                          },
                          child: const Text('Save CV'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
