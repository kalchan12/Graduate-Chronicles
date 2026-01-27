import 'package:flutter/material.dart';
import '../../../../theme/design_system.dart';
import '../../../../models/yearbook_entry.dart';
import '../../profile/profile_screen.dart';
import '../../portfolio/portfolio_hub_screen.dart';

class YearbookProfileDialog extends StatelessWidget {
  final YearbookEntry entry;

  const YearbookProfileDialog({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.60,
      minChildSize: 0.40,
      maxChildSize: 0.90,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        decoration: BoxDecoration(
          color: DesignSystem.scaffoldBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                controller: controller,
                children: [
                  // Main Photo Section
                  Center(
                    child: Hero(
                      tag: 'yearbook_photo_${entry.id}',
                      child: Container(
                        width: 160, // Increased size slightly
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          image: entry.yearbookPhotoUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(entry.yearbookPhotoUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: entry.yearbookPhotoUrl.isEmpty
                              ? Colors.white.withValues(alpha: 0.05)
                              : null,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: entry.yearbookPhotoUrl.isEmpty
                            ? const Icon(
                                Icons.person_rounded,
                                color: Colors.white24,
                                size: 48,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name and School Info
                  Column(
                    children: [
                      Text(
                        entry.fullName ?? 'Unknown',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // School Badge
                      if (entry.school != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: DesignSystem.purpleAccent.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: DesignSystem.purpleAccent.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            entry.school!,
                            style: const TextStyle(
                              color: DesignSystem.purpleAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (entry.major != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          entry.major!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Quote / Bio Section
                  if (entry.yearbookBio != null &&
                      entry.yearbookBio!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.format_quote_rounded,
                            color: DesignSystem.purpleAccent,
                            size: 28,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            entry.yearbookBio!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Gallery Section (Explicit Separation)
                  if (entry.morePictures.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.collections_bookmark_rounded,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'MEMORY GALLERY',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 240, // Increased height for better presence
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: entry.morePictures.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // TODO: Full screen viewer if needed
                            },
                            child: Container(
                              width: 180, // Wider cards
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color(
                                  0xFF1E1E24,
                                ), // Fallback color
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    entry.morePictures[index],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              progress.expectedTotalBytes !=
                                                  null
                                              ? progress.cumulativeBytesLoaded /
                                                    progress.expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                          color: Colors.white24,
                                        ),
                                      );
                                    },
                                  ),
                                  // Gradient for subtle depth
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.3),
                                        ],
                                        stops: const [0.7, 1.0],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Navigate to Portfolio
                            // Note: Currently goes to current user portfolio as per existing routes
                            // Ideally this would accept entry.userId
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PortfolioHubScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'View Portfolio',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignSystem.purpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 8,
                            shadowColor: DesignSystem.purpleAccent.withValues(
                              alpha: 0.4,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Navigate to Profile
                            // Note: Currently goes to current user profile
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'View Profile',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
