import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class ProfessionalTabHorario extends StatefulWidget {
  final List<Map<String, dynamic>> disponibilidad;
  final void Function(List<Map<String, dynamic>>) onChanged;

  const ProfessionalTabHorario({
    super.key,
    required this.disponibilidad,
    required this.onChanged,
  });

  @override
  State<ProfessionalTabHorario> createState() => _ProfessionalTabHorarioState();
}

class _ProfessionalTabHorarioState extends State<ProfessionalTabHorario> {
  final List<String> diasSemana = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo'
  ];

  late List<bool> diasActivos;
  late List<TimeOfDay> horaInicio;
  late List<TimeOfDay> horaFin;
  late List<List<Map<String, dynamic>>> bloqueosPorDia;

  @override
  void initState() {
    super.initState();
    diasActivos = List.generate(7, (_) => false);
    horaInicio = List.generate(7, (_) => const TimeOfDay(hour: 10, minute: 0));
    horaFin = List.generate(7, (_) => const TimeOfDay(hour: 20, minute: 0));
    bloqueosPorDia = List.generate(7, (_) => []);

    for (var i = 0; i < 7; i++) {
      final dia = diasSemana[i];

      final entrada = widget.disponibilidad.firstWhere(
        (d) => d['dia'] == dia,
        orElse: () => {'dia': dia, 'bloques': []},
      );

      final bloques = List<Map<String, dynamic>>.from(entrada['bloques']);
      if (bloques.isNotEmpty) {
        diasActivos[i] = true;
        final b0 = bloques[0];
        horaInicio[i] = _parseTime(b0['inicio']) ?? horaInicio[i];
        horaFin[i] = _parseTime(b0['fin']) ?? horaFin[i];

        bloqueosPorDia[i] = bloques.skip(1).map((b) {
          return {
            'inicio':
                _parseTime(b['inicio']) ?? const TimeOfDay(hour: 14, minute: 0),
            'fin': _parseTime(b['fin']) ?? const TimeOfDay(hour: 15, minute: 0),
            'nombre': b['nombre'] ?? '',
          };
        }).toList();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _emitirCambio());
  }

  TimeOfDay? _parseTime(dynamic v) {
    if (v is String) {
      final parts = v.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return null;
  }

  String _formatTime(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat('HH:mm').format(dt);
  }

  void _seleccionarHora(int dia, String tipo, int? bloqueIdx) async {
    final actual = (bloqueIdx != null
        ? bloqueosPorDia[dia][bloqueIdx][tipo]
        : (tipo == 'inicio' ? horaInicio[dia] : horaFin[dia])) as TimeOfDay;

    final seleccionada = await showTimePicker(
      context: context,
      initialTime: actual,
    );

    if (seleccionada != null) {
      setState(() {
        if (bloqueIdx != null) {
          bloqueosPorDia[dia][bloqueIdx][tipo] = seleccionada;
        } else {
          if (tipo == 'inicio') {
            horaInicio[dia] = seleccionada;
          } else {
            horaFin[dia] = seleccionada;
          }
        }
      });
      _emitirCambio();
    }
  }

  void _emitirCambio() {
    final List<Map<String, dynamic>> resultado = [];

    for (var i = 0; i < 7; i++) {
      if (!diasActivos[i]) continue;

      final bloques = [
        {
          'inicio': _formatTime(horaInicio[i]),
          'fin': _formatTime(horaFin[i]),
          'nombre': 'Disponible',
        },
        ...bloqueosPorDia[i].map((b) => {
              'inicio': _formatTime(b['inicio']),
              'fin': _formatTime(b['fin']),
              'nombre': (b['nombre'] as String).trim().isEmpty
                  ? 'Bloqueo'
                  : b['nombre'],
            })
      ];

      resultado.add({'dia': diasSemana[i], 'bloques': bloques});
    }

    widget.onChanged(resultado);
  }

  void _agregarBloqueo(int dia) {
    setState(() {
      bloqueosPorDia[dia].add({
        'inicio': const TimeOfDay(hour: 14, minute: 0),
        'fin': const TimeOfDay(hour: 15, minute: 0),
        'nombre': '',
      });
    });
    _emitirCambio();
  }

  void _eliminarBloqueo(int dia, int i) {
    setState(() {
      bloqueosPorDia[dia].removeAt(i);
    });
    _emitirCambio();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 7,
      shrinkWrap: true,
      itemBuilder: (_, i) {
        final nombreDia =
            diasSemana[i][0].toUpperCase() + diasSemana[i].substring(1);
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              elevation: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Switch(
                              activeColor: kBrandPurple,
                              inactiveTrackColor: Colors.grey.shade300,
                              value: diasActivos[i],
                              onChanged: (v) {
                                setState(() => diasActivos[i] = v);
                                _emitirCambio();
                              },
                            ),
                            Text(
                              nombreDia,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    diasActivos[i] ? kBrandPurple : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: diasActivos[i]
                                  ? () => _seleccionarHora(i, 'inicio', null)
                                  : null,
                              child:
                                  Text('Desde: ${_formatTime(horaInicio[i])}'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: diasActivos[i]
                                  ? () => _seleccionarHora(i, 'fin', null)
                                  : null,
                              child: Text('Hasta: ${_formatTime(horaFin[i])}'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (diasActivos[i])
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            ...bloqueosPorDia[i].asMap().entries.map((entry) {
                              final j = entry.key;
                              final b = entry.value;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () => _seleccionarHora(
                                                i, 'inicio', j),
                                            child: Text(
                                                'Bloqueo desde: ${_formatTime(b['inicio'])}'),
                                          ),
                                          const SizedBox(width: 12),
                                          TextButton(
                                            onPressed: () =>
                                                _seleccionarHora(i, 'fin', j),
                                            child: Text(
                                                'Hasta: ${_formatTime(b['fin'])}'),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _eliminarBloqueo(i, j),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: TextFormField(
                                          initialValue: b['nombre'],
                                          decoration: const InputDecoration(
                                            labelText: 'Nombre del bloqueo',
                                            hintText:
                                                'Ej: Almuerzo, Reunión...',
                                          ),
                                          onChanged: (v) {
                                            setState(() => bloqueosPorDia[i][j]
                                                ['nombre'] = v);
                                            _emitirCambio();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            TextButton.icon(
                              onPressed: () => _agregarBloqueo(i),
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar bloqueo'),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
