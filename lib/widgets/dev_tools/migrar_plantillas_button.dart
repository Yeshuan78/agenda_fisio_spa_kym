import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class MigrarPlantillasButton extends StatelessWidget {
  const MigrarPlantillasButton({super.key});

  Future<void> _migrar(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore.collection('plantillas_mensajes').get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final tipoUsuario = data['tipoUsuario'];
        final canal = data['canal'];
        final estado = data['estado'];
        final mensaje = data['mensaje'];

        final destino = firestore
            .collection('notificaciones_config')
            .doc('templates')
            .collection('${canal}_$tipoUsuario')
            .doc(estado);

        await destino.set({
          'tipoUsuario': tipoUsuario,
          'canal': canal,
          'estado': estado,
          'mensaje': mensaje,
          'activo': true,
        });
      }

      // Plantillas EMAIL - PROFESIONAL
      final emailProfesional = {
        'asignado':
            'Tienes una nueva cita asignada para el {{fecha}} a las {{hora}} con {{cliente}}. Servicio: {{servicio}}.',
        'confirmado':
            'Tu cita para el {{fecha}} a las {{hora}} con {{cliente}} ha sido confirmada. Servicio: {{servicio}}.',
        'cancelado':
            'La cita del {{fecha}} con {{cliente}} ha sido cancelada. Ya fue retirada de tu calendario.',
        'recordatorio':
            'Hola {{profesional}}, recuerda que hoy tienes una cita a las {{hora}} con {{cliente}} para {{servicio}}.',
        'cita_realizada':
            'Gracias por atender la cita con {{cliente}} el {{fecha}}. Puedes marcarla como completada en tu agenda.',
      };

      for (final estado in emailProfesional.keys) {
        await firestore
            .collection('notificaciones_config')
            .doc('templates')
            .collection('email_profesional')
            .doc(estado)
            .set({
          'tipoUsuario': 'profesional',
          'canal': 'email',
          'estado': estado,
          'mensaje': emailProfesional[estado],
          'activo': true,
        });
      }

      // Plantillas EMAIL - CLIENTE
      final emailCliente = {
        'reservado':
            'Hola {{nombre}}, tu cita ha sido reservada para el servicio de {{servicio}}. Te confirmaremos los detalles pronto.',
        'confirmado':
            'Hola {{nombre}}, tu cita ha sido confirmada para el {{fecha}} a las {{hora}} con {{profesional}}. ¡Gracias por elegirnos!',
        'cancelado':
            'Hola {{nombre}}, lamentamos informarte que tu cita de {{servicio}} ha sido cancelada. Si necesitas reprogramar, contáctanos.',
        'finalizado':
            'Hola {{nombre}}, gracias por tu confianza. Tu sesión de {{servicio}} con {{profesional}} ha finalizado exitosamente. Esperamos verte pronto.'
      };

      for (final estado in emailCliente.keys) {
        await firestore
            .collection('notificaciones_config')
            .doc('templates')
            .collection('email_cliente')
            .doc(estado)
            .set({
          'tipoUsuario': 'cliente',
          'canal': 'email',
          'estado': estado,
          'mensaje': emailCliente[estado],
          'activo': true,
        });
      }

      // Plantillas EMAIL - ADMIN
      final emailAdmin = {
        'reservado':
            'Se ha reservado una nueva cita: {{cliente}}, Servicio: {{servicio}}, Fecha: {{fecha}}, Hora: {{hora}}, Profesional: {{profesional}}.',
        'asignado':
            'Cita asignada a profesional: {{profesional}} atenderá a {{cliente}} el {{fecha}} a las {{hora}} para {{servicio}}.',
        'cancelado':
            'Se ha cancelado una cita: Cliente: {{cliente}}, Fecha: {{fecha}}, Servicio: {{servicio}}, Profesional: {{profesional}}.'
      };

      for (final estado in emailAdmin.keys) {
        await firestore
            .collection('notificaciones_config')
            .doc('templates')
            .collection('email_admin')
            .doc(estado)
            .set({
          'tipoUsuario': 'admin',
          'canal': 'email',
          'estado': estado,
          'mensaje': emailAdmin[estado],
          'activo': true,
        });
      }

      // Plantillas EMAIL - CORPORATIVO
      final emailCorporativo = {
        'reservado':
            'Estimado/a {{nombre}}, tu cita de masaje ha sido reservada. Te confirmaremos el horario y espacio asignado pronto.',
        'confirmado':
            'Tu masaje está confirmado para el {{fecha}} a las {{hora}}. Acude al área designada: {{servicio}}.',
        'cancelado':
            'Tu cita programada ha sido cancelada. Para más detalles, comunícate con tu contacto interno.',
        'recordatorio':
            'Recordatorio: tu cita de masaje es hoy a las {{hora}} en el área de {{servicio}}. Te esperamos.'
      };

      for (final estado in emailCorporativo.keys) {
        await firestore
            .collection('notificaciones_config')
            .doc('templates')
            .collection('email_corporativo')
            .doc(estado)
            .set({
          'tipoUsuario': 'corporativo',
          'canal': 'email',
          'estado': estado,
          'mensaje': emailCorporativo[estado],
          'activo': true,
        });
      }

      messenger.showSnackBar(
        const SnackBar(
            content: Text("✅ Plantillas migradas y ampliadas correctamente")),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("❌ Error al migrar plantillas: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.copy),
      label: const Text("Migrar a notificaciones_config"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onPressed: () => _migrar(context),
    );
  }
}
