
import 'package:flutter/material.dart';

class LogoPulseLoader extends StatefulWidget {
  const LogoPulseLoader({super.key});

  @override
  State<LogoPulseLoader> createState() => _LogoPulseLoaderState();
}

class _LogoPulseLoaderState extends State<LogoPulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
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
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Image.asset(
              'assets/img/logo app son fondo.png',
              width: 100,
              height: 100,
            ),
          );
        },
      ),
    );
  }
}
