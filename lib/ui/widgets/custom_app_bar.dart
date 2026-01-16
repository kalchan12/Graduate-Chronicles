import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

/*
  Custom Application Bar.

  A reusable AppBar widget that matches the design system.
  - Purely visual; requires manual navigation handling if not using default back.
  - Supports title, optional leading widget (defaulting to back arrow), and trailing actions.
  - Transparent background to blend with the global gradient.
*/
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showLeading;
  final VoidCallback? onLeading;
  final Widget? trailing;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showLeading = true,
    this.onLeading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      color: DesignSystem.scaffoldBg.withValues(alpha: 0.0),
      child: Row(
        children: [
          if (showLeading)
            GestureDetector(
              onTap: onLeading ?? () {},
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
            )
          else
            const SizedBox(width: 40),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          trailing ?? const SizedBox(width: 40),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
