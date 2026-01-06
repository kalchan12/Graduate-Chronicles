import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class ReunionHubScreen extends StatelessWidget {
  const ReunionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1A3C),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomAppBar(title: 'Reunions', showLeading: true, onLeading: () => Navigator.of(context).pop()),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Reunions', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                // Search
                Container(
                  height: 48,
                  decoration: BoxDecoration(color: const Color(0xFF24203A), borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: const [Icon(Icons.search, color: Colors.white54), SizedBox(width: 8), Expanded(child: TextField(decoration: InputDecoration.collapsed(hintText: 'Search reunions...', hintStyle: TextStyle(color: Colors.white54))))]),
                ),
                const SizedBox(height: 12),
              ]),
            ),
            // Cards list
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: [
                _eventCard(context, 'Computer Science Batch of \'22 Reunion', 'Sat, Oct 26, 2024', 'University Grand Hall'),
                const SizedBox(height: 12),
                _eventCard(context, 'Engineering Alumni Meetup', 'Fri, Sep 13, 2024', 'The Social Hub, Downtown'),
                const SizedBox(height: 12),
                // CTA to find/join
                ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/reunion/find'), style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent), child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Find / Join Reunion'))),
                const SizedBox(height: 12),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/reunion/my'), child: const Text('My Reunions', style: TextStyle(color: Colors.white70))),
                const SizedBox(height: 24),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _eventCard(BuildContext context, String title, String date, String location) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/reunion/details'),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF2C2946), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 140, decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(12)), image: DecorationImage(image: NetworkImage('https://picsum.photos/800/400'), fit: BoxFit.cover))),
          Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 8), Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.white54), const SizedBox(width: 6), Text(date, style: const TextStyle(color: Colors.white54))]), const SizedBox(height: 6), Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.white54), const SizedBox(width: 6), Text(location, style: const TextStyle(color: Colors.white54))])])),
        ]),
      ),
    );
  }
}
