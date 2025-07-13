import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/services/whatsapp_integration.dart';
import 'package:agenda_fisio_spa_kym/services/correo_service.dart';
import 'package:agenda_fisio_spa_kym/services/notificaciones_logger.dart';
import 'package:agenda_fisio_spa_kym/utils/estado_normalizer.dart';

class ReminderCard extends StatelessWidget {
  final String nombreCliente;
  final String estado;
  final String fecha;
  final String hora;
  final bool whatsappEnviado;
  final bool correoEnviado;
  final String telefonoCliente;
  final String emailCliente;
  final String tipoUsuario;
  final String nombreServicio;
  final String nombreProfesional;
  final void Function()? onMensajeReenviado;

  const ReminderCard({
    super.key,
    required this.nombreCliente,
    required this.estado,
    required this.fecha,
    required this.hora,
    required this.whatsappEnviado,
    required this.correoEnviado,
    required this.telefonoCliente,
    required this.emailCliente,
    required this.tipoUsuario,
    required this.nombreServicio,
    required this.nombreProfesional,
    this.onMensajeReenviado,
  });

  Future<void> _reenviarCorreo(BuildContext context) async {
    final estadoNormalizado = normalizarEstadoPlantilla(estado);

    try {
      final docSnap = await FirebaseFirestore.instance
          .collection('notificaciones_config')
          .doc('templates')
          .collection('email_${tipoUsuario.toLowerCase()}')
          .doc(estadoNormalizado)
          .get();

      if (!docSnap.exists) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "❌ No se encontró plantilla:\nemail_${tipoUsuario.toLowerCase()}/$estadoNormalizado")),
        );
        return;
      }

      final rawMensaje = docSnap['mensaje'] ?? '';
      final mensaje = CorreoService.renderTemplate(rawMensaje, {
        'nombre': nombreCliente,
        'fecha': fecha,
        'hora': hora,
        'servicio': nombreServicio,
        'profesional': nombreProfesional,
      });

      final nowIso = DateTime.now().toIso8601String();
      print("📧 Buscando cita con:");
      print(" - Correo: $emailCliente");
      print(" - Estado: $estado");
      print(" - Fecha mínima: $nowIso");

      final query = await FirebaseFirestore.instance
          .collection('bookings')
          .where('clientEmail', isEqualTo: emailCliente)
          .where('status', isEqualTo: estado)
          .where('date', isGreaterThanOrEqualTo: nowIso)
          .limit(1)
          .get();

      print("📄 Citas encontradas: ${query.docs.length}");
      if (query.docs.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("❌ No se encontró la cita en Firestore")),
        );
        return;
      }

      final ref = query.docs.first.reference;

      final enviado = await CorreoService.enviarCorreo(
        destinatario: emailCliente,
        asunto: "Detalles de tu cita - Fisio Spa KYM",
        contenidoHtml: mensaje,
      );

      if (enviado) {
        await ref.update({'emailSent': true});
        await NotificacionesLogger.logEnvioMensaje(
          bookingId: ref.id,
          canal: 'email',
          clienteNombre: nombreCliente,
          estado: estadoNormalizado,
          mensaje: mensaje,
          tipoUsuario: tipoUsuario,
          correo: emailCliente,
        );

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("📧 Correo reenviado correctamente ✅")),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Error al enviar el correo")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  Future<void> _reenviarWhatsApp(BuildContext context) async {
    final estadoNormalizado = normalizarEstadoPlantilla(estado);

    try {
      final docSnap = await FirebaseFirestore.instance
          .collection('notificaciones_config')
          .doc('templates')
          .collection('whatsapp_${tipoUsuario.toLowerCase()}')
          .doc(estadoNormalizado)
          .get();

      if (!docSnap.exists) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "❌ No se encontró plantilla:\nwhatsapp_${tipoUsuario.toLowerCase()}/$estadoNormalizado")),
        );
        return;
      }

      final rawMensaje = docSnap['mensaje'] ?? '';
      final mensaje = rawMensaje
          .replaceAll('{{nombre}}', nombreCliente)
          .replaceAll('{{fecha}}', fecha)
          .replaceAll('{{hora}}', hora)
          .replaceAll('{{servicio}}', nombreServicio)
          .replaceAll('{{profesional}}', nombreProfesional);
      await WhatsAppIntegration.enviarMensajeTexto(
        telefono: telefonoCliente,
        mensaje: mensaje,
      );

      final query = await FirebaseFirestore.instance
          .collection('bookings')
          .where('clientPhone', isEqualTo: telefonoCliente)
          .where('status', isEqualTo: estado)
          .where('date',
              isGreaterThanOrEqualTo: DateTime.now().toIso8601String())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final ref = query.docs.first.reference;
        await ref.update({'whatsappSent': true});
        await NotificacionesLogger.logEnvioMensaje(
          bookingId: ref.id,
          canal: 'whatsapp',
          clienteNombre: nombreCliente,
          estado: estadoNormalizado,
          mensaje: mensaje,
          tipoUsuario: tipoUsuario,
          telefono: telefonoCliente,
        );
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("📲 WhatsApp reenviado correctamente ✅")),
      );

      if (onMensajeReenviado != null) {
        onMensajeReenviado!();
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al reenviar WhatsApp: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Text(
          nombreCliente,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '$estado | $fecha - $hora',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.email, size: 18),
              tooltip: 'Reenviar por correo',
              color: correoEnviado ? Colors.green : Colors.grey,
              onPressed: () => _reenviarCorreo(context),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
              tooltip: 'Reenviar WhatsApp',
              color: whatsappEnviado ? Colors.green : Colors.grey,
              onPressed: () => _reenviarWhatsApp(context),
            ),
          ],
        ),
      ),
    );
  }
}
