import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

/*
  FeaturedCarousel Widget.
  
  A reusable auto-swiping carousel for featured content.
  Features:
  - Automatic page transitions (configurable interval).
  - Vertical card design with clear separation.
  - Yearbook quote styling for descriptions.
  - Improved image visibility (top alignment).
  - Optimized Flex Ratios (70% Image / 30% Text).
*/

class FeaturedCarousel extends StatefulWidget {
  final List<FeaturedItem> items;
  final double height;
  final Duration autoScrollInterval;
  final Function(FeaturedItem)? onItemTap;

  const FeaturedCarousel({
    super.key,
    required this.items,
    this.height = 360, // Default increased to 360
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.items.length <= 1) return;

    _autoScrollTimer = Timer.periodic(widget.autoScrollInterval, (_) {
      if (!mounted) return;

      final nextPage = (_currentPage + 1) % widget.items.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
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

    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
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
                      scale = (1 - (index - page).abs() * 0.05).clamp(
                        0.95,
                        1.0,
                      );
                    }
                    return Transform.scale(
                      scale: scale,
                      child: _FeaturedCard(
                        item: widget.items[index],
                        onTap: widget.onItemTap,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (widget.items.length > 1) ...[
            const SizedBox(height: 12),
            _PageIndicator(
              count: widget.items.length,
              currentIndex: _currentPage,
            ),
          ],
        ],
      ),
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
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF2E1A36), // Solid dark background
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section (Top, 70%)
            Expanded(
              flex: 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter, // Focus on faces
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          color: DesignSystem.purpleAccent.withOpacity(0.5),
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (_, __, ___) => _imagePlaceholder(),
                    )
                  else
                    _imagePlaceholder(),

                  // Badge (Cleaner look)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.badge ?? 'FEATURED',
                        style: TextStyle(
                          color: DesignSystem.purpleAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Text Section (Bottom, 30%)
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2E1A36),
                  border: Border(
                    top: BorderSide(color: Color(0xFFE94CFF), width: 1.5),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16, // Slightly smaller to fix text
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (item.description != null)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.format_quote_rounded,
                                color: DesignSystem.purpleAccent.withOpacity(
                                  0.5,
                                ),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.description!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13, // Smaller for better fit
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'Georgia',
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF3A2743),
      child: Center(
        child: Icon(
          Icons.school_rounded,
          size: 48,
          color: Colors.white.withOpacity(0.2),
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
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? DesignSystem.purpleAccent
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
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
