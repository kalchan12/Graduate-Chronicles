import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({Key? key}) : super(key: key);

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
              const SizedBox(height: 36),
              // Artwork placeholder
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
              const Spacer(),

              // pager dots + Next
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                child: Row(
                  children: [
                    Row(children: const [Dot(active: true), SizedBox(width: 6), Dot(active: false), SizedBox(width: 6), Dot(active: false)]),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/onboarding2'),
                      style: ElevatedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14), backgroundColor: DesignSystem.warmYellow, foregroundColor: Colors.black),
                      child: const Text('Next', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/login'), child: const Text('Skip', style: TextStyle(color: Colors.white70))),
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
  const Dot({Key? key, this.active = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 14 : 8,
      height: 8,
      decoration: BoxDecoration(color: active ? Colors.white : Colors.white38, borderRadius: BorderRadius.circular(8)),
    );
  }
}
