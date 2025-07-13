import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EstadoCitasDashboard extends StatelessWidget {
  const EstadoCitasDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final desde = DateTime.now().subtract(const Duration(days: 7));
    final desdeIso = DateFormat("yyyy-MM-dd").format(desde);

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

        int canceladas = 0;
        int whatsapp7dias = 0;
        int correo7dias = 0;

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final fechaStr = data['date'] ?? '';

          DateTime? fecha;
          try {
            fecha = DateTime.parse(fechaStr);
          } catch (_) {
            fecha = null;
          }

          if (fecha == null || fecha.isBefore(desde)) continue;

          final estado = (data['status'] ?? '').toString().toLowerCase();

          if (estado == 'cancelado') canceladas++;
          if (data['whatsappSent'] == true) whatsapp7dias++;
          if (data['emailSent'] == true) correo7dias++;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _buildItem(
                  "Canceladas (7 días)", canceladas, Icons.cancel, Colors.red),
              _buildItem("WhatsApp enviados", whatsapp7dias, Icons.message,
                  Colors.green),
              _buildItem(
                  "Correos enviados", correo7dias, Icons.email, Colors.indigo),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(String label, int cantidad, IconData icon, Color color) {
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
