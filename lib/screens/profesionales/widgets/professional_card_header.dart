import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/professional_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class ProfessionalCardHeader extends StatelessWidget {
  final ProfessionalModel profesional;
  final VoidCallback onEdit;
  final VoidCallback onDeleted;

  const ProfessionalCardHeader({
    super.key,
    required this.profesional,
    required this.onEdit,
    required this.onDeleted,
  });

  Future<void> _alternarEstado(BuildContext context) async {
    final nuevoEstado = !profesional.estado;
    await FirebaseFirestore.instance
        .collection('profesionales')
        .doc(profesional.id)
        .update({'estado': nuevoEstado});

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nuevoEstado ? 'Profesional activado' : 'Profesional desactivado',
        ),
        backgroundColor: nuevoEstado ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<Map<String, Color>> _coloresEspecialidades() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('especialidades').get();
    final Map<String, Color> coloresMap = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final categoria = (data['categoria'] ?? '').toString().toLowerCase();
      coloresMap[data['nombre']] = _colorPorCategoria(categoria);
    }
    return coloresMap;
  }

  Color _colorPorCategoria(String categoria) {
    switch (categoria) {
      case 'masajes':
        return const Color(0xFFE1F5FE);
      case 'faciales':
        return const Color(0xFFFFF3E0);
      case 'fisioterapia':
        return const Color(0xFFE8F5E9);
      case 'podología':
        return const Color(0xFFF3E5F5);
      default:
        return kAccentBlue.withValues(alpha: 0.09);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombreCompleto = '${profesional.nombre} ${profesional.apellidos}';
    final serviciosCount = profesional.servicios.length;

    return FutureBuilder<Map<String, Color>>(
        future: _coloresEspecialidades(),
        builder: (context, snapshot) {
          final colores = snapshot.data ?? {};
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreCompleto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profesional.email}   |   ${profesional.telefono}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _alternarEstado(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: profesional.estado
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              profesional.estado ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                fontSize: 12,
                                color: profesional.estado
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Servicios asignados: $serviciosCount',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: profesional.especialidades.map((nombre) {
                        final color = colores[nombre] ??
                            kAccentBlue.withValues(alpha: 0.02);
                        return EtiquetaEspecialidadProfesional(
                          nombre: nombre,
                          colorFondo: color,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Tooltip(
                        message: 'Últimas citas (mock)',
                        preferBelow: false,
                        child: IconButton(
                          icon: const Icon(Icons.calendar_today_outlined),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Últimas citas'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    ListTile(
                                      dense: true,
                                      title: Text('10 May 2025'),
                                      subtitle: Text('Asistida — Juan Pérez'),
                                    ),
                                    ListTile(
                                      dense: true,
                                      title: Text('08 May 2025'),
                                      subtitle: Text('Cancelada — María López'),
                                    ),
                                    ListTile(
                                      dense: true,
                                      title: Text('05 May 2025'),
                                      subtitle:
                                          Text('No asistió — Laura Hernández'),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cerrar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: onDeleted,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        });
  }
}

class EtiquetaEspecialidadProfesional extends StatelessWidget {
  final String nombre;
  final Color colorFondo;

  const EtiquetaEspecialidadProfesional({
    super.key,
    required this.nombre,
    required this.colorFondo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        nombre,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
