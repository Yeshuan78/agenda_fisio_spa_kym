import 'package:flutter/material.dart';

class HoverCardServicio extends StatelessWidget {
  final String nombre;
  final String? duracion;
  final String? notas;

  const HoverCardServicio({
    super.key,
    required this.nombre,
    this.duracion,
    this.notas,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.008),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                color: Colors.black87,
              ),
            ),
            if (duracion != null && duracion!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('$duracion min.', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
            if (notas != null && notas!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Notas:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.5),
              ),
              const SizedBox(height: 2),
              Text(
                notas!,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
