import 'dart:io';
import 'package:xml/xml.dart';

Future<Map<String, dynamic>> parseFacturaXML(File xmlFile) async {
  final xmlString = await xmlFile.readAsString();
  final document = XmlDocument.parse(xmlString);

  final comprobante = document.getElement('cfdi:Comprobante');
  final emisor =
      document.getElement('cfdi:Comprobante')?.getElement('cfdi:Emisor');
  final receptor =
      document.getElement('cfdi:Comprobante')?.getElement('cfdi:Receptor');

  return {
    'folio': comprobante?.getAttribute('Folio') ?? '',
    'montoTotal':
        double.tryParse(comprobante?.getAttribute('Total') ?? '0') ?? 0.0,
    'fechaEmision': comprobante?.getAttribute('Fecha') ?? '',
    'emisorRfc': emisor?.getAttribute('Rfc') ?? '',
    'receptorRfc': receptor?.getAttribute('Rfc') ?? '',
  };
}
