import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class CitasConErroresDashboard extends StatelessWidget {
  const CitasConErroresDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;
        int sinTelefono = 0;
        int sinCorreo = 0;
        int sinFecha = 0;

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;

          final telefono = data['clientPhone']?.toString().trim() ?? '';
          final correo = data['clientEmail']?.toString().trim() ?? '';
          final fecha = data['date']?.toString().trim() ?? '';

          if (telefono.isEmpty) sinTelefono++;
          if (correo.isEmpty) sinCorreo++;

          try {
            if (fecha.isEmpty ||
                DateTime.parse(fecha).isBefore(DateTime(2020))) {
              sinFecha++;
            }
          } catch (_) {
            sinFecha++;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildErrorCard("Sin teléfono", sinTelefono, Icons.phone_disabled,
                  Colors.red),
              _buildErrorCard("Sin correo", sinCorreo, Icons.mark_email_unread,
                  Colors.orange),
              _buildErrorCard(
                  "Fecha inválida", sinFecha, Icons.event_busy, Colors.grey),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(
      String label, int cantidad, IconData icon, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorderColor.withAlpha((255 * 0.4).round())),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.04).round()),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            '$cantidad',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kBrandPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
