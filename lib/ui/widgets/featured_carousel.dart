import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

/*
  FeaturedCarousel Widget.
  
  A reusable auto-swiping carousel for featured content.
  Features:
  - Automatic page transitions (configurable interval).
  - Glassmorphic card design.
  - Image + title + description display.
  - Manual swipe support.
  - Only renders if items are provided (no placeholders).
*/

class FeaturedCarousel extends StatefulWidget {
  final List<FeaturedItem> items;
  final double height;
  final Duration autoScrollInterval;
  final Function(FeaturedItem)? onItemTap;

  const FeaturedCarousel({
    super.key,
    required this.items,
    this.height = 200,
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
    _pageController = PageController();
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
    // Don't render if no items
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
                return _FeaturedCard(
                  item: widget.items[index],
                  onTap: widget.onItemTap,
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
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF251029).withValues(alpha: 0.95),
              const Color(0xFF151019).withValues(alpha: 0.9),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Image Section
            SizedBox(
              width: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.imageUrl != null)
                    Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  else
                    _imagePlaceholder(),
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF251029).withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DesignSystem.purpleAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: DesignSystem.purpleAccent.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Text(
                        item.badge ?? 'FEATURED',
                        style: TextStyle(
                          color: DesignSystem.purpleAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.description!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
      color: const Color(0xFF3A2738),
      child: const Center(
        child: Icon(Icons.image, size: 32, color: Colors.white12),
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
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: isActive
                ? DesignSystem.purpleAccent
                : Colors.white.withValues(alpha: 0.2),
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
