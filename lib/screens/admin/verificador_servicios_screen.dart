import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class VerificadorServiciosScreen extends StatefulWidget {
  const VerificadorServiciosScreen({super.key});

  @override
  State<VerificadorServiciosScreen> createState() =>
      _VerificadorServiciosScreenState();
}

class _VerificadorServiciosScreenState
    extends State<VerificadorServiciosScreen> {
  int _serviciosValidos = 0;
  int _serviciosAntiguos = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _verificarServicios();
  }

  Future<void> _verificarServicios() async {
    setState(() => _cargando = true);

    final snapshot =
        await FirebaseFirestore.instance.collection('services').get();

    int validos = 0;
    int antiguos = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final name = data['name']?.toString().trim() ?? '';
      final id = doc.id.trim();

      if (id == name) {
        antiguos++;
      } else {
        validos++;
      }
    }

    setState(() {
      _serviciosValidos = validos;
      _serviciosAntiguos = antiguos;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBrandPurple,
        title: const Text("Verificador de servicios"),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Resultado de la verificación:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        "Servicios válidos con ID real: $_serviciosValidos",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        "Servicios antiguos con ID igual a nombre: $_serviciosAntiguos",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Volver a verificar"),
                    onPressed: _verificarServicios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBrandPurple,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
