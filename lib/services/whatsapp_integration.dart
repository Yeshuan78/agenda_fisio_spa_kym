import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class WhatsAppIntegration {
  /// 🔹 Método directo (wa.me) para acciones rápidas
  static Future<void> enviarMensajeWhatsApp({
    required String telefono,
    required String mensaje,
  }) async {
    final url = Uri.parse(
      'https://wa.me/52$telefono?text=${Uri.encodeComponent(mensaje)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir WhatsApp';
    }
  }

  /// 🔸 Método para enviar mensaje vía API oficial (NO se usa en este proyecto aún)
  Future<void> sendTextMessage({
    required String toPhone,
    required String message,
  }) async {
    const String accessToken = 'TU_TOKEN_DE_ACCESO';
    const String phoneNumberId = 'TU_PHONE_NUMBER_ID';

    final url =
        Uri.parse('https://graph.facebook.com/v18.0/$phoneNumberId/messages');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "messaging_product": "whatsapp",
        "to": toPhone,
        "type": "text",
        "text": {"body": message},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar mensaje: ${response.body}');
    }
  }

  /// 🧩 NUEVO: Mensajes automáticos por estado con variables dinámicas
  static Future<void> enviarMensajePorEstado({
    required String telefono,
    required String estado,
    required String nombreCliente,
    String? fecha,
    String? hora,
    String? servicio,
    String? profesional,
  }) async {
    final mensajes = {
      'reservado':
          'Hola $nombreCliente 👋. Tu cita ha sido reservada para $servicio. Te confirmaremos pronto.',
      'confirmado':
          'Hola $nombreCliente 👋. Tu cita está confirmada para el $fecha a las $hora con $profesional.',
      'cancelado':
          'Hola $nombreCliente, lamentamos informarte que tu cita de $servicio ha sido cancelada.',
      'en camino':
          'Hola $nombreCliente, tu terapeuta $profesional va en camino 🚗. Prepárate para recibir tu sesión de $servicio.',
      'llegamos':
          '¡Hola $nombreCliente! Hemos llegado a tu domicilio para tu sesión de $servicio.',
      'finalizado':
          'Gracias $nombreCliente por tu preferencia. Tu sesión de $servicio con $profesional ha finalizado. ¡Esperamos verte pronto!',
    };

    final mensaje = mensajes[estado.toLowerCase()] ??
        'Hola $nombreCliente, tenemos novedades sobre tu cita.';

    await enviarMensajeWhatsApp(
      telefono: telefono,
      mensaje: mensaje,
    );
  }

  /// ✅ NUEVO: Reenvío desde historial (mensaje personalizado ya armado)
  static Future<void> enviarMensajeTexto({
    required String telefono,
    required String mensaje,
  }) async {
    await enviarMensajeWhatsApp(
      telefono: telefono,
      mensaje: mensaje,
    );
  }
}
