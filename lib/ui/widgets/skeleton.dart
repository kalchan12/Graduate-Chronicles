import 'package:flutter/material.dart';

class SkeletonBase extends StatefulWidget {
  final double? width;
  final double? height;
  final ShapeBorder shape;
  final EdgeInsetsGeometry? margin;

  const SkeletonBase({
    super.key,
    this.width,
    this.height,
    this.shape = const RoundedRectangleBorder(),
    this.margin,
  });

  @override
  State<SkeletonBase> createState() => _SkeletonBaseState();
}

class _SkeletonBaseState extends State<SkeletonBase>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.05, end: 0.15).animate(_controller),
        child: Container(
          decoration: ShapeDecoration(color: Colors.white, shape: widget.shape),
        ),
      ),
    );
  }
}

class SkeletonStoryCard extends StatelessWidget {
  const SkeletonStoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: const SkeletonBase(
              width: 64,
              height: 64,
              shape: CircleBorder(),
            ),
          ),
          const SizedBox(height: 6),
          const SkeletonBase(
            width: 50,
            height: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonFeaturedCard extends StatelessWidget {
  const SkeletonFeaturedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1A36),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: SkeletonBase(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
          ),
          // Badge
          Positioned(
            top: 16,
            left: 16,
            child: SkeletonBase(
              width: 80,
              height: 28,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          // Text Content
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBase(
                    width: 160,
                    height: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SkeletonBase(width: 2, height: 14),
                      const SizedBox(width: 8),
                      const SkeletonBase(
                        width: 120,
                        height: 14,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const SkeletonBase(
                  width: 40,
                  height: 40,
                  shape: CircleBorder(),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBase(
                      width: 100,
                      height: 14,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    SizedBox(height: 6),
                    SkeletonBase(
                      width: 60,
                      height: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content Lines
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBase(
                  width: double.infinity,
                  height: 14,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
                SizedBox(height: 8),
                SkeletonBase(
                  width: 200,
                  height: 14,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Media Placeholder
          const SkeletonBase(width: double.infinity, height: 300),
          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                SkeletonBase(
                  width: 60,
                  height: 24,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
                SizedBox(width: 20),
                SkeletonBase(
                  width: 60,
                  height: 24,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
