import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:clipboard/clipboard.dart';

class MicrositioActions extends StatelessWidget {
  final String empresaId;

  const MicrositioActions({super.key, required this.empresaId});

  String get url => 'https://www.fisiospakym.com/micrositio/\$empresaId';

  void _abrirEnNavegador(BuildContext context) async {
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      Fluttertoast.showToast(msg: 'No se pudo abrir el navegador');
    }
  }

  void _copiarAlPortapapeles(BuildContext context) {
    FlutterClipboard.copy(url).then((_) {
      Fluttertoast.showToast(msg: 'Enlace copiado');
    });
  }

  void _mostrarQR(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Código QR'),
        content: QrImageView(
          data: url,
          size: 200,
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.link),
          label: const Text('Ver micrositio'),
          onPressed: () => _abrirEnNavegador(context),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text('Copiar enlace'),
          onPressed: () => _copiarAlPortapapeles(context),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.qr_code),
          label: const Text('Ver QR'),
          onPressed: () => _mostrarQR(context),
        ),
      ],
    );
  }
}
