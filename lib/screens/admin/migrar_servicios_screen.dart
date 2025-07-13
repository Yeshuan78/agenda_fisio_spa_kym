import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class MigrarServiciosScreen extends StatefulWidget {
  const MigrarServiciosScreen({super.key});

  @override
  State<MigrarServiciosScreen> createState() => _MigrarServiciosScreenState();
}

class _MigrarServiciosScreenState extends State<MigrarServiciosScreen> {
  bool _cargando = false;
  bool _completado = false;
  List<String> _errores = [];

  Future<void> _migrarServicios() async {
    setState(() {
      _cargando = true;
      _completado = false;
      _errores = [];
    });

    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('services').get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      try {
        await firestore.collection('services').add({
          'name': data['name'] ?? '',
          'category': data['category'] ?? '',
          'price': data['price'] ?? 0,
          'duration': data['duration'] ?? 0,
          'image': data['image'] ?? '',
          'description': data['description'] ?? '',
        });
      } catch (e) {
        _errores.add("Error con '${data['name']}': $e");
      }
    }

    setState(() {
      _cargando = false;
      _completado = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBrandPurple,
        title: const Text("Migrar servicios con ID real"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Este módulo migrará todos los servicios actuales (con ID = nombre) a nuevos documentos con ID generado automáticamente por Firestore.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text("Migrar servicios"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPurple,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _migrarServicios,
                  ),
                  const SizedBox(height: 24),
                  if (_completado)
                    const Text("✅ Migración completada correctamente."),
                  if (_errores.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text("⚠️ Errores encontrados:"),
                    for (final e in _errores)
                      Text(
                        "- $e",
                        style: const TextStyle(color: Colors.red),
                      )
                  ],
                ],
              ),
      ),
    );
  }
}
