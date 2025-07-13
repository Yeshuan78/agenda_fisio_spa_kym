import 'package:flutter/material.dart';

class LotusFlowerLoader extends StatefulWidget {
  const LotusFlowerLoader({super.key});

  @override
  State<LotusFlowerLoader> createState() => _LotusFlowerLoaderState();
}

class _LotusFlowerLoaderState extends State<LotusFlowerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.7, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.03),
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(Icons.spa, color: Colors.white, size: 28),
              ),
            ),
          );
        },
      ),
    );
  }
}
