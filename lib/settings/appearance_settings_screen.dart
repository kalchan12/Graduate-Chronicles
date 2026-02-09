import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../state/theme_provider.dart';
import '../../ui/widgets/global_background.dart';

/*
  Appearance Settings Screen.
  
  Theme customization.
  Features:
  - Dark Mode
  - Light Mode
*/
class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.onSurface),
        title: Text(
          'Appearance',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Theme',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              // Dark Mode
              _ThemeOptionTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                isSelected: isDark,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
                },
              ),
              const SizedBox(height: 12),
              // Light Mode
              _ThemeOptionTile(
                icon: Icons.light_mode,
                title: 'Light Mode',
                isSelected: !isDark,
                onTap: () {
                  ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.light);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppTheme.purpleAccent, width: 1.5)
              : null,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected
                ? AppTheme.purpleAccent
                : theme.colorScheme.onSurfaceVariant,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: AppTheme.purpleAccent)
              : null,
        ),
      ),
    );
  }
}
