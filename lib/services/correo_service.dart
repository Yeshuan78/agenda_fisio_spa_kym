import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:agenda_fisio_spa_kym/app/config/config.dart';

class CorreoService {
  static final String _usuario = AppConfig.smtpUsuario;
  static final String _contrasena = AppConfig.smtpContrasena;

  static final SmtpServer _smtpServer = SmtpServer(
    AppConfig.smtpHost,
    port: AppConfig.smtpPort,
    ssl: true,
    username: _usuario,
    password: _contrasena,
  );

  /// Envía un correo con los datos proporcionados
  static Future<bool> enviarCorreo({
    required String destinatario,
    required String asunto,
    required String contenidoHtml,
  }) async {
    final mensaje = Message()
      ..from = Address(_usuario, AppConfig.nombreRemitente)
      ..recipients.add(destinatario)
      ..subject = asunto
      ..html = contenidoHtml;

    try {
      final sendReport = await send(mensaje, _smtpServer);
      print('📧 Correo enviado: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('❌ Error al enviar correo: $e');
      return false;
    }
  }

  /// Reemplaza variables tipo {{nombre}} con datos reales
  static String renderTemplate(String plantilla, Map<String, String> data) {
    String resultado = plantilla;
    data.forEach((clave, valor) {
      resultado = resultado.replaceAll('{{$clave}}', valor);
    });
    return resultado;
  }
}
