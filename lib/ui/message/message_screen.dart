import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../theme/design_system.dart';
import '../widgets/custom_app_bar.dart';

// Messages screen built to match the provided static HTML chat design.
class MessageScreen extends ConsumerWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider);

    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'Messages', showLeading: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  const Center(child: Text('TODAY', style: TextStyle(color: Color(0xFFBDB1C9)))),
                  const SizedBox(height: 12),
                  // Chat bubbles built from messagesProvider for UI-driven content.
                  ...messages.map((m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _ChatRow(sender: m.sender, text: m.lastMessage, isIncoming: messages.indexOf(m) % 2 == 0),
                      )),
                ],
              ),
            ),

            // Message input area (visual only)
            Container(
              padding: const EdgeInsets.all(12),
              color: DesignSystem.scaffoldBg,
              child: Row(
                children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3A2738)), child: const Icon(Icons.add, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(child: Container(height: 44, decoration: BoxDecoration(color: const Color(0xFF2A1727), borderRadius: BorderRadius.circular(999)), child: const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Align(alignment: Alignment.centerLeft, child: Text('Type a message...', style: TextStyle(color: Color(0xFFBDB1C9))))))),
                  const SizedBox(width: 12),
                  Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, color: DesignSystem.purpleAccent), child: const Icon(Icons.send, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  final String sender;
  final String text;
  final bool isIncoming;
  const _ChatRow({Key? key, required this.sender, required this.text, this.isIncoming = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isIncoming) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3A2738))),
        const SizedBox(width: 8),
        Flexible(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF241228), borderRadius: BorderRadius.circular(12)), child: Text(text, style: const TextStyle(color: Color(0xFFD6C9E6))))),
      ]);
    }

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Flexible(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: DesignSystem.purpleAccent, borderRadius: BorderRadius.circular(12)), child: Text(text, style: const TextStyle(color: Colors.white)))),
    ]);
  }
}
