import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

class Onboarding3Screen extends StatelessWidget {
  const Onboarding3Screen({Key? key}) : super(key: key);

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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                height: 220,
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Icon(Icons.school, size: 56, color: Colors.white30)),
              ),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text('Relive Your Uni Days.', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Access your digital yearbook, find photos with friends, and rediscover shared memories from your time at university.',
                  style: TextStyle(color: Color(0xFFBEB2DF), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/onboarding2'),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: DesignSystem.warmYellow, shape: BoxShape.circle),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                        icon: const Icon(Icons.check, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed('/login'), child: const Text('Already have an account? Log In', style: TextStyle(color: Colors.white70)))),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
