import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventoQRDialog extends StatelessWidget {
  final Map<String, dynamic> evento;
  final String eventoId;

  const EventoQRDialog(
      {super.key, required this.evento, required this.eventoId});

  Future<String> _obtenerNombreProfesional(String id) async {
    final doc = await FirebaseFirestore.instance
        .collection('profesionales')
        .doc(id)
        .get();
    return doc.exists ? (doc.data()?['nombre'] ?? id) : id;
  }

  Future<String> _obtenerNombreServicio(String id) async {
    final doc =
        await FirebaseFirestore.instance.collection('services').doc(id).get();
    return doc.exists ? (doc.data()?['name'] ?? id) : id;
  }

  @override
  Widget build(BuildContext context) {
    final asignados = evento['serviciosAsignados'] as List<dynamic>? ?? [];

    return AlertDialog(
      title: const Text('Códigos QR por combinación'),
      content: SizedBox(
        width: 600,
        height: 500,
        child: asignados.isEmpty
            ? const Center(child: Text('No hay servicios asignados'))
            : FutureBuilder<List<Widget>>(
                future: _generarQRs(asignados),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  return ListView(children: snapshot.data!);
                },
              ),
      ),
      actions: [
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }

  Future<List<Widget>> _generarQRs(List asignados) async {
    List<Widget> widgets = [];

    for (final item in asignados) {
      final profesionalId = item['profesionalId'];
      final servicioId = item['servicioId'];

      final nombreProfesional = await _obtenerNombreProfesional(profesionalId);
      final nombreServicio = await _obtenerNombreServicio(servicioId);

      final url =
          'https://fisiospakym.com/kym-pulse/?e=$eventoId&p=$profesionalId&s=$servicioId';

      widgets.add(
        Card(
          margin: const EdgeInsets.symmetric(vertical: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$nombreProfesional - $nombreServicio',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Center(
                  child: QrImageView(
                    data: url,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  url,
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                )
              ],
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
