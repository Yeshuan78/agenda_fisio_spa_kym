import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class PlantillasDevButton extends StatelessWidget {
  const PlantillasDevButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.cloud_upload, size: 18),
      label: const Text("Cargar plantillas base"),
      style: ElevatedButton.styleFrom(
        backgroundColor: kBrandPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);

        try {
          await _crearPlantillasBase();
          messenger.showSnackBar(
            const SnackBar(
                content: Text("✅ Plantillas base cargadas correctamente")),
          );
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text("❌ Error al cargar plantillas: $e")),
          );
        }
      },
    );
  }

  Future<void> _crearPlantillasBase() async {
    final firestore = FirebaseFirestore.instance;

    final plantillas = [
      // Cliente - WhatsApp
      {
        "tipoUsuario": "cliente",
        "canal": "whatsapp",
        "estado": "reservado",
        "mensaje":
            "Hola {{nombre}} 👋. Tu cita ha sido reservada para {{servicio}}. Te confirmaremos pronto."
      },
      {
        "tipoUsuario": "cliente",
        "canal": "whatsapp",
        "estado": "confirmado",
        "mensaje":
            "Hola {{nombre}} 👋. Tu cita está confirmada para el {{fecha}} a las {{hora}} con {{profesional}}."
      },
      {
        "tipoUsuario": "cliente",
        "canal": "whatsapp",
        "estado": "cancelado",
        "mensaje":
            "Hola {{nombre}}, lamentamos informarte que tu cita de {{servicio}} ha sido cancelada."
      },
      {
        "tipoUsuario": "cliente",
        "canal": "whatsapp",
        "estado": "en camino",
        "mensaje":
            "Hola {{nombre}}, tu terapeuta {{profesional}} va en camino 🚗. Prepárate para recibir tu sesión de {{servicio}}."
      },
      {
        "tipoUsuario": "cliente",
        "canal": "whatsapp",
        "estado": "llegamos",
        "mensaje":
            "¡Hola {{nombre}}! Hemos llegado a tu domicilio para tu sesión de {{servicio}}."
      },
      {
        "tipoUsuario": "cliente",
        "canal": "whatsapp",
        "estado": "finalizado",
        "mensaje":
            "Gracias {{nombre}} por tu preferencia. Tu sesión de {{servicio}} con {{profesional}} ha finalizado. ¡Esperamos verte pronto!"
      },

      // Profesional - WhatsApp
      {
        "tipoUsuario": "profesional",
        "canal": "whatsapp",
        "estado": "asignado",
        "mensaje":
            "Nueva cita asignada para el {{fecha}} a las {{hora}} con {{cliente}}. Servicio: {{servicio}}."
      },

      // Admin - WhatsApp
      {
        "tipoUsuario": "admin",
        "canal": "whatsapp",
        "estado": "reservado",
        "mensaje":
            "🔔 Se ha agendado una nueva cita. Cliente: {{nombre}}, Servicio: {{servicio}}, Fecha: {{fecha}}, Hora: {{hora}}, Profesional: {{profesional}}."
      },

      // Corporativo - WhatsApp
      {
        "tipoUsuario": "corporativo",
        "canal": "whatsapp",
        "estado": "reservado",
        "mensaje":
            "Hola {{nombre}}, tu cita de masaje ha sido reservada. En breve te confirmamos todos los detalles."
      },
      {
        "tipoUsuario": "corporativo",
        "canal": "whatsapp",
        "estado": "confirmado",
        "mensaje":
            "Hola {{nombre}}, tu cita está confirmada para el {{fecha}} a las {{hora}}. Dirígete al área de {{servicio}}."
      },
      {
        "tipoUsuario": "corporativo",
        "canal": "whatsapp",
        "estado": "cancelado",
        "mensaje":
            "Hola {{nombre}}, tu cita ha sido cancelada por el momento. Por favor consulta con recursos humanos."
      },
      {
        "tipoUsuario": "corporativo",
        "canal": "whatsapp",
        "estado": "tu servicio se realizará en:",
        "mensaje":
            "Hola {{nombre}}, recuerda que tu masaje de {{servicio}} será en {{profesional}} a las {{hora}}. No olvides llegar a tiempo 🙌."
      },
    ];

    for (final plantilla in plantillas) {
      final query = await firestore
          .collection('plantillas_mensajes')
          .where('tipoUsuario', isEqualTo: plantilla['tipoUsuario'])
          .where('canal', isEqualTo: plantilla['canal'])
          .where('estado', isEqualTo: plantilla['estado'])
          .get();

      if (query.docs.isEmpty) {
        await firestore.collection('plantillas_mensajes').add(plantilla);
      }
    }
  }
}
