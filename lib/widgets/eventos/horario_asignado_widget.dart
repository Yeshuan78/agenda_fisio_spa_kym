import 'package:flutter/material.dart';

class HorarioAsignadoWidget extends StatelessWidget {
  final String horaInicio;
  final String horaFin;
  final Function(String nuevaHoraInicio, String nuevaHoraFin) onEditar;
  final bool editable;

  const HorarioAsignadoWidget({
    super.key,
    required this.horaInicio,
    required this.horaFin,
    required this.onEditar,
    this.editable = true,
  });

  Future<void> _editarHorario(BuildContext context) async {
    final TimeOfDay? nuevaInicio = await showTimePicker(
      context: context,
      initialTime:
          _parseHora(horaInicio) ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (nuevaInicio == null) return;

    final TimeOfDay? nuevaFin = await showTimePicker(
      context: context,
      initialTime: _parseHora(horaFin) ??
          TimeOfDay(hour: nuevaInicio.hour + 1, minute: 0),
    );

    if (nuevaFin == null) return;

    final nuevoInicioStr = nuevaInicio.format(context);
    final nuevoFinStr = nuevaFin.format(context);

    onEditar(nuevoInicioStr, nuevoFinStr);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Horario actualizado: $nuevoInicioStr – $nuevoFinStr'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  TimeOfDay? _parseHora(String hora) {
    try {
      final parts = hora.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 16, color: Colors.black45),
        const SizedBox(width: 6),
        Text(
          '$horaInicio – $horaFin',
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
        if (editable) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _editarHorario(context),
            child: const Icon(Icons.edit, size: 16, color: Colors.purple),
          ),
        ],
      ],
    );
  }
}
