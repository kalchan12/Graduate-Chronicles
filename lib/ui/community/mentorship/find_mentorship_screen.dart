import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class FindMentorshipScreen extends StatelessWidget {
  const FindMentorshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191022),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'Find a Mentor', showLeading: true, onLeading: () => Navigator.of(context).pop()),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(color: const Color(0xFF121018), borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(children: const [Icon(Icons.search, color: Colors.white54), SizedBox(width: 8), Expanded(child: TextField(style: TextStyle(color: Colors.white), decoration: InputDecoration.collapsed(hintText: 'Search by name, company, skill...', hintStyle: TextStyle(color: Colors.white54))))]),
                  ),
                  const SizedBox(height: 12),
                  // Filter chips
                  SizedBox(
                    height: 44,
                    child: ListView(scrollDirection: Axis.horizontal, children: [
                      _chip('All', primary: true),
                      const SizedBox(width: 8),
                      _chip('Industry'),
                      const SizedBox(width: 8),
                      _chip('Skills'),
                      const SizedBox(width: 8),
                      _chip('University'),
                    ]),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // Mentor list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _mentorCard('Jordan Lee', 'Software Engineer at Google', 'https://lh3.googleusercontent.com/aida-public/AB6AXuC83DnklcFsm_l3wJCXbK-8gDxaqXixe7-74vBCEbTI-KRbCe9B8UYE3ZQJWaDKIZoLLNAD8oUgRO203hYuNAVG-Xaa_f6NGqm_ja65PHmRThduvO1soH5Z4PSOlInWJnkBEIN9h8BU8OQUHAXu-NNvlQfLDC_3R57uYceXccIde2eSWEtXFJtSzWMENgNxHI0GefGZuapNFnjb-Y7ZmSO5xhHSMXxLeVQ49vS5sQkpAXHm46c6KlnhiEAznSdVlcESnhtA1TWIOTSo'),
                  const SizedBox(height: 12),
                  _mentorCard('Alex Chen', 'UX Designer at Airbnb', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAkMvWEmtoOOdrP1oalCI8qq2EpH91qWRGg5-xS7_9WZO7dxlfOkGUGHE-I1qMRkluLYIoyNYYVWPq_vKVS1J2RgK-uEBa6Uw94IDSbfyfRTxBuMWwKxwZsKhqKCH5oMeaGZJEWONLHRR8NxoSwd84PpyJvpp0EMTZgW-mu2GhFulLHpk9rZTXPA6-2YF5KNrMT2gnqKB1TQIj4SAbZpnmPRkSn8L2dt3oId67Zk66lRMKIWiD8PQJlv-ahzOc7hRfa7b0Z7pJ061u4'),
                  const SizedBox(height: 12),
                  _mentorCard('Maria Garcia', 'Marketing Manager at Spotify', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBK_2rOmeZauVUZLvY1358JUOtvkItFVs2ML3MVYyMMm5K-rp3SGO5y5uc718Tr0YI3fmkwg2A9-89YOaICjyZpovVJRUa-yzG3SCGi_h51EweojGDYcmSsl3YVrfTrQ19pXVfDtVHFXYpLWbDV9IVqlLQYT99PYbJDIaiRUD4JDc_FWobJokqa_BEKiLbYYrEhRBVb_LO1b94bdjuE-CTwI_J4SkwmFBtBtFGz2NMtsvk0-JY-Oj0f1vWuiK14oREyiTcamsvyotgX'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, {bool primary = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: primary ? Colors.blueAccent : Colors.white12, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      );

  Widget _mentorCard(String name, String subtitle, String url) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF121018), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [ClipRRect(borderRadius: BorderRadius.circular(40), child: Image.network(url, width: 56, height: 56, fit: BoxFit.cover)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), Text(subtitle, style: const TextStyle(color: Colors.white70))])), ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0), child: const Text('View Profile'))]),
        const SizedBox(height: 8),
        Text('Short description about the mentor goes here.', style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(999)), child: const Text('#Backend', style: TextStyle(color: Colors.white70, fontSize: 12))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(999)), child: const Text('#Python', style: TextStyle(color: Colors.white70, fontSize: 12))),
        ])
      ]),
    );
  }
}
