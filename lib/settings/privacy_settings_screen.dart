import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/design_system.dart';
import 'providers/settings_provider.dart';
import 'widgets/settings_tile.dart';
import '../../ui/auth/forgot/set_new_password_screen.dart'; // Direct import or use named route
import '../../ui/widgets/global_background.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    void showTwoFactorSetup() {
      final codeController = TextEditingController(
        text: settings.twoFactorCode ?? '',
      );
      final isEditing = settings.twoFactorAuth;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Handle keyboard
        backgroundColor: const Color(0xFF1C1022),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.security,
                size: 48,
                color: DesignSystem.purpleAccent,
              ),
              const SizedBox(height: 16),
              Text(
                isEditing
                    ? 'Update Two-Factor Code'
                    : 'Enable Two-Factor Authentication',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isEditing
                    ? 'Enter a new security code to update your settings.'
                    : 'Enter a security code to enable 2FA protection.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 24),
              // Real Input Field
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2D2433),
                  counterText: '',
                  hintText: '0000',
                  hintStyle: const TextStyle(
                    color: Colors.white24,
                    letterSpacing: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: DesignSystem.purpleAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  if (isEditing) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          notifier.toggleTwoFactorAuth(false);
                          notifier.setTwoFactorCode(''); // Clear code
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('2FA Disabled Successfully'),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Disable 2FA'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (codeController.text.length < 4) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Code must be at least 4 digits'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        notifier.setTwoFactorCode(codeController.text);
                        notifier.toggleTwoFactorAuth(true);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEditing
                                  ? '2FA Updated Successfully'
                                  : '2FA Enabled Successfully',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.purpleAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Save Changes' : 'Verify & Enable',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    void confirmDisable2FA() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF231B26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Disable 2FA?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to disable Two-Factor Authentication? Your account will be less secure.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () {
                notifier.toggleTwoFactorAuth(false);
                notifier.setTwoFactorCode(''); // Clear code on disable
                Navigator.pop(context);
              },
              child: const Text(
                'Disable',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Privacy & Security',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const _SectionHeader(title: 'SECURITY'),
              SettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SetNewPasswordScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Custom tile for 2FA with switch
              GestureDetector(
                onTap: () {
                  // Allow tapping to edit/view if already enabled
                  if (settings.twoFactorAuth) {
                    showTwoFactorSetup();
                  }
                },
                child: Container(
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
                        child: const Icon(
                          Icons.security,
                          color: Color(0xFFBDB1C9),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Two-Factor Authentication',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              settings.twoFactorAuth
                                  ? 'Tap to manage code'
                                  : 'Enable 2FA for extra security',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: settings.twoFactorAuth,
                        onChanged: (v) {
                          if (v) {
                            showTwoFactorSetup();
                          } else {
                            confirmDisable2FA();
                          }
                        },
                        activeThumbColor: Colors.white,
                        activeTrackColor: DesignSystem.purpleAccent,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.white24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'DATA PRIVACY'),
              // Placeholder for Data Privacy items if needed
              SettingsTile(
                icon: Icons.policy,
                title: 'Privacy Policy',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Privacy Policy...')),
                  );
                },
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
