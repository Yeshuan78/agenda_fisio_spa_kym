import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:agenda_fisio_spa_kym/utils/factura_parser_service.dart'; // 🔄 nuevo parser
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class ArchivosFactura {
  final Uint8List pdfOC;
  final Uint8List xmlFactura;
  final Uint8List pdfFactura;
  final String ordenCompra;
  final Map<String, dynamic> datosXml;

  ArchivosFactura({
    required this.pdfOC,
    required this.xmlFactura,
    required this.pdfFactura,
    required this.ordenCompra,
    required this.datosXml,
  });
}

class FacturaUploaderDialog {
  static void show(BuildContext context,
      {required Function(ArchivosFactura) onCompleted}) {
    Uint8List? pdfOCData;
    Uint8List? xmlData;
    Uint8List? pdfFacturaData;

    String ordenCompra = '';
    Map<String, dynamic> datosXml = {};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          bool validado = pdfOCData != null &&
              xmlData != null &&
              pdfFacturaData != null &&
              ordenCompra.isNotEmpty;

          return AlertDialog(
            title: const Text('Subir factura corporativa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                      withData: true,
                    );
                    if (result != null && result.files.single.bytes != null) {
                      pdfOCData = result.files.single.bytes!;
                      final fileName =
                          result.files.single.name.split('.').first;
                      ordenCompra = fileName.replaceAll(RegExp(r'[^0-9]'), '');
                      setState(() {});
                    }
                  },
                  icon: Icon(
                    pdfOCData != null ? Icons.check_circle : Icons.upload_file,
                    color: pdfOCData != null ? kAccentGreen : Colors.black54,
                  ),
                  label: Text(
                    pdfOCData != null
                        ? 'Orden de compra cargada'
                        : 'Cargar orden de compra (PDF)',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kWhite,
                    foregroundColor: Colors.black87,
                    side: BorderSide(
                      color: pdfOCData != null
                          ? kAccentGreen
                          : kBorderColor.withValues(alpha: 0.05),
                    ),
                    elevation: 1,
                    minimumSize: const Size(300, 50),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['xml'],
                      withData: true,
                    );
                    if (result != null && result.files.single.bytes != null) {
                      xmlData = result.files.single.bytes!;
                      datosXml = await FacturaParserService.parseXmlBytes(
                          xmlData!); // ✅ nuevo parser
                      setState(() {});
                    }
                  },
                  icon: Icon(
                    xmlData != null ? Icons.check_circle : Icons.code,
                    color: xmlData != null ? kAccentGreen : Colors.black54,
                  ),
                  label: Text(
                    xmlData != null ? 'XML cargado' : 'Cargar XML de factura',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kWhite,
                    foregroundColor: Colors.black87,
                    side: BorderSide(
                      color: xmlData != null
                          ? kAccentGreen
                          : kBorderColor.withValues(alpha: 0.05),
                    ),
                    elevation: 1,
                    minimumSize: const Size(300, 50),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                      withData: true,
                    );
                    if (result != null && result.files.single.bytes != null) {
                      pdfFacturaData = result.files.single.bytes!;
                      setState(() {});
                    }
                  },
                  icon: Icon(
                    pdfFacturaData != null
                        ? Icons.check_circle
                        : Icons.picture_as_pdf,
                    color:
                        pdfFacturaData != null ? kAccentGreen : Colors.black54,
                  ),
                  label: Text(
                    pdfFacturaData != null
                        ? 'PDF de factura cargado'
                        : 'Cargar PDF de factura',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kWhite,
                    foregroundColor: Colors.black87,
                    side: BorderSide(
                      color: pdfFacturaData != null
                          ? kAccentGreen
                          : kBorderColor.withValues(alpha: 0.05),
                    ),
                    elevation: 1,
                    minimumSize: const Size(300, 50),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: validado ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: validado
                      ? Column(
                          children: const [
                            Icon(Icons.verified, color: kAccentGreen, size: 48),
                            SizedBox(height: 8),
                            Text(
                              '¡Todos los archivos fueron validados!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kAccentGreen),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: validado
                    ? () {
                        Navigator.pop(context);
                        onCompleted(ArchivosFactura(
                          pdfOC: pdfOCData!,
                          xmlFactura: xmlData!,
                          pdfFactura: pdfFacturaData!,
                          ordenCompra: ordenCompra,
                          datosXml: datosXml,
                        ));
                      }
                    : null,
                child: const Text('Continuar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
