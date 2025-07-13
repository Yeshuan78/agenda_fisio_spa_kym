import 'dart:typed_data';
import 'package:xml/xml.dart';

class FacturaParserService {
  static Future<Map<String, dynamic>> parseXmlBytes(Uint8List bytes) async {
    final document = XmlDocument.parse(String.fromCharCodes(bytes));

    String? getAttr(XmlElement? node, String attr) {
      return node?.getAttribute(attr) ?? node?.getAttribute(attr.toLowerCase());
    }

    final comprobante =
        document.findAllElements('cfdi:Comprobante').firstOrNull ??
            document.findAllElements('Comprobante').firstOrNull;

    final emisor = document.findAllElements('cfdi:Emisor').firstOrNull ??
        document.findAllElements('Emisor').firstOrNull;

    final receptor = document.findAllElements('cfdi:Receptor').firstOrNull ??
        document.findAllElements('Receptor').firstOrNull;

    final timbre =
        document.findAllElements('tfd:TimbreFiscalDigital').firstOrNull ??
            document.findAllElements('TimbreFiscalDigital').firstOrNull;

    return {
      'serie': getAttr(comprobante, 'Serie'),
      'folio': getAttr(comprobante, 'Folio'),
      'fechaEmision': getAttr(comprobante, 'Fecha'),
      'montoTotal':
          double.tryParse(getAttr(comprobante, 'Total') ?? '0') ?? 0.0,
      'usoCFDI': getAttr(comprobante, 'UsoCFDI'),
      'metodoPago': getAttr(comprobante, 'MetodoPago'),
      'formaPago': getAttr(comprobante, 'FormaPago'),
      'condicionesDePago': getAttr(comprobante, 'CondicionesDePago'), // ✅ NUEVO
      'emisor': getAttr(emisor, 'Nombre'),
      'rfcEmisor': getAttr(emisor, 'Rfc'),
      'rfcReceptor': getAttr(receptor, 'Rfc'),
      'nombreReceptor':
          getAttr(receptor, 'Nombre') ?? getAttr(receptor, 'nombre'),
      'uuid': getAttr(timbre, 'UUID'),
    };
  }
}

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
