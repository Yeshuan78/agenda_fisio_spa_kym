// [Sección 1.1] professional_logs_screen.dart – Historial de cambios tipo timeline CRM

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class ProfessionalLogsScreen extends StatelessWidget {
  final String idProfesional;

  const ProfessionalLogsScreen({
    super.key,
    required this.idProfesional,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 700,
        height: 600,
        child: Column(
          children: [
            Container(
              color: kBrandPurple.withValues(alpha: 0.005),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.history, color: kBrandPurple),
                  const SizedBox(width: 8),
                  const Text(
                    'Historial de cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('profesionales_logs')
                    .where('idProfesional', isEqualTo: idProfesional)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Sin historial registrado.'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final fecha = (data['timestamp'] as Timestamp?)?.toDate();
                      final accion = data['accion'] ?? 'acción';
                      final modificadoPor =
                          (data['modificadoPor']?['email']) ?? 'desconocido';
                      final datos =
                          data['datos'] as Map<String, dynamic>? ?? {};

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: kBorderColor),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  accion == 'creado'
                                      ? Icons.add_circle
                                      : Icons.edit,
                                  color: kBrandPurple,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  accion.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (fecha != null)
                                  Text(
                                    DateFormat('d MMM yyyy, HH:mm', 'es_MX')
                                        .format(fecha),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Modificado por: $modificadoPor',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: datos.entries.map((entry) {
                                final valor = entry.value;
                                return Chip(
                                  label: Text(
                                    '${entry.key}: ${valor is List ? valor.join(', ') : valor}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor:
                                      kBrandPurple.withValues(alpha: 0.008),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
