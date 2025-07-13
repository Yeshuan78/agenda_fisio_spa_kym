import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/services/correo_service.dart';
import 'package:agenda_fisio_spa_kym/services/whatsapp_integration.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HistorialEnviosSidebar extends StatelessWidget {
  const HistorialEnviosSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final ahora = DateTime.now();
    final sieteDiasAntes = ahora.subtract(const Duration(days: 7));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorderColor.withAlpha(50)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text(
            '📜 Historial de envíos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: kBrandPurple,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notificaciones_log')
                  .where('fechaEnvio',
                      isGreaterThanOrEqualTo: sieteDiasAntes.toIso8601String())
                  .orderBy('fechaEnvio', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final logs = snapshot.data!.docs;
                if (logs.isEmpty) {
                  return const Center(
                      child: Text(
                          'No hay registros de envíos en los últimos 7 días.'));
                }

                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final data = logs[index].data() as Map<String, dynamic>;
                    final cliente = data['clienteNombre'] ?? 'Cliente';
                    final canal = data['canal'] ?? 'desconocido';
                    final estado = data['estado'] ?? '';
                    final mensaje = data['mensaje'] ?? '';
                    final correo = data['correo'] ?? '';
                    final telefono = data['telefono'] ?? '';
                    final fecha = DateTime.tryParse(data['fechaEnvio'] ?? '') ??
                        DateTime.now();

                    final horaStr =
                        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

                    final canalColor = canal == 'whatsapp'
                        ? Colors.green
                        : (canal == 'email' ? Colors.deepPurple : Colors.grey);

                    return Tooltip(
                      message: mensaje,
                      padding: const EdgeInsets.all(8),
                      textStyle: const TextStyle(color: Colors.white),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: canalColor.withAlpha(60)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            canal == 'whatsapp'
                                ? FaIcon(FontAwesomeIcons.whatsapp,
                                    size: 18, color: canalColor)
                                : Icon(Icons.email_outlined,
                                    size: 18, color: canalColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cliente,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    '$estado • $horaStr',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 18),
                              tooltip: 'Reenviar mensaje',
                              onPressed: () async {
                                final confirmar = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('¿Reenviar mensaje?'),
                                    content: Text(
                                      '¿Quieres reenviar este mensaje a $cliente por $canal?',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancelar'),
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: canalColor,
                                        ),
                                        child: const Text('Reenviar'),
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmar != true) return;

                                try {
                                  if (canal == 'email') {
                                    if (correo.isEmpty) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  '❌ No se puede reenviar. Falta el correo.')));
                                      return;
                                    }

                                    final enviado =
                                        await CorreoService.enviarCorreo(
                                      destinatario: correo,
                                      asunto:
                                          "Recordatorio de cita - Fisio Spa KYM",
                                      contenidoHtml: mensaje,
                                    );

                                    if (enviado && context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  '📧 Correo reenviado correctamente')));
                                    }
                                  } else if (canal == 'whatsapp') {
                                    if (telefono.isEmpty) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  '❌ No se puede reenviar. Falta el número.')));
                                      return;
                                    }

                                    await WhatsAppIntegration
                                        .enviarMensajeTexto(
                                      telefono: telefono,
                                      mensaje: mensaje,
                                    );

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "📲 WhatsApp reenviado correctamente")));
                                    }
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "❌ Error al reenviar mensaje: $e"),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
