import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class MigrarServiciosDesdeCategoriasScreen extends StatefulWidget {
  const MigrarServiciosDesdeCategoriasScreen({super.key});

  @override
  State<MigrarServiciosDesdeCategoriasScreen> createState() =>
      _MigrarServiciosDesdeCategoriasScreenState();
}

class _MigrarServiciosDesdeCategoriasScreenState
    extends State<MigrarServiciosDesdeCategoriasScreen> {
  bool _cargando = false;
  List<String> _errores = [];
  int _migrados = 0;

  Future<void> _migrarServicios() async {
    setState(() {
      _cargando = true;
      _errores = [];
      _migrados = 0;
    });

    final firestore = FirebaseFirestore.instance;

    try {
      final categoriasSnap = await firestore.collection('categories').get();

      for (final catDoc in categoriasSnap.docs) {
        final categoria = catDoc.id;
        final subcollection =
            await firestore.collection('categories/$categoria/services').get();

        for (final servDoc in subcollection.docs) {
          final data = servDoc.data();
          try {
            await firestore.collection('services').add({
              'name': data['name'] ?? '',
              'category': categoria,
              'price': data['price'] ?? 0,
              'duration': data['duration'] ?? 0,
              'image': data['image'] ?? '',
              'description': data['description'] ?? '',
            });
            _migrados++;
          } catch (e) {
            _errores.add("Error en '$categoria/${servDoc.id}': $e");
          }
        }
      }
    } catch (e) {
      _errores.add("Error global: $e");
    }

    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBrandPurple,
        title: const Text("Migrar servicios desde categorías"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Este módulo copiará todos los servicios de:\n"
                    "categories/{nombre}/services → services/",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.system_update),
                    label: const Text("Ejecutar migración"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPurple,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _migrarServicios,
                  ),
                  const SizedBox(height: 24),
                  if (_migrados > 0)
                    Text("✅ $_migrados servicios migrados correctamente.",
                        style:
                            const TextStyle(color: Colors.green, fontSize: 16)),
                  if (_errores.isNotEmpty) ...[
                    const Text("⚠️ Errores detectados:"),
                    ..._errores.map((e) => Text("- $e",
                        style:
                            const TextStyle(fontSize: 13, color: Colors.red)))
                  ]
                ],
              ),
      ),
    );
  }
}
