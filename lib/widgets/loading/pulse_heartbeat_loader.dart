import 'package:flutter/material.dart';

class PulseHeartbeatLoader extends StatefulWidget {
  final String mensaje;
  const PulseHeartbeatLoader({
    super.key,
    this.mensaje = '',
  });

  @override
  State<PulseHeartbeatLoader> createState() => _PulseHeartbeatLoaderState();
}

class _PulseHeartbeatLoaderState extends State<PulseHeartbeatLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulse.value,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.08),
                  ),
                  child: const Center(
                    child: Icon(Icons.favorite, color: Colors.white, size: 60),
                  ),
                ),
              );
            },
          ),
          if (widget.mensaje.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.mensaje,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
