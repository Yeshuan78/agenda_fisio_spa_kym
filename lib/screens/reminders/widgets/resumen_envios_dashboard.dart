import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/screens/settings/automatic_reminder_config_screen.dart';

class ResumenEnviosDashboard extends StatelessWidget {
  const ResumenEnviosDashboard({super.key});

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

        int whatsappOk = 0;
        int whatsappPendiente = 0;
        int correoOk = 0;
        int correoPendiente = 0;

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['whatsappSent'] == true) {
            whatsappOk++;
          } else {
            whatsappPendiente++;
          }

          if (data['emailSent'] == true) {
            correoOk++;
          } else {
            correoPendiente++;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildCard("WhatsApp enviados", whatsappOk, Icons.check_circle,
                  Colors.green),
              _buildCard("WhatsApp pendientes", whatsappPendiente,
                  Icons.schedule, Colors.grey),
              _buildCard("Correos enviados", correoOk, Icons.email_outlined,
                  Colors.green),
              _buildCard("Correos pendientes", correoPendiente, Icons.schedule,
                  Colors.grey),
              _buildCardConfiguracion(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(
      String label, int cantidad, IconData icon, Color iconColor) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorderColor.withValues(alpha: 0.04)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.004),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: iconColor),
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

  Widget _buildCardConfiguracion(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AutomaticReminderConfigScreen()),
        );
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: kBorderColor.withAlpha((255 * 0.4).round())),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.04).round()),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.settings, size: 28, color: kBrandPurple),
            SizedBox(height: 8),
            Text(
              'Configurar\nEnvío Automático',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
