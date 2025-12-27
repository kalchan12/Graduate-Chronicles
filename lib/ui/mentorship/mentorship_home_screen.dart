import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../widgets/custom_app_bar.dart';

class MentorshipHomeScreen extends StatelessWidget {
  const MentorshipHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191022),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomAppBar(title: 'Mentorship Hub', showLeading: true, onLeading: () => Navigator.of(context).pop()),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Level Up Your Future', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    const Text('Get guidance from experienced alumni and professionals who\'ve been in your shoes.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 18),

                    // Benefits grid (3 cards)
                    Row(
                      children: [
                        Expanded(child: _benefitCard(Icons.work, 'Career Guidance', 'Get career advice')),
                        const SizedBox(width: 8),
                        Expanded(child: _benefitCard(Icons.trending_up, 'Skill Development', 'Build new skills')),
                        const SizedBox(width: 8),
                        Expanded(child: _benefitCard(Icons.groups, 'Networking', 'Grow your network')),
                      ],
                    ),
                    const SizedBox(height: 18),

                    const Text('Featured Mentors', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _mentorTile('Sarah Chen', 'Software Engineer at Google', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBVT_EFmdO7QC91Hz_1M-4X805OQqxaSUHFq2O3uweYjmT4mbnVChv5ne1i88biIManwVlZ9eCLR08_u7JomlPvryyK9-nztTIr3O6_rGPsWXmdt9_4SU5R0PK8Bzyd6cr42060rc4YPdqFzgWQ3lcMroFpkJYKA6g4lA1RurZq_LVBWsaZpy4eXY0k6M1pNfIN_EaEyYT-QUq1mE3N4SlOoFCQh6w5KMzSyuSS4pydCHdbnnodZv0u_bd33Jn4GwIMiMJjLtUUhZoU'),
                          const SizedBox(width: 12),
                          _mentorTile('Michael Lee', 'Marketing Director', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBPqoykWhwnRzTSwvtCQ2V-FswRtNGTucVNdtw89Gb7uEvI492kO4EceO62iU2nnBR-B3CUfMd_x5PeHWxj3IfzeP2OUus3PdSa_um1tRQ8mEQGRZuZtLAX9rmQc5CI3AP1P-Y9OvhlF34kMDSbV3Pf9rUs8J8t4VXx0MWodQTBksmWT22Wp1m4Pz-3sVdvENNtbZCGUDhmFqO-B-IlpvD_7fg3DtpDqINSihySrDYyKe5nUBcBXO5lY2gNkph0swDxbsNW39c0j0Mx'),
                          const SizedBox(width: 12),
                          _mentorTile('David Kim', 'Product Manager at Meta', 'https://lh3.googleusercontent.com/aida-public/AB6AXuCNUdFjmAI2Cqj7yRZ9Wc3ifJheJuZiub8e01qm_EOSN34jnvvg9Bj_6ADpMOszIdThax4IpWe8BObYcfPcp8pcMghoWos3qqUq9p5uDBhFUb8qQCuaKOboFcYfjMd4tzfCpn10LofQ_FEUeZQYtnzYl5UEdEJlSgvBiCwiKQAL7Hp-OyvtZmbtsv0ySGsQgQojXsGGPmjp0Ir7ShqIPzGHFeZOo16Ir0Ou-BcJDQZaeg66FlYRp7f2x80gij8UyLANnWyty4AIpaXC'),
                          const SizedBox(width: 12),
                          _mentorTile('Emily Rodriguez', 'UX Designer at Airbnb', 'https://lh3.googleusercontent.com/aida-public/AB6AXuC7lXyg556pxr888KS1hmePJqcGyQPOHFoEMZpWbItr7FEVCVqblFy1BKGKLVY_sPx9CvOtV_IXcfjbzFRrA75kyAl6suAjhuIVTQoGHbJhFnGsA2I12pUC1dg2y0FTleBv0zpOuK42bpYAfyxQX1zjeRxkB8Uq6qOFopPp9IaeLxEvZDSO6ckSZr8zBu1nh8vnlgs9Lb7zDc-H0FyHUL-SxHY7k7qwpeO8V98hKg2GRuJzl1gjflhZaXqdDtP0cng3B0_vV3MJ4fs_'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text('Popular Categories', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _chip('Tech', primary: true),
                      _chip('Marketing'),
                      _chip('Finance'),
                      _chip('Startups'),
                      _chip('Design'),
                    ]),
                    const SizedBox(height: 24),
                    // CTA
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/mentorship/find'),
                      style: ElevatedButton.styleFrom(backgroundColor: DesignSystem.purpleAccent, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Find Your Mentor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(onPressed: () => Navigator.pushNamed(context, '/mentorship/my'), child: const Text('My Mentorship', style: TextStyle(color: Colors.white70))),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFFFFFF).withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: DesignSystem.purpleAccent), const SizedBox(height: 8), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12))]),
    );
  }

  Widget _mentorTile(String name, String subtitle, String url) {
    return Container(
      width: 120,
      decoration: BoxDecoration(color: const Color(0xFFFFFFFF).withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(8),
      child: Column(children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(url, height: 72, width: 72, fit: BoxFit.cover)),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _chip(String label, {bool primary = false}) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: primary ? DesignSystem.purpleAccent : Colors.white12, borderRadius: BorderRadius.circular(999)), child: Text(label, style: const TextStyle(color: Colors.white)));
  }
}
