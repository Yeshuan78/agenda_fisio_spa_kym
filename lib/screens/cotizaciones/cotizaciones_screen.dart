// 📁 screens/cotizaciones/cotizaciones_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/cotizacion_model.dart';
import 'package:agenda_fisio_spa_kym/services/cotizacion_service.dart';
import 'cotizacion_form.dart';

class CotizacionesScreen extends StatefulWidget {
  const CotizacionesScreen({super.key});

  @override
  State<CotizacionesScreen> createState() => _CotizacionesScreenState();
}

class _CotizacionesScreenState extends State<CotizacionesScreen> {
  final CotizacionService _cotizacionService = CotizacionService();
  late Future<List<CotizacionModel>> _cotizacionesFuture;

  @override
  void initState() {
    super.initState();
    _cotizacionesFuture = _cotizacionService.getCotizaciones();
  }

  Future<void> _refresh() async {
    setState(() {
      _cotizacionesFuture = _cotizacionService.getCotizaciones();
    });
  }

  void _abrirFormulario({CotizacionModel? cotizacion}) async {
    await showDialog(
      context: context,
      builder: (_) => CotizacionForm(cotizacionExistente: cotizacion),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _abrirFormulario(),
          ),
        ],
      ),
      body: FutureBuilder<List<CotizacionModel>>(
        future: _cotizacionesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cotizaciones = snapshot.data ?? [];
          if (cotizaciones.isEmpty) {
            return const Center(
                child: Text('No hay cotizaciones registradas.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: cotizaciones.length,
              itemBuilder: (context, index) {
                final c = cotizaciones[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title:
                        Text('Monto: \$${c.montoPropuesto.toStringAsFixed(2)}'),
                    subtitle: Text('Estado: ${c.estado}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _abrirFormulario(cotizacion: c),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
