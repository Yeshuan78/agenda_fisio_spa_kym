// lib/widgets/cita_card.dart

import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart"; // <-- para FaIcon
import "../theme/theme.dart";

class CitaCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onSendWhatsApp;
  final VoidCallback onSendEmail;

  const CitaCard({
    Key? key,
    required this.data,
    required this.onEdit,
    required this.onSendWhatsApp,
    required this.onSendEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clientName = data["clientName"] ?? "Cliente sin nombre";
    final profesionalName = data["profesionalName"] ?? "General";
    final serviceName = data["serviceName"] ?? "Sin servicio";
    final date = data["date"] ?? "";
    final status = data["status"] ?? "Desconocido";
    final reminderSent = data["reminderSent"] ?? false;
    final lastReminderMethod = data["lastReminderMethod"] ?? "N/A";

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: kBrandPurple.withValues(alpha: 0.04)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Profesional: $profesionalName\n"
                  "Servicio: $serviceName\n"
                  "Fecha: $date\n"
                  "Estado: $status",
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                reminderSent
                    ? Text(
                        "Recordatorio Enviado: $lastReminderMethod",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : const Text(
                        "Sin recordatorio enviado",
                        style: TextStyle(fontSize: 11, color: Colors.red),
                      ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrandPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                        child: const Text(
                          "Editar Estado",
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.whatsapp,
                          color: Colors.green),
                      tooltip: "Enviar WhatsApp",
                      onPressed: onSendWhatsApp,
                    ),
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.envelope,
                          color: Colors.blueAccent),
                      tooltip: "Enviar Email",
                      onPressed: onSendEmail,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
