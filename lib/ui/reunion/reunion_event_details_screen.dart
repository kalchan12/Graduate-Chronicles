import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class ReunionEventDetailsScreen extends StatelessWidget {
  const ReunionEventDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1A3C),
      body: SafeArea(
        child: Column(children: [
          CustomAppBar(title: "Class of '24 Homecoming Bash", showLeading: true, onLeading: () => Navigator.of(context).pop()),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Container(height: 200, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: const DecorationImage(image: NetworkImage('https://picsum.photos/900/400'), fit: BoxFit.cover))),
              const SizedBox(height: 12),
              Row(children: [
                _infoTile(Icons.calendar_today, 'Sat, Oct 26, 2024'),
                const SizedBox(width: 8),
                _infoTile(Icons.schedule, '7:00 PM - 11:00 PM'),
                const SizedBox(width: 8),
                _infoTile(Icons.location_on, 'University Grand Hall'),
              ]),
              const SizedBox(height: 12),
              const Text('Join us for a night of nostalgia, fun, and reconnection at the annual Homecoming Bash. Catch up with old friends, dance to your favorite tunes, and make new memories.', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              const Text('Who\'s Going?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SizedBox(height: 60, child: ListView(scrollDirection: Axis.horizontal, children: [
                _avatar('https://picsum.photos/seed/1/80'),
                const SizedBox(width: 8),
                _avatar('https://picsum.photos/seed/2/80'),
                const SizedBox(width: 8),
                _avatar('https://picsum.photos/seed/3/80'),
                const SizedBox(width: 8),
                _avatar('https://picsum.photos/seed/4/80'),
              ])),
              const SizedBox(height: 12),
              Row(children: [Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Join Reunion'))), const SizedBox(width: 12), OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/reunion/gallery'), child: const Text('View Gallery'))])
            ]),
          )
        ]),
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) => Expanded(child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF24203A), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(icon, color: Colors.white54), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: Colors.white70)))])));

  Widget _avatar(String url) => ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, width: 60, height: 60, fit: BoxFit.cover));
}
