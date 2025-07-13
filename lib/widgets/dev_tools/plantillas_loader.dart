// File: lib/dev_tools/plantillas_loader.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PlantillasLoader {
  static Future<void> crearTodasLasPlantillas() async {
    final firestore = FirebaseFirestore.instance;

    final List<Map<String, dynamic>> plantillas = [
      // CLIENTE - WhatsApp
      {
        'canal': 'whatsapp',
        'tipoUsuario': 'cliente',
        'estado': 'reservado',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'reservado\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },
      {
        'canal': 'whatsapp',
        'tipoUsuario': 'cliente',
        'estado': 'confirmado',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'confirmado\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },
      {
        'canal': 'whatsapp',
        'tipoUsuario': 'cliente',
        'estado': 'cancelado',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'cancelado\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },
      {
        'canal': 'whatsapp',
        'tipoUsuario': 'cliente',
        'estado': 'en camino',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'en camino\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },
      {
        'canal': 'whatsapp',
        'tipoUsuario': 'cliente',
        'estado': 'llegamos',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'llegamos\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },
      {
        'canal': 'whatsapp',
        'tipoUsuario': 'cliente',
        'estado': 'finalizado',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'finalizado\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },

      // PROFESIONAL - WhatsApp
      {
        'canal': 'whatsapp',
        'tipoUsuario': 'profesional',
        'estado': 'asignado',
        'mensaje':
            'Hola {{nombre}}, tienes una cita \'asignado\' asignada para el {{fecha}} a las {{hora}} con el cliente {{cliente}}.',
        'activo': true
      },
      {
        'canal': 'whatsapp',
        'tipoUsuario': 'profesional',
        'estado': 'recordatorio',
        'mensaje':
            'Hola {{nombre}}, tienes una cita \'recordatorio\' asignada para el {{fecha}} a las {{hora}} con el cliente {{cliente}}.',
        'activo': true
      },

      // CLIENTE - Correo
      {
        'canal': 'correo',
        'tipoUsuario': 'cliente',
        'estado': 'reservado',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'reservado\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'cliente',
        'estado': 'confirmado',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'confirmado\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'cliente',
        'estado': 'cancelado',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'cancelado\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'cliente',
        'estado': 'en camino',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'en camino\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'cliente',
        'estado': 'llegamos',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'llegamos\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'cliente',
        'estado': 'finalizado',
        'mensaje':
            'Hola {{nombre}}, tu cita está en estado \'finalizado\' programada para el {{fecha}} a las {{hora}} con {{profesional}}.',
        'activo': true
      },

      // PROFESIONAL - Correo
      {
        'canal': 'correo',
        'tipoUsuario': 'profesional',
        'estado': 'asignado',
        'mensaje':
            'Hola {{nombre}}, tienes una cita \'asignado\' asignada para el {{fecha}} a las {{hora}} con el cliente {{cliente}}.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'profesional',
        'estado': 'recordatorio',
        'mensaje':
            'Hola {{nombre}}, tienes una cita \'recordatorio\' asignada para el {{fecha}} a las {{hora}} con el cliente {{cliente}}.',
        'activo': true
      },

      // CORPORATIVO - Correo
      {
        'canal': 'correo',
        'tipoUsuario': 'corporativo',
        'estado': 'reservado',
        'mensaje':
            'Hola {{nombre}}, tu cita ha sido reservada por el equipo de Fisio Spa KYM.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'corporativo',
        'estado': 'confirmado',
        'mensaje':
            'Hola {{nombre}}, tu cita ha sido confirmada por el equipo de Fisio Spa KYM.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'corporativo',
        'estado': 'cancelado',
        'mensaje':
            'Hola {{nombre}}, tu cita ha sido cancelada por el equipo de Fisio Spa KYM.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'corporativo',
        'estado': 'se realizará',
        'mensaje':
            'Hola {{nombre}}, tu servicio se realizará en la zona asignada por tu empresa el {{fecha}} a las {{hora}}.',
        'activo': true
      },

      // ADMIN - Correo
      {
        'canal': 'correo',
        'tipoUsuario': 'admin',
        'estado': 'reservado',
        'mensaje':
            'Se ha creado una cita para el cliente {{nombre}} con el profesional {{profesional}} el día {{fecha}} a las {{hora}} para el servicio {{servicio}}. Estado: reservado.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'admin',
        'estado': 'confirmado',
        'mensaje':
            'Se ha creado una cita para el cliente {{nombre}} con el profesional {{profesional}} el día {{fecha}} a las {{hora}} para el servicio {{servicio}}. Estado: confirmado.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'admin',
        'estado': 'cancelado',
        'mensaje':
            'Se ha creado una cita para el cliente {{nombre}} con el profesional {{profesional}} el día {{fecha}} a las {{hora}} para el servicio {{servicio}}. Estado: cancelado.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'admin',
        'estado': 'en camino',
        'mensaje':
            'Se ha creado una cita para el cliente {{nombre}} con el profesional {{profesional}} el día {{fecha}} a las {{hora}} para el servicio {{servicio}}. Estado: en camino.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'admin',
        'estado': 'llegamos',
        'mensaje':
            'Se ha creado una cita para el cliente {{nombre}} con el profesional {{profesional}} el día {{fecha}} a las {{hora}} para el servicio {{servicio}}. Estado: llegamos.',
        'activo': true
      },
      {
        'canal': 'correo',
        'tipoUsuario': 'admin',
        'estado': 'finalizado',
        'mensaje':
            'Se ha creado una cita para el cliente {{nombre}} con el profesional {{profesional}} el día {{fecha}} a las {{hora}} para el servicio {{servicio}}. Estado: finalizado.',
        'activo': true
      },
    ];

    for (final plantilla in plantillas) {
      final canal = plantilla['canal'];
      final tipo = plantilla['tipoUsuario'];
      final estado = plantilla['estado'];

      final docRef = firestore
          .collection('notificaciones_config')
          .doc('templates')
          .collection('${canal}_$tipo')
          .doc(estado);

      await docRef.set(plantilla);
    }

    print("✅ Todas las plantillas fueron creadas correctamente.");
  }
}
