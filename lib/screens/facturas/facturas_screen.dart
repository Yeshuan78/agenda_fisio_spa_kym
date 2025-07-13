import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:agenda_fisio_spa_kym/models/factura_model.dart';
import 'package:agenda_fisio_spa_kym/services/factura_service.dart';
import 'package:agenda_fisio_spa_kym/widgets/factura/factura_uploader_dialog.dart';
import 'package:agenda_fisio_spa_kym/screens/facturas/factura_form_screen.dart';
import 'package:agenda_fisio_spa_kym/widgets/factura/facturas_resumen_kpi.dart';
import 'package:agenda_fisio_spa_kym/widgets/factura/facturas_por_empresa_folder.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class FacturasScreen extends StatefulWidget {
  const FacturasScreen({super.key});

  @override
  State<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends State<FacturasScreen> {
  final _facturaService = FacturaService();
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'Cuentas por cobrar',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: kBrandPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                StreamBuilder<List<FacturaModel>>(
                  stream: _facturaService.obtenerFacturas(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final todas = snapshot.data!;
                    final filtradas = todas
                        .where((f) =>
                            f.empresaId.toLowerCase().contains(_filtro) ||
                            f.numeroFactura.toLowerCase().contains(_filtro))
                        .toList();

                    return FacturasResumenKPI(facturas: filtradas);
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Buscar por empresa o número de factura',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() => _filtro = value.toLowerCase());
                  },
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: StreamBuilder<List<FacturaModel>>(
                    stream: _facturaService.obtenerFacturas(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final facturas = snapshot.data!
                          .where((f) =>
                              f.empresaId.toLowerCase().contains(_filtro) ||
                              f.numeroFactura.toLowerCase().contains(_filtro))
                          .toList();

                      if (facturas.isEmpty) {
                        return const Center(
                          child: Text(
                            'No hay facturas que coincidan.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      // Agrupación por empresa + año
                      final agrupadas = groupBy(
                        facturas,
                        (FacturaModel f) =>
                            '${f.empresaId} ${f.fechaIngreso.year}',
                      );

                      return ListView(
                        padding: const EdgeInsets.only(bottom: 120),
                        children: agrupadas.entries.map((entry) {
                          final empresaYAnio = entry.key;
                          final lista = entry.value;

                          return FacturasPorEmpresaFolder(
                            empresa: empresaYAnio,
                            facturas: lista,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // ✅ FAB institucional
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: () {
              FacturaUploaderDialog.show(
                context,
                onCompleted: (archivos) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FacturaFormScreen(archivos: archivos),
                    ),
                  );
                },
              );
            },
            backgroundColor: kBrandPurple,
            label: const Text('Agregar'),
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Icon(Icons.receipt_long, size: 16, color: kBrandPurple),
            ),
          ),
        ),
      ],
    );
  }
}
