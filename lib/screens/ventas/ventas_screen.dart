// 📁 screens/ventas/ventas_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/venta_model.dart';
import 'package:agenda_fisio_spa_kym/services/venta_service.dart';
import 'venta_form.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final VentaService _ventaService = VentaService();
  late Future<List<VentaModel>> _ventasFuture;

  @override
  void initState() {
    super.initState();
    _ventasFuture = _ventaService.getVentas();
  }

  Future<void> _refresh() async {
    setState(() {
      _ventasFuture = _ventaService.getVentas();
    });
  }

  void _abrirFormulario({VentaModel? venta}) async {
    await showDialog(
      context: context,
      builder: (_) => VentaForm(ventaExistente: venta),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _abrirFormulario(),
          ),
        ],
      ),
      body: FutureBuilder<List<VentaModel>>(
        future: _ventasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final ventas = snapshot.data ?? [];
          if (ventas.isEmpty) {
            return const Center(child: Text('No hay ventas registradas.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: ventas.length,
              itemBuilder: (context, index) {
                final v = ventas[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(v.descripcion),
                    subtitle: Text('Monto: \$${v.monto.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _abrirFormulario(venta: v),
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
