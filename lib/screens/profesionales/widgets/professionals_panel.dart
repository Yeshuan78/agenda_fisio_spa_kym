import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/professional_model.dart';
import 'package:agenda_fisio_spa_kym/screens/profesionales/widgets/professional_card.dart';
import 'package:agenda_fisio_spa_kym/screens/profesionales/widgets/professional_crud_dialog.dart';

class ProfessionalsPanel extends StatelessWidget {
  final String filtroTexto;
  final String? filtroCategoria;
  final VoidCallback? onUpdated;
  final List<Map<String, dynamic>> serviciosDisponibles;

  const ProfessionalsPanel({
    super.key,
    required this.filtroTexto,
    required this.filtroCategoria,
    required this.serviciosDisponibles,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> categoriasDisponibles = serviciosDisponibles
        .map((s) => s['category']?.toString() ?? 'Sin categoría')
        .toSet()
        .toList()
      ..sort();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('profesionales')
          .orderBy('nombre')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        final listaFiltrada = docs.where((doc) {
          final data = doc.data();
          final nombre = (data['nombre'] ?? '').toString().toLowerCase();
          final coincideTexto =
              filtroTexto.isEmpty || nombre.contains(filtroTexto.toLowerCase());

          if (!coincideTexto) return false;

          // 🔎 Nuevo filtro: buscar categoría dentro de servicios
          if (filtroCategoria != null && filtroCategoria != 'Todas') {
            final servicios =
                List<Map<String, dynamic>>.from(data['servicios'] ?? []);
            final categoriasServicios = servicios
                .map((s) => s['category']?.toString())
                .where((c) => c != null)
                .toSet();

            return categoriasServicios.contains(filtroCategoria);
          }

          return true;
        }).toList();

        if (listaFiltrada.isEmpty) {
          return const Center(child: Text('No se encontraron profesionales.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: listaFiltrada.length,
          itemBuilder: (context, index) {
            final doc = listaFiltrada[index];
            final profesional = ProfessionalModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            });

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProfessionalCard(
                profesional: profesional,
                categoriasDisponibles: categoriasDisponibles,
                onEdit: () async {
                  final resultado = await showDialog<ProfessionalModel>(
                    context: context,
                    builder: (_) => ProfessionalCrudDialog(
                      professional: profesional,
                      serviciosDisponibles: serviciosDisponibles,
                    ),
                  );
                  if (resultado != null) {
                    onUpdated?.call();
                  }
                },
                onDeleted: onUpdated ?? () {},
              ),
            );
          },
        );
      },
    );
  }
}
