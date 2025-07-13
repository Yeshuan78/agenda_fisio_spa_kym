import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventoPasoServicios extends StatefulWidget {
  final List<Map<String, dynamic>> serviciosDisponibles;
  final List<Map<String, dynamic>> profesionales;
  final List<Map<String, String>> serviciosAsignados;
  final Function(String servicioId, String profesionalId, DateTime fecha)
      onAsignar;

  const EventoPasoServicios({
    super.key,
    required this.serviciosDisponibles,
    required this.profesionales,
    required this.serviciosAsignados,
    required this.onAsignar,
  });

  @override
  State<EventoPasoServicios> createState() => _EventoPasoServiciosState();
}

class _EventoPasoServiciosState extends State<EventoPasoServicios> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: widget.serviciosDisponibles.map((servicio) {
              final servicioId = servicio['id'];

              final asignacion = widget.serviciosAsignados.firstWhere(
                (a) => a['servicioId'] == servicioId,
                orElse: () => {
                  'profesionalId': '',
                  'fecha': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                },
              );

              final profesionalId = asignacion['profesionalId'] ?? '';
              final fechaStr = asignacion['fecha'] ??
                  DateFormat('yyyy-MM-dd').format(DateTime.now());

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(servicio['nombre'],
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButton<String>(
                            value: profesionalId.isEmpty ? null : profesionalId,
                            hint: const Text('Profesional'),
                            items: widget.profesionales
                                .map<DropdownMenuItem<String>>((p) {
                              return DropdownMenuItem<String>(
                                value: p['id'],
                                child: Text(p['nombre']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null && val.isNotEmpty) {
                                widget.onAsignar(
                                  servicioId,
                                  val,
                                  DateTime.tryParse(fechaStr) ?? DateTime.now(),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            readOnly: true,
                            controller: TextEditingController(text: fechaStr),
                            decoration: const InputDecoration(
                              labelText: 'Fecha',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.tryParse(fechaStr) ??
                                    DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                widget.onAsignar(
                                  servicioId,
                                  profesionalId,
                                  picked,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
