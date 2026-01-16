import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_system.dart';
import 'providers/settings_provider.dart';
import '../../ui/widgets/global_background.dart';

/*
  Notification Settings Screen.
  
  Granular control over app notifications.
  Options:
  - Global pause switch
  - Push notifications (Events, Yearbook)
  - Activity alerts (Comments, Likes)
  - Email preferences
*/
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const _SectionHeader(title: 'PUSH NOTIFICATIONS'),
              _SwitchTile(
                title: 'Pause All',
                subtitle: 'Temporarily disable push alerts',
                icon: Icons.do_not_disturb_on,
                iconColor: settings.pauseAllNotifications
                    ? DesignSystem.purpleAccent
                    : Colors.white54,
                value: settings.pauseAllNotifications,
                onChanged: (v) => notifier.togglePauseAll(v),
              ),
              _SwitchTile(
                title: 'Yearbook Signatures',
                icon: Icons.edit_note,
                value: settings.yearbookSignatures,
                onChanged: (v) => notifier.toggleYearbookSignatures(v),
              ),
              _SwitchTile(
                title: 'Event Reminders',
                icon: Icons.event,
                value: settings.eventReminders,
                onChanged: (v) => notifier.toggleEventReminders(v),
              ),

              const SizedBox(height: 24),
              const _SectionHeader(title: 'ACTIVITY MENTIONS'),
              _SwitchTile(
                title: 'Comments',
                icon: Icons.comment,
                value: settings.comments,
                onChanged: (v) => notifier.toggleComments(v),
              ),
              _SwitchTile(
                title: 'Tags & Mentions',
                icon: Icons.alternate_email,
                value: settings.tagsMentions,
                onChanged: (v) => notifier.toggleTagsMentions(v),
              ),
              _SwitchTile(
                title: 'New Likes',
                icon: Icons.favorite,
                value: settings.newLikes,
                onChanged: (v) => notifier.toggleNewLikes(v),
              ),

              const SizedBox(height: 24),
              const _SectionHeader(title: 'EMAIL ALERTS'),
              _SwitchTile(
                title: 'Weekly Recap',
                subtitle: 'Summary of profile activity',
                icon: Icons.email,
                value: settings.weeklyRecap,
                onChanged: (v) => notifier.toggleWeeklyRecap(v),
              ),
              _SwitchTile(
                title: 'Product Updates',
                icon: Icons.campaign,
                value: settings.productUpdates,
                onChanged: (v) => notifier.toggleProductUpdates(v),
              ),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Email preferences are managed separately from push notifications.',
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFBDB1C9),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final Function(bool) onChanged;
  final Color? iconColor;

  const _SwitchTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF231B26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2433),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFFBDB1C9),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: DesignSystem.purpleAccent,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }
}
