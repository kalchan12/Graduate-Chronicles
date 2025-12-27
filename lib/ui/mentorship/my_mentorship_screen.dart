import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class MyMentorshipScreen extends StatelessWidget {
  const MyMentorshipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191022),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'My Mentorships', showLeading: true, onLeading: () => Navigator.of(context).pop()),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(children: [
                Container(
                  height: 48,
                  decoration: BoxDecoration(color: const Color(0xFF121018), borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: const [Icon(Icons.search, color: Colors.white54), SizedBox(width: 8), Expanded(child: TextField(style: TextStyle(color: Colors.white), decoration: InputDecoration.collapsed(hintText: 'Search by mentor name...', hintStyle: TextStyle(color: Colors.white54))))]),
                ),
                const SizedBox(height: 12),
                // Segment buttons
                Row(children: [
                  Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Ongoing', style: TextStyle(color: Colors.white))))),
                  const SizedBox(width: 8),
                  Expanded(child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Past', style: TextStyle(color: Colors.white70)))))
                ]),
                const SizedBox(height: 12),
              ]),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.all(16), children: [
                // Example active mentorship card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF121018), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    CircleAvatar(radius: 28, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBZm8cybNKhSjblbt53JdZPFQOS0heORW7ac-RQyB3t5OlmEBaL4uzvEQrGSYfEoSSwdVH3ykSeTRtUUfbRd5m2WH5XUBa71hZKremU6Mk_nzZuI_VJ3n26y8BUov056nB-nkXd2PrWcxZ23DxRt72Qh7nzznD4lhahL-OR2MxysB34YB331s_kQUiCFRbn14zvq6EDAu6Dc-EC_2RthQxCd9OOGutX9HEBxbFQ6P9d8Gjveyj__sQVQoJO09bUNExqaMLfT2_e2Pqr')),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Evelyn Reed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), Text('Marketing @ Google', style: TextStyle(color: Colors.white70))])),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: const Text('Active', style: TextStyle(color: Colors.green)))
                  ]),
                ),
                const SizedBox(height: 12),
                // Empty state block example
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFFFFFFFF).withOpacity(0.02), borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [
                    const Icon(Icons.group, size: 48, color: Colors.white54),
                    const SizedBox(height: 12),
                    const Text('No Mentors Yet?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Text('Start connecting with professionals to guide your journey.', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/mentorship/find'), child: const Text('Browse Mentors'))
                  ]),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}
