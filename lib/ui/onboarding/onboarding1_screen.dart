import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: DesignSystem.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Center artwork and text block
              Expanded(
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // artwork (placeholder image for now)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      height: 240,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                      child: const Center(child: Icon(Icons.photo, size: 56, color: Colors.white30)),
                    ),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text('Your Legacy Starts Here.', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Capture your university moments, from late-night study sessions to graduation day, all in one place.',
                        style: TextStyle(color: Color(0xFFECE3FF), fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]),
                ),
              ),

              // pager dots + nav icons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Row(children: const [Dot(active: true), SizedBox(width: 6), Dot(active: false), SizedBox(width: 6), Dot(active: false)]),
                    const Spacer(),
                    // Next icon button
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: DesignSystem.warmYellow, shape: BoxShape.circle),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/onboarding2'),
                        icon: const Icon(Icons.arrow_forward, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              // Skip top-right style moved to bottom but subtle
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/login'), child: const Text('Skip', style: TextStyle(color: Colors.white70)))),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final bool active;
  const Dot({super.key, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 14 : 8,
      height: 8,
      decoration: BoxDecoration(color: active ? Colors.white : Colors.white38, borderRadius: BorderRadius.circular(8)),
    );
  }
}
