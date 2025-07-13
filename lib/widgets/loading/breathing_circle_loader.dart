import 'package:flutter/material.dart';

class BreathingCircleLoader extends StatefulWidget {
  const BreathingCircleLoader({super.key});

  @override
  State<BreathingCircleLoader> createState() => _BreathingCircleLoaderState();
}

class _BreathingCircleLoaderState extends State<BreathingCircleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
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
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.07),
              ),
              child: const Center(
                child:
                    Icon(Icons.self_improvement, color: Colors.white, size: 30),
              ),
            ),
          );
        },
      ),
    );
  }
}
