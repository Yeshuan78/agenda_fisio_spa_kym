// lib/dev_tools/regenerar_plantillas_base_button.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class RegenerarPlantillasBaseButton extends StatelessWidget {
  const RegenerarPlantillasBaseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.replay_circle_filled_outlined),
      label: const Text('Regenerar todas las plantillas base'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () => _regenerarTodas(context),
    );
  }

  Future<void> _regenerarTodas(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    final canales = ['whatsapp', 'email'];
    final tipos = ['cliente', 'profesional', 'admin', 'corporativo'];

    final estadosPorTipo = {
      'cliente': [
        'reservado',
        'confirmado',
        'cancelado',
        'en camino',
        'llegamos',
        'finalizado'
      ],
      'profesional': [
        'asignado',
        'confirmado',
        'cancelado',
        'recordatorio',
        'cita_realizada'
      ],
      'admin': ['reservado', 'cancelado', 'asignado'],
      'corporativo': ['reservado', 'confirmado', 'cancelado', 'recordatorio'],
    };

    const ejemplo = {
      'nombre': 'Andrea',
      'fecha': '20 de abril',
      'hora': '13:00',
      'servicio': 'Masaje relajante',
      'profesional': 'Julia González',
    };

    int total = 0;

    for (final canal in canales) {
      for (final tipo in tipos) {
        final estados = estadosPorTipo[tipo] ?? [];
        final colRef = firestore
            .collection('notificaciones_config')
            .doc('templates')
            .collection('${canal}_$tipo');

        for (final estado in estados) {
          final texto = _generarMensajeEjemplo(estado, canal, tipo);
          await colRef.doc(estado).set({
            'mensaje': texto,
            'estado': estado,
            'tipoUsuario': tipo,
            'canal': canal,
            'activo': true,
          }, SetOptions(merge: true));
          total++;
        }
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $total plantillas regeneradas correctamente'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _generarMensajeEjemplo(
      String estado, String canal, String tipoUsuario) {
    final saludo = canal == 'email' ? 'Hola {{nombre}},' : '📢 *{{nombre}}*';
    final cuerpo = switch (estado) {
      'reservado' =>
        'Tu cita ha sido reservada para el día {{fecha}} a las {{hora}}.',
      'confirmado' =>
        'Confirmamos tu cita para {{fecha}} a las {{hora}} con {{profesional}}.',
      'en camino' =>
        '¡Ya vamos en camino! Te esperamos para tu servicio de {{servicio}}.',
      'llegamos' =>
        'Ya estamos en tu domicilio para iniciar la sesión. ¡Gracias!',
      'finalizado' =>
        'Tu servicio ha finalizado. ¡Gracias por confiar en nosotros!',
      'cancelado' =>
        'Tu cita ha sido cancelada. Si fue un error, por favor contáctanos.',
      'asignado' =>
        'Se te ha asignado una nueva cita para {{fecha}} a las {{hora}}.',
      'recordatorio' =>
        'Recordatorio de cita: {{fecha}} a las {{hora}} con {{nombre}}.',
      'cita_realizada' =>
        'Gracias por atender la cita. Marca como completada si ya terminó.',
      _ => 'Este es un mensaje automático del sistema para el estado "$estado".'
    };

    return '$saludo\n\n$cuerpo\n\nFisio Spa KYM';
  }
}
