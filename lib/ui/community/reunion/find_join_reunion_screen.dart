import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class FindJoinReunionScreen extends StatelessWidget {
  const FindJoinReunionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1A3C),
      body: SafeArea(
        child: Column(children: [
          CustomAppBar(title: 'Reunions', showLeading: true, onLeading: () => Navigator.of(context).pop()),
          const SizedBox(height: 12),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(height: 48, decoration: BoxDecoration(color: const Color(0xFF24203A), borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: const [Icon(Icons.search, color: Colors.white54), SizedBox(width: 8), Expanded(child: TextField(decoration: InputDecoration.collapsed(hintText: 'Search reunions...', hintStyle: TextStyle(color: Colors.white54))))]))),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(16), children: [
              _card('Computer Science Batch of \'22 Reunion', 'University Grand Hall', 'Sat, Oct 26, 2024'),
              const SizedBox(height: 12),
              _card('Engineering Alumni Meetup', 'The Social Hub, Downtown', 'Fri, Sep 13, 2024'),
              const SizedBox(height: 12),
              _card('Annual Alumni Gala', 'Alumni Hall', 'Sat, Jan 20, 7:00 PM'),
            ]),
          )
        ]),
      ),
    );
  }

  Widget _card(String title, String location, String date) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF2C2946), borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 8), Row(children: [const Icon(Icons.location_on, size: 16, color: Colors.white54), const SizedBox(width: 6), Text(location, style: const TextStyle(color: Colors.white54))]), const SizedBox(height: 6), Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.white54), const SizedBox(width: 6), Text(date, style: const TextStyle(color: Colors.white54))])])),
      ),
    );
  }
}
