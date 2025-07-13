import 'package:flutter/material.dart';

class MusicNotesLoader extends StatefulWidget {
  const MusicNotesLoader({super.key});

  @override
  State<MusicNotesLoader> createState() => _MusicNotesLoaderState();
}

class _MusicNotesLoaderState extends State<MusicNotesLoader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _offsetY = Tween<double>(begin: 50, end: -30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _note(IconData icon, double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = _offsetY.value + delay;
        return Transform.translate(
          offset: Offset(0, offset % 80),
          child:
              Icon(icon, size: 24, color: Colors.white.withValues(alpha: 0.09)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _note(Icons.music_note, 0),
          _note(Icons.music_note_outlined, 10),
          _note(Icons.queue_music, 20),
        ],
      ),
    );
  }
}
