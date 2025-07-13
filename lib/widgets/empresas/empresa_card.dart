import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/models/empresa_model.dart';
import 'package:agenda_fisio_spa_kym/screens/kym_pulse/eventos_screen.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EmpresaCard extends StatefulWidget {
  final EmpresaModel empresa;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const EmpresaCard({
    super.key,
    required this.empresa,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  State<EmpresaCard> createState() => _EmpresaCardState();
}

class _EmpresaCardState extends State<EmpresaCard> {
  late String estadoLocal;

  @override
  void initState() {
    super.initState();
    estadoLocal = widget.empresa.estado;
  }

  Future<void> _toggleEstado() async {
    final nuevoEstado = estadoLocal == 'activo' ? 'inactivo' : 'activo';
    await FirebaseFirestore.instance
        .collection('empresas')
        .doc(widget.empresa.empresaId)
        .update({'estado': nuevoEstado});
    setState(() {
      estadoLocal = nuevoEstado;
    });
  }

  @override
  Widget build(BuildContext context) {
    final direccionResumen = widget.empresa.direccion ?? '';
    final ciudad = widget.empresa.ciudad ?? '';
    final mostrarLineaDireccion =
        ciudad.isNotEmpty || direccionResumen.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.empresa.nombre,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('RFC: ${widget.empresa.rfc}'),
                      if (widget.empresa.razonSocial != null &&
                          widget.empresa.razonSocial!.isNotEmpty)
                        Text('Razón social: ${widget.empresa.razonSocial}'),
                      if (mostrarLineaDireccion)
                        Tooltip(
                          message: direccionResumen,
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      if (ciudad.isNotEmpty)
                                        TextSpan(text: 'Ciudad: $ciudad'),
                                      if (ciudad.isNotEmpty &&
                                          direccionResumen.isNotEmpty)
                                        const TextSpan(text: ' · '),
                                      if (direccionResumen.isNotEmpty)
                                        TextSpan(
                                          text: direccionResumen,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _toggleEstado,
                      child: Chip(
                        label: Text(estadoLocal.toUpperCase()),
                        backgroundColor: estadoLocal == 'activo'
                            ? Colors.green.shade50
                            : Colors.grey.shade300,
                        labelStyle: TextStyle(
                          color: estadoLocal == 'activo'
                              ? Colors.green
                              : Colors.grey.shade600,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EventosScreen(),
                                settings: RouteSettings(
                                  arguments: widget.empresa.empresaId,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.event_available_outlined),
                          label: const Text('Ver eventos'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Editar',
                          onPressed: widget.onEditar,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Eliminar',
                          onPressed: widget.onEliminar,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('📇 Contactos:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            ...widget.empresa.contactos.map((contacto) {
              final nombre = contacto['nombre'] ?? '';
              final area = contacto['area'] ?? '';
              final correo = contacto['correo'] ?? '';
              return Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Text('$nombre ($area)')),
                  const SizedBox(width: 12),
                  Text(correo, style: const TextStyle(fontSize: 12)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
