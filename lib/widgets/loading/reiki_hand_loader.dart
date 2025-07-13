
import 'package:flutter/material.dart';

class ReikiHandLoader extends StatefulWidget {
  const ReikiHandLoader({super.key});

  @override
  State<ReikiHandLoader> createState() => _ReikiHandLoaderState();
}

class _ReikiHandLoaderState extends State<ReikiHandLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _glow = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCirc),
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
        animation: _glow,
        builder: (context, child) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(_glow.value),
                  blurRadius: 20 * _glow.value,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.front_hand, color: Colors.white, size: 32),
            ),
          );
        },
      ),
    );
  }
}
