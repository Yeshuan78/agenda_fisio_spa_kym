// [Archivo: lib/widgets/eventos/qr_generator_button.dart]

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class QRGeneratorButton extends StatelessWidget {
  final String profesionalId;
  final String servicioId;
  final String eventoId;

  const QRGeneratorButton({
    super.key,
    required this.profesionalId,
    required this.servicioId,
    required this.eventoId,
  });

  @override
  Widget build(BuildContext context) {
    final url =
        'https://fisiospakym.com/kym-pulse/?e=$eventoId&p=$profesionalId&s=$servicioId';

    return IconButton(
      tooltip: 'Generar link QR',
      icon: const Icon(Icons.qr_code),
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: url));
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copiado y abierto')),
        );
      },
    );
  }
}
