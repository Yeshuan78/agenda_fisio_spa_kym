import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class OrdenCompraParser {
  /// Extrae un número de orden de compra desde un PDF digital usando read_pdf_text.
  static Future<String?> extraerOrdenDesdePDF(Uint8List pdfBytes) async {
    try {
      // Guardar el PDF como archivo temporal
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_oc.pdf');
      await tempFile.writeAsBytes(pdfBytes);

      // Extraer texto
      final texto = await ReadPdfText.getPDFtext(tempFile.path);

      // Buscar patrones de orden de compra
      final patrones = [
        RegExp(r'ORDEN DE COMPRA[:\s\-]*([A-Z0-9\-]+)', caseSensitive: false),
        RegExp(r'ORDEN COMPRA[:\s\-]*([A-Z0-9\-]+)', caseSensitive: false),
        RegExp(r'OC[:\s\-]*([A-Z0-9\-]+)', caseSensitive: false),
      ];

      for (final regex in patrones) {
        final match = regex.firstMatch(texto);
        if (match != null && match.groupCount >= 1) {
          return match.group(1);
        }
      }

      return null;
    } catch (e) {
      print('[OrdenCompraParser] Error al procesar PDF: $e');
      return null;
    }
  }
}
