// 🎉 BOOKING CONFIRMATION SCREEN PREMIUM - Glassmorphism & Cliente Fix
// 📁 Ubicación: /lib/screens/public/booking_confirmation_screen.dart
// 🎯 OBJETIVO: Pantalla de confirmación WOW con glassmorphism + nombres correctos
// ✅ NUEVO: Efectos premium + fix visualización nombres cliente

import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../enums/booking_types.dart';
import '../../services/booking/booking_configuration_service.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;
  final BookingType bookingType;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.bookingData,
    required this.bookingType,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with TickerProviderStateMixin {
  // 🎨 CONTROLADORES DE ANIMACIÓN
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // 🎨 ANIMACIÓN PRINCIPAL (Fade + Scale + Slide)
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 💓 ANIMACIÓN DE PULSO (Éxito continuo)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // ✨ ANIMACIÓN SHIMMER (Glassmorphism)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // 📈 CONFIGURAR ANIMACIONES
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));
  }

  void _startAnimationSequence() {
    // 🚀 SECUENCIA DE ANIMACIONES
    _mainController.forward();

    // ⏰ DELAY PARA ANIMACIONES SECUNDARIAS
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
        _shimmerController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _buildPremiumConfirmation(context),
    );
  }

  /// 🌟 CONFIRMACIÓN PREMIUM CON GLASSMORPHISM
  Widget _buildPremiumConfirmation(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _fadeAnimation,
        _scaleAnimation,
        _slideAnimation,
        _pulseAnimation,
        _shimmerAnimation,
      ]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            // 🎨 GRADIENTE PREMIUM DE 3 COLORES (IGUAL AL BOOKING)
            gradient: kHeaderGradientPremium,
          ),
          child: Stack(
            children: [
              // ✨ SHIMMER BACKGROUND GLASSMORPHISM
              _buildShimmerBackground(),

              // 📱 CONTENIDO PRINCIPAL
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildMainContent(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ✨ SHIMMER BACKGROUND GLASSMORPHISM
  Widget _buildShimmerBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _GlassmorphismPainter(_shimmerAnimation.value),
      ),
    );
  }

  /// 📱 CONTENIDO PRINCIPAL RESPONSIVO - ✅ FIX OVERFLOW
  Widget _buildMainContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isIPhoneSE = context.isIPhoneSE;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              // ✅ FIX: HACER SCROLLABLE
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(context.containerPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 📱 ESPACIADO TOP DINÁMICO
                    SizedBox(height: _getTopSpacing(context, constraints)),

                    // 🎉 ÍCONO DE ÉXITO CON ANIMACIÓN
                    _buildSuccessIcon(context),

                    SizedBox(height: _getDynamicSpacing(context, 1.0)),

                    // 🎯 MENSAJE PRINCIPAL
                    _buildMainMessage(context),

                    SizedBox(height: _getDynamicSpacing(context, 1.2)),

                    // 📋 DETALLES GLASSMORPHISM
                    _buildGlassDetailsCard(context),

                    SizedBox(height: _getDynamicSpacing(context, 0.8)),

                    // ℹ️ INFORMACIÓN ADICIONAL
                    _buildAdditionalInfo(context),

                    SizedBox(height: _getDynamicSpacing(context, 1.2)),

                    // 🚀 BOTÓN PREMIUM
                    _buildPremiumButton(context),

                    // 📱 ESPACIADO BOTTOM SEGURO
                    SizedBox(height: _getBottomSpacing(context)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 📏 ESPACIADO TOP DINÁMICO
  double _getTopSpacing(BuildContext context, BoxConstraints constraints) {
    if (context.isIPhoneSE) {
      return constraints.maxHeight < 650
          ? 20
          : 40; // ✅ MENOS ESPACIO EN PANTALLAS PEQUEÑAS
    }
    if (context.isMobile) {
      return constraints.maxHeight < 700 ? 30 : 60;
    }
    return 80;
  }

  /// 📏 ESPACIADO DINÁMICO ENTRE ELEMENTOS
  double _getDynamicSpacing(BuildContext context, double multiplier) {
    final baseSpacing = context.sectionSpacing;

    if (context.isIPhoneSE) {
      return (baseSpacing * 0.7 * multiplier); // ✅ 30% MENOS ESPACIO
    }
    if (context.isMobile) {
      return (baseSpacing * 0.85 * multiplier); // ✅ 15% MENOS ESPACIO
    }
    return baseSpacing * multiplier;
  }

  /// 📏 ESPACIADO BOTTOM SEGURO
  double _getBottomSpacing(BuildContext context) {
    if (context.isIPhoneSE) return 20;
    if (context.isMobile) return 30;
    return 40;
  }

  /// 🎉 ÍCONO DE ÉXITO CON PULSO Y GLASSMORPHISM
  Widget _buildSuccessIcon(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: context.isIPhoneSE ? 100 : 120,
            height: context.isIPhoneSE ? 100 : 120,
            decoration: BoxDecoration(
              // 🌟 GLASSMORPHISM CONTAINER
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: kAccentGreen.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: context.isIPhoneSE ? 50 : 60,
            ),
          ),
        );
      },
    );
  }

  /// 🎯 MENSAJE PRINCIPAL CON GRADIENTE TEXT
  Widget _buildMainMessage(BuildContext context) {
    return Column(
      children: [
        // ✨ TÍTULO CON EFECTO GRADIENTE
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
          ).createShader(bounds),
          child: Text(
            '¡Reserva Confirmada!',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.isIPhoneSE ? 28 : 32,
              fontWeight: FontWeight.bold,
              fontFamily: kFontFamily,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: context.isIPhoneSE ? 12 : 16),

        Text(
          BookingConfigurationService.getConfiguration(widget.bookingType)
              .confirmationMessage,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: context.isIPhoneSE ? 16 : 18,
            fontWeight: FontWeight.w400,
            fontFamily: kFontFamily,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 🪟 CARD DE DETALLES CON GLASSMORPHISM - ✅ FIX OVERFLOW
  Widget _buildGlassDetailsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: context.isIPhoneSE ? double.infinity : 600,
      ),
      padding: EdgeInsets.all(context.cardPadding),
      decoration: BoxDecoration(
        // 🌟 GLASSMORPHISM PREMIUM
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(context.cardRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🆔 ID DE RESERVA CON GRADIENTE
          _buildGradientText(
            'ID: ${widget.bookingId.substring(0, 8)}...',
            fontSize: context.isIPhoneSE ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),

          SizedBox(
              height: _getDynamicSpacing(context, 0.8)), // ✅ ESPACIADO DINÁMICO

          // 📋 DETALLES PRINCIPALES
          _buildDetailsList(context),
        ],
      ),
    );
  }

  /// 📋 LISTA DE DETALLES CON NOMBRES CORREGIDOS
  Widget _buildDetailsList(BuildContext context) {
    // ✅ FIX CRÍTICO: OBTENER NOMBRE CORRECTO DEL CLIENTE
    final clientName = _getCorrectClientName();

    return Column(
      children: [
        _buildDetailRow(
          'Servicio:',
          widget.bookingData['servicioNombre'] ?? 'No especificado',
          context,
        ),
        _buildDetailRow(
          'Cliente:',
          clientName, // ✅ NOMBRE CORREGIDO
          context,
        ),
        _buildDetailRow(
          'Teléfono:',
          widget.bookingData['clientPhone'] ??
              widget.bookingData['telefono'] ??
              'No especificado',
          context,
        ),
        if (widget.bookingData['profesionalNombre'] != null)
          _buildDetailRow(
            'Profesional:',
            widget.bookingData['profesionalNombre'],
            context,
          ),
        if (widget.bookingData['fechaInicio'] != null)
          _buildDetailRow(
            'Fecha:',
            _formatDateTime(widget.bookingData['fechaInicio']),
            context,
          ),
      ],
    );
  }

  /// ✅ FIX CRÍTICO: OBTENER NOMBRE CORRECTO DEL CLIENTE
  String _getCorrectClientName() {
    // 🔍 PRIORIDAD DE BÚSQUEDA DE NOMBRE
    final clienteName = widget.bookingData['clienteNombre'] ??
        widget.bookingData['nombreCliente'] ??
        widget.bookingData['nombre'] ??
        widget.bookingData['clientName'];

    if (clienteName != null && clienteName.toString().trim().isNotEmpty) {
      return clienteName.toString().trim();
    }

    // 📱 FALLBACK: CONSTRUIR DESDE TELÉFONO
    final telefono =
        widget.bookingData['clientPhone'] ?? widget.bookingData['telefono'];

    if (telefono != null && telefono.toString().trim().isNotEmpty) {
      return 'Cliente ${telefono.toString().substring(telefono.toString().length - 4)}';
    }

    // 🆔 ÚLTIMO FALLBACK: DESDE ID
    return 'Cliente ${widget.bookingId.substring(0, 6)}';
  }

  /// 📋 FILA DE DETALLE CON GLASSMORPHISM - ✅ FIX SPACING
  Widget _buildDetailRow(String label, String? value, BuildContext context) {
    if (value == null || value.isEmpty || value == 'No especificado') {
      return const SizedBox.shrink();
    }

    return Container(
      margin:
          EdgeInsets.only(bottom: context.isIPhoneSE ? 6 : 8), // ✅ MENOS MARGIN
      padding: EdgeInsets.symmetric(
        horizontal: context.isIPhoneSE ? 10 : 12, // ✅ MENOS PADDING
        vertical: context.isIPhoneSE ? 6 : 8, // ✅ MENOS PADDING
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.isIPhoneSE ? 65 : 75, // ✅ MENOS ANCHO
            child: Text(
              label,
              style: TextStyle(
                fontSize: context.isIPhoneSE ? 12 : 13, // ✅ FONT MÁS PEQUEÑO
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
                fontFamily: kFontFamily,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: context.isIPhoneSE ? 12 : 13, // ✅ FONT MÁS PEQUEÑO
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: kFontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ℹ️ INFORMACIÓN ADICIONAL GLASSMORPHISM - ✅ FIX OVERFLOW
  Widget _buildAdditionalInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: context.isIPhoneSE ? double.infinity : 600,
      ),
      padding: EdgeInsets.all(context.isIPhoneSE ? 12 : 16), // ✅ MENOS PADDING
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.cardRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: BookingConfigurationService.getConfiguration(
                widget.bookingType)
            .contactInstructions
            .map((instruction) => Padding(
                  padding: EdgeInsets.only(
                      bottom: context.isIPhoneSE ? 4 : 6), // ✅ MENOS PADDING
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white.withValues(alpha: 0.8),
                        size:
                            context.isIPhoneSE ? 14 : 16, // ✅ ÍCONO MÁS PEQUEÑO
                      ),
                      SizedBox(
                          width: context.isIPhoneSE ? 4 : 6), // ✅ MENOS ESPACIO
                      Expanded(
                        child: Text(
                          instruction,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: context.isIPhoneSE
                                ? 11
                                : 13, // ✅ FONT MÁS PEQUEÑO
                            fontFamily: kFontFamily,
                            height: 1.3, // ✅ MENOS LINE HEIGHT
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  /// 🚀 BOTÓN PREMIUM CON GRADIENTE
  Widget _buildPremiumButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.buttonHeight,
      decoration: BoxDecoration(
        // 🌟 GRADIENTE INVERSO
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.buttonRadius),
          ),
        ),
        child: Text(
          'Finalizar',
          style: TextStyle(
            color: kBrandPurple,
            fontSize: context.isIPhoneSE ? 15 : 16,
            fontWeight: FontWeight.w600,
            fontFamily: kFontFamily,
          ),
        ),
      ),
    );
  }

  /// 🎨 TEXTO CON GRADIENTE
  Widget _buildGradientText(
    String text, {
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [Colors.white, kAccentGreen.withValues(alpha: 0.9)],
      ).createShader(bounds),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.normal,
          fontFamily: kFontFamily,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 📅 FORMATEAR FECHA/HORA
  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'No especificado';

    try {
      DateTime parsedDate;

      if (dateTime is DateTime) {
        parsedDate = dateTime;
      } else if (dateTime is String) {
        parsedDate = DateTime.parse(dateTime);
      } else {
        return 'Fecha inválida';
      }

      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} ${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}

/// 🎨 PAINTER PARA GLASSMORPHISM BACKGROUND
class _GlassmorphismPainter extends CustomPainter {
  final double animationValue;

  _GlassmorphismPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // ✨ FORMAS GLASSMORPHISM ANIMADAS
    for (int i = 0; i < 5; i++) {
      final offset = animationValue * 200 + i * 100;
      final center = Offset(
        (size.width * 0.2 * i + offset) % (size.width + 100),
        size.height * 0.3 + (i * 50),
      );

      canvas.drawCircle(
        center,
        50 + (i * 20),
        paint,
      );
    }

    // 🌊 LÍNEAS SHIMMER
    final shimmerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final x = (animationValue * size.width + i * 40) % (size.width + 50);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - 30, size.height),
        shimmerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GlassmorphismPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
