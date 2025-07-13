import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:agenda_fisio_spa_kym/models/factura_model.dart';
import 'package:agenda_fisio_spa_kym/services/factura_service.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class FacturaArchivosToolbar extends StatefulWidget {
  final FacturaModel factura;

  const FacturaArchivosToolbar({super.key, required this.factura});

  @override
  State<FacturaArchivosToolbar> createState() => _FacturaArchivosToolbarState();
}

class _FacturaArchivosToolbarState extends State<FacturaArchivosToolbar> {
  final storage = FirebaseStorage.instance;
  final facturaService = FacturaService();

  final Map<String, bool> _estadoArchivo = {
    'pdfUrl': false,
    'xmlUrl': false,
    'ocUrl': false,
    'complementoUrl': false,
  };

  @override
  void initState() {
    super.initState();
    _verificarArchivos();
  }

  Future<void> _verificarArchivos() async {
    final id = widget.factura.id;
    final archivos = {
      'pdfUrl': 'facturas/$id/factura.pdf',
      'xmlUrl': 'facturas/$id/factura.xml',
      'ocUrl': 'facturas/$id/orden_compra.pdf',
      'complementoUrl': 'facturas/$id/complemento.pdf',
    };

    for (final campo in archivos.keys) {
      try {
        final ref = storage.ref(archivos[campo]!);
        await ref.getDownloadURL();
        if (mounted) {
          setState(() => _estadoArchivo[campo] = true);
        }
      } catch (_) {
        if (mounted) {
          setState(() => _estadoArchivo[campo] = false);
        }
      }
    }
  }

  Future<void> _verOSubirArchivo({
    required String campoFirestore,
    required String nombre,
    required String storagePath,
    required List<String> extensiones,
    required String? url,
  }) async {
    if (url != null) {
      await launchUrl(Uri.parse(url));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensiones,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final data = result.files.single.bytes!;
      final ref = storage.ref(storagePath);

      await ref.putData(data);
      final newUrl = await ref.getDownloadURL();

      await facturaService.actualizarCampo(
        widget.factura.id,
        campoFirestore,
        newUrl,
      );

      if (mounted) {
        setState(() => _estadoArchivo[campoFirestore] = true);
      }
    }
  }

  Widget _boton({
    required String label,
    required IconData icon,
    required String campoFirestore,
    required String? url,
    required String path,
    required List<String> extensiones,
  }) {
    final cargado = (_estadoArchivo[campoFirestore] ?? false) || (url != null);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ElevatedButton.icon(
        onPressed: () => _verOSubirArchivo(
          campoFirestore: campoFirestore,
          nombre: label,
          storagePath: path,
          extensiones: extensiones,
          url: url,
        ),
        icon: Icon(icon,
            size: 16, color: cargado ? Colors.green[700] : Colors.grey[600]),
        label: Text(label, overflow: TextOverflow.ellipsis),
        style: ElevatedButton.styleFrom(
          backgroundColor: kWhite,
          foregroundColor: Colors.black,
          side: BorderSide(color: cargado ? Colors.green : Colors.grey),
          elevation: 0,
          minimumSize: const Size(160, 28),
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.factura.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _boton(
          label: 'Orden Compra',
          icon: Icons.description,
          campoFirestore: 'ocUrl',
          url: widget.factura.ocUrl,
          path: 'facturas/$id/orden_compra.pdf',
          extensiones: ['pdf'],
        ),
        _boton(
          label: 'Factura PDF',
          icon: Icons.picture_as_pdf,
          campoFirestore: 'pdfUrl',
          url: widget.factura.pdfUrl,
          path: 'facturas/$id/factura.pdf',
          extensiones: ['pdf'],
        ),
        _boton(
          label: 'XML',
          icon: Icons.code,
          campoFirestore: 'xmlUrl',
          url: widget.factura.xmlUrl,
          path: 'facturas/$id/factura.xml',
          extensiones: ['xml'],
        ),
        _boton(
          label: 'Complemento',
          icon: Icons.library_books,
          campoFirestore: 'complementoUrl',
          url: widget.factura.complementoUrl,
          path: 'facturas/$id/complemento.pdf',
          extensiones: ['pdf'],
        ),
      ],
    );
  }
}
