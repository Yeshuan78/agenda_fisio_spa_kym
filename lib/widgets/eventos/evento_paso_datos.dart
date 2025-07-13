// [Archivo: widgets/eventos/evento_paso_datos.dart]
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventoPasoDatos extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController empresaController;
  final TextEditingController ubicacionController;
  final TextEditingController observacionesController;
  final DateTime fecha;
  final String estado;
  final Function(DateTime) onFechaChanged;
  final Function(String) onEstadoChanged;

  const EventoPasoDatos({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.empresaController,
    required this.ubicacionController,
    required this.observacionesController,
    required this.fecha,
    required this.estado,
    required this.onFechaChanged,
    required this.onEstadoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nombreController,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: empresaController,
            decoration: const InputDecoration(labelText: 'Empresa'),
            validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: ubicacionController,
            decoration: const InputDecoration(labelText: 'Ubicación'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: observacionesController,
            decoration: const InputDecoration(labelText: 'Observaciones'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            readOnly: true,
            controller: TextEditingController(
              text: DateFormat('yyyy-MM-dd').format(fecha),
            ),
            decoration: const InputDecoration(
              labelText: 'Fecha del evento',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: fecha,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                onFechaChanged(picked);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: estado,
            items: const [
              DropdownMenuItem(value: 'activo', child: Text('Activo')),
              DropdownMenuItem(value: 'cerrado', child: Text('Cerrado')),
            ],
            onChanged: (val) => onEstadoChanged(val ?? 'activo'),
            decoration: const InputDecoration(labelText: 'Estado'),
          ),
        ],
      ),
    );
  }
}
