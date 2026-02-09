import 'dart:async';
import 'dart:ui'; // For ImageFilter
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

/*
  FeaturedCarousel Widget.
  
  A reusable auto-swiping carousel for featured content.
  Features:
  - Automatic page transitions.
  - Modern "Full Card" design with glassmorphic overlay.
  - Responsive Viewport Fraction.
*/

class FeaturedCarousel extends StatefulWidget {
  final List<FeaturedItem> items;
  final double height;
  final Duration autoScrollInterval;
  final Function(FeaturedItem)? onItemTap;

  const FeaturedCarousel({
    super.key,
    required this.items,
    this.height = 450, // Increased height for better aspect ratio
    this.autoScrollInterval = const Duration(seconds: 5),
    this.onItemTap,
  });

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  // Default fraction for mobile; responsive logic in build
  final double _baseViewportFraction = 0.85;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _baseViewportFraction);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.items.length <= 1) return;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(widget.autoScrollInterval, (_) {
      if (!mounted) return;
      if (!_pageController.hasClients) return;

      final nextPage = (_currentPage + 1) % widget.items.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsiveness:
        // ideally we would change viewportFraction here but requires controller recreation.
        // For now, we stick to mobile-optimized 0.85.

        return SizedBox(
          height: widget.height,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  // We use a slightly smaller fraction to show next card
                  controller: _pageController,
                  itemCount: widget.items.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double scale = 1.0;
                        if (_pageController.position.haveDimensions) {
                          double page = _pageController.page ?? 0;
                          scale = (1 - (index - page).abs() * 0.1).clamp(
                            0.9,
                            1.0,
                          );
                        }

                        // Center the card
                        return Center(
                          child: SizedBox(
                            // Dynamic height based on scale
                            height:
                                Curves.easeOut.transform(scale) * widget.height,
                            // Responsive width: max 360px or 100% of fraction
                            // actually let PageView handle width, just scale content
                            child: _FeaturedCard(
                              item: widget.items[index],
                              onTap: widget.onItemTap,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (widget.items.length > 1) ...[
                const SizedBox(height: 16),
                _PageIndicator(
                  count: widget.items.length,
                  currentIndex: _currentPage,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final FeaturedItem item;
  final Function(FeaturedItem)? onTap;

  const _FeaturedCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8), // Gap between cards
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          boxShadow: [
            BoxShadow(
              color: DesignSystem.shadowColor(context),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full Height Image
            if (item.imageUrl != null)
              CachedNetworkImage(
                imageUrl: item.imageUrl!,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter, // Crucial for faces
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => _imagePlaceholder(),
              )
            else
              _imagePlaceholder(),

            // 2. Gradient Overlay (Bottom Protection)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Badge (Top Left)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: DesignSystem.purpleAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.badge?.toUpperCase() ?? 'FEATURED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Info Section (Bottom with Glassmorphism)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                        0.2,
                      ), // Darker for readability
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (item.description != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 2,
                                height: 14,
                                color: DesignSystem.purpleAccent,
                                margin: const EdgeInsets.only(right: 8),
                              ),
                              Expanded(
                                child: Text(
                                  item.description!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Builder(
      builder: (context) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.person_rounded,
            size: 64,
            color: DesignSystem.textSubtle(context),
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [DesignSystem.purpleAccent, Color(0xFFB030D0)],
                  )
                : null,
            color: isActive ? null : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

/// Data model for featured items
class FeaturedItem {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? badge;
  final Map<String, dynamic>? metadata;

  const FeaturedItem({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.badge,
    this.metadata,
  });

  factory FeaturedItem.fromMap(Map<String, dynamic> map, {String? badge}) {
    return FeaturedItem(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? map['full_name'] ?? map['caption'] ?? 'Untitled',
      description: map['description'] ?? map['major'] ?? map['subtitle'],
      imageUrl:
          map['image_url'] ?? map['cover_url'] ?? map['profile_picture_url'],
      badge: badge ?? map['badge'],
      metadata: map,
    );
  }
}
