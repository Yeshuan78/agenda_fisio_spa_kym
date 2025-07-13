import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ✅ COLORES DE MARCA PARA PDF (MISMO QUE EXPORT_EVENTO_PDF)
const PdfColor kBrandPurplePdf = PdfColor.fromInt(0xFF9920A7);
const PdfColor kAccentBluePdf = PdfColor.fromInt(0xFF4DB1E0);
const PdfColor kAccentGreenPdf = PdfColor.fromInt(0xFF8ABF54);
const PdfColor kBrandPurpleLightPdf = PdfColor.fromInt(0xFFEADCF9);

class QRPdfGenerator {
  // ✅ FUNCIÓN PRINCIPAL CON EXPERIENCIA PREMIUM
  static Future<void> generarQRComoPDF({
    required BuildContext context,
    required String url,
    required String servicio,
    required String profesional,
  }) async {
    Uint8List? pdfBytes;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => _QRGenerationDialogPremium(
        url: url,
        servicio: servicio,
        profesional: profesional,
        onPDFGenerated: (bytes) {
          pdfBytes = bytes;
        },
      ),
    );

    if (pdfBytes != null && context.mounted) {
      await _mostrarOpcionesPremium(context, pdfBytes!, servicio);
    }
  }
}

// ✅ DIALOG PREMIUM CON QRs CAYENDO (ADAPTADO DE EXPORT_EVENTO_PDF)
class _QRGenerationDialogPremium extends StatefulWidget {
  final String url;
  final String servicio;
  final String profesional;
  final Function(Uint8List) onPDFGenerated;

  const _QRGenerationDialogPremium({
    required this.url,
    required this.servicio,
    required this.profesional,
    required this.onPDFGenerated,
  });

  @override
  State<_QRGenerationDialogPremium> createState() =>
      _QRGenerationDialogPremiumState();
}

class _QRGenerationDialogPremiumState extends State<_QRGenerationDialogPremium>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _qrController; // ✅ CAMBIO: Controller para QRs

  int _currentStep = 0;
  bool _isCompleted = false;
  String _errorMessage = '';

  final List<_QRStep> _steps = [
    _QRStep('Preparando código QR', Icons.qr_code_2),
    _QRStep('Aplicando diseño profesional', Icons.palette),
    _QRStep('Optimizando para impresión', Icons.print),
    _QRStep('Generando documento PDF', Icons.picture_as_pdf),
    _QRStep('Finalizando QR premium', Icons.check_circle),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _qrController = AnimationController(
      // ✅ CAMBIO: Para QRs cayendo
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _startGeneration();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _qrController.dispose(); // ✅ CAMBIO: Dispose QR controller
    super.dispose();
  }

  Future<void> _startGeneration() async {
    try {
      for (int i = 0; i < _steps.length; i++) {
        if (!mounted) return;

        setState(() => _currentStep = i);
        await _progressController.animateTo((i + 1) / _steps.length);

        switch (i) {
          case 0:
            await Future.delayed(const Duration(milliseconds: 800));
            break;
          case 1:
            await Future.delayed(const Duration(milliseconds: 600));
            break;
          case 2:
            await Future.delayed(const Duration(milliseconds: 700));
            break;
          case 3:
            // ✅ GENERAR PDF PREMIUM
            try {
              final pdfBytes = await _generarQRPDFPremium(
                widget.url,
                widget.servicio,
                widget.profesional,
              ).timeout(const Duration(seconds: 15));
              widget.onPDFGenerated(pdfBytes);
            } on TimeoutException {
              throw Exception('Tiempo de espera agotado');
            }
            await Future.delayed(const Duration(milliseconds: 500));
            break;
          case 4:
            await Future.delayed(const Duration(milliseconds: 400));
            break;
        }
      }

      if (!mounted) return;
      setState(() => _isCompleted = true);

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isCompleted = false;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 25,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // ✅ QRs CAYENDO (ADAPTADO DE HOJAS)
            ...List.generate(
              6,
              (index) => AnimatedBuilder(
                animation: _qrController,
                builder: (context, child) {
                  final offset = (_qrController.value + index * 0.2) % 1.0;
                  final horizontalOffset = (index % 2 == 0)
                      ? 50 + (index * 60.0)
                      : 80 + (index * 45.0);
                  return Positioned(
                    left: horizontalOffset,
                    top: 30 + (offset * 320),
                    child: Transform.rotate(
                      angle: offset * 0.5,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          Icons
                              .qr_code_2, // ✅ CAMBIO: QR en lugar de description
                          size: 18 + (index * 4.0),
                          color: Colors
                              .purple[600], // ✅ CAMBIO: Color morado de marca
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildStepsList(),
                  const SizedBox(height: 28),
                  _buildProgressBar(),
                  const SizedBox(height: 20),
                  if (_isCompleted) _buildCompletionState(),
                  if (_errorMessage.isNotEmpty) _buildErrorState(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _qrController]),
          builder: (context, child) {
            final pulseScale = 0.85 + (_pulseController.value * 0.3);
            final rotation = _qrController.value * 2 * 3.14159;

            return Transform.rotate(
              angle: rotation * 0.1,
              child: Transform.scale(
                scale: pulseScale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors
                            .purple[400]!, // ✅ CAMBIO: Morado en lugar de rojo
                        Colors.blue[400]!, // ✅ CAMBIO: Azul de marca
                        Colors.purple[600]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple
                            .withValues(alpha: 0.04), // ✅ CAMBIO: Morado
                        blurRadius: 15 + (_pulseController.value * 10),
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: Colors.blue
                            .withValues(alpha: 0.02), // ✅ CAMBIO: Azul
                        blurRadius: 25 + (_pulseController.value * 15),
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_2, // ✅ CAMBIO: QR en lugar de favorite
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 24),

        // ✅ TÍTULO PARA QR
        AnimatedBuilder(
          animation: _qrController,
          builder: (context, child) {
            final opacity = 0.7 + (_qrController.value * 0.3);
            return Opacity(
              opacity: opacity,
              child: const Text(
                'Generando código QR',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.servicio,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStepsList() {
    return Column(
      children: _steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep && !_isCompleted;
        final isPending = index > _currentStep;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green[500]
                      : isCurrent
                          ? Colors
                              .purple[500] // ✅ CAMBIO: Morado en lugar de azul
                          : Colors.grey[300],
                  boxShadow: isCompleted || isCurrent
                      ? [
                          BoxShadow(
                            color: (isCompleted
                                    ? Colors.green
                                    : Colors.purple) // ✅ CAMBIO
                                .withValues(alpha: 0.03),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : step.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                    color: isPending ? Colors.grey[500] : Colors.black87,
                  ),
                ),
              ),
              if (isCurrent)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.purple[500]!), // ✅ CAMBIO
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso general',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Text(
                  '${(_progressController.value * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressController.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple[400]!,
                        Colors.blue[400]!
                      ], // ✅ CAMBIO
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green[600],
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡QR generado exitosamente!', // ✅ CAMBIO: Texto específico para QR
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Elige cómo quieres utilizarlo',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_rounded,
            color: Colors.red[600],
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error al generar el QR',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorMessage.length > 60
                      ? '${_errorMessage.substring(0, 60)}...'
                      : _errorMessage,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QRStep {
  final String label;
  final IconData icon;
  _QRStep(this.label, this.icon);
}

// ✅ GENERAR PDF PREMIUM CON DISEÑO PROFESIONAL (ADAPTADO DE EXPORT_EVENTO_PDF)
Future<Uint8List> _generarQRPDFPremium(
  String url,
  String servicio,
  String profesional,
) async {
  final doc = pw.Document();

  // Tipografías profesionales
  final font = await PdfGoogleFonts.poppinsRegular();
  final boldFont = await PdfGoogleFonts.poppinsSemiBold();

  // Cargar logo
  final ByteData logoData =
      await rootBundle.load('assets/images/logo_kym_black.png');
  final Uint8List logoBytes = logoData.buffer.asUint8List();

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // 🎨 HEADER PREMIUM CON GRADIENTE Y LOGO CENTRADO
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: kBrandPurpleLightPdf,
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: kBrandPurplePdf),
              ),
              child: pw.Column(
                children: [
                  pw.Center(
                      child: pw.Image(pw.MemoryImage(logoBytes), height: 60)),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    'CÓDIGO QR',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: kBrandPurplePdf,
                      letterSpacing: 2,
                      font: boldFont,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // 🎨 INFORMACIÓN DEL SERVICIO EN TARJETA
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: kBrandPurpleLightPdf,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: kBrandPurplePdf),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'INFORMACIÓN DEL SERVICIO',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: kBrandPurplePdf,
                      font: boldFont,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text('Servicio: $servicio',
                      style: pw.TextStyle(fontSize: 16, font: font)),
                  pw.SizedBox(height: 8),
                  pw.Text('Profesional: $profesional',
                      style: pw.TextStyle(fontSize: 16, font: font)),
                ],
              ),
            ),

            pw.SizedBox(height: 32),

            // 🎨 QR CODE PREMIUM CON MARCO
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(16),
                border: pw.Border.all(color: kBrandPurplePdf, width: 3),
                boxShadow: [
                  pw.BoxShadow(
                    color: kBrandPurplePdf.shade(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'ESCANEA PARA REGISTRAR TU SERVICIO',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: kBrandPurplePdf,
                      font: boldFont,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.BarcodeWidget(
                    data: url,
                    barcode: pw.Barcode.qrCode(),
                    width: 250,
                    height: 250,
                  ),
                  pw.SizedBox(height: 16),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: kAccentBluePdf.shade(0.1),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'Código generado con tecnología Fisio Spa KYM',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: kAccentBluePdf,
                        font: font,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // 🎨 INSTRUCCIONES PREMIUM
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: kAccentGreenPdf.shade(0.1),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: kAccentGreenPdf),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'INSTRUCCIONES DE USO',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: kAccentGreenPdf,
                      font: boldFont,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    '1. Escanea el código QR con tu dispositivo móvil',
                    style: pw.TextStyle(fontSize: 12, font: font),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '2. Ingresa tu número de empleado cuando se solicite',
                    style: pw.TextStyle(fontSize: 12, font: font),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '3. Completa la encuesta de satisfacción',
                    style: pw.TextStyle(fontSize: 12, font: font),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '4. ¡Listo! Tu servicio quedará registrado automáticamente',
                    style: pw.TextStyle(fontSize: 12, font: font),
                  ),
                ],
              ),
            ),

            pw.Spacer(),

            // 🎨 FOOTER CON URL
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                url,
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                  font: font,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ],
        );
      },
    ),
  );

  return await doc.save();
}

// ✅ OPCIONES PREMIUM (IGUAL QUE EXPORT_EVENTO_PDF)
Future<void> _mostrarOpcionesPremium(
  BuildContext context,
  Uint8List pdfBytes,
  String servicio,
) async {
  await showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.purple[400]!,
                  Colors.blue[400]!
                ]), // ✅ CAMBIO: Colores de marca
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_2, // ✅ CAMBIO: QR icon
                  color: Colors.white,
                  size: 30),
            ),
            const SizedBox(height: 20),
            const Text('QR listo para usar',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            Text('¿Cómo quieres utilizar tu código QR?',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            _OpcionButton(
              icon: Icons.open_in_new_rounded,
              titulo: 'Abrir en nueva ventana',
              descripcion: 'Visualizar QR en nueva pestaña del navegador',
              color: Colors.blue,
              onTap: () async {
                Navigator.pop(context);
                await _abrirPDFEnNuevaVentana(pdfBytes, servicio);
              },
            ),
            const SizedBox(height: 12),
            _OpcionButton(
              icon: Icons.print_rounded,
              titulo: 'Imprimir',
              descripcion: 'Imprimir código QR en papel',
              color: Colors.orange,
              onTap: () async {
                Navigator.pop(context);
                await _abrirPDFParaImprimir(pdfBytes);
              },
            ),
            const SizedBox(height: 12),
            _OpcionButton(
              icon: Icons.download_rounded,
              titulo: 'Descargar',
              descripcion: 'Guardar QR en tu dispositivo',
              color: Colors.green,
              onTap: () async {
                Navigator.pop(context);
                await _descargarPDF(pdfBytes, servicio);
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15)),
            ),
          ],
        ),
      ),
    ),
  );
}

class _OpcionButton extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  const _OpcionButton({
    required this.icon,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.01),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(descripcion,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}

// ✅ FUNCIONES DE APERTURA (IGUALES QUE EXPORT_EVENTO_PDF)
Future<void> _abrirPDFEnNuevaVentana(
    Uint8List pdfBytes, String servicio) async {
  try {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    Future.delayed(
        const Duration(seconds: 5), () => html.Url.revokeObjectUrl(url));
  } catch (e) {
    debugPrint('Error abriendo PDF: $e');
  }
}

Future<void> _descargarPDF(Uint8List pdfBytes, String servicio) async {
  try {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final fileName =
        'QR_${servicio.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w\s-]'), '')}.pdf';
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    debugPrint('Error descargando PDF: $e');
  }
}

Future<void> _abrirPDFParaImprimir(Uint8List pdfBytes) async {
  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes);
}
