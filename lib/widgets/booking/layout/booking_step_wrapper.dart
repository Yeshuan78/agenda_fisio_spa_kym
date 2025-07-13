// [booking_step_wrapper.dart] - ✅ ESTRUCTURA LAYERED: Glassmorphism + Card Blanco
// 📁 Ubicación: /lib/widgets/booking/layout/booking_step_wrapper.dart
// 🎯 OBJETIVO: Fondo glassmorphism + card blanco encima + contenido arriba (como imagen)

import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import '../components/booking_step_header.dart';

/// 📦 WRAPPER LAYERED - ✅ ESTRUCTURA DE CAPAS COMO IMAGEN
class BookingStepWrapper extends StatefulWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget child;
  final bool isMobile;
  final bool animate;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool showHeader;

  const BookingStepWrapper({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.child,
    this.isMobile = false,
    this.animate = true,
    this.padding,
    this.borderRadius,
    this.showHeader = true,
  });

  @override
  State<BookingStepWrapper> createState() => _BookingStepWrapperState();
}

class _BookingStepWrapperState extends State<BookingStepWrapper>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.animate) {
      _initializeAnimations();
      _startAnimations();
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
        _scaleController.forward();
      }
    });
  }

  @override
  void dispose() {
    if (widget.animate) {
      _fadeController.dispose();
      _slideController.dispose();
      _scaleController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final containerPadding =
        widget.padding ?? EdgeInsets.all(context.cardPadding);
    final radius = widget.borderRadius ?? context.cardRadius;

    if (!widget.animate) {
      return _buildLayeredContainer(containerPadding, radius, context);
    }

    return AnimatedBuilder(
      animation:
          Listenable.merge([_fadeAnimation, _slideAnimation, _scaleAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildLayeredContainer(containerPadding, radius, context),
            ),
          ),
        );
      },
    );
  }

  /// 🎨 ESTRUCTURA LAYERED - ✅ COMO LA IMAGEN
  Widget _buildLayeredContainer(
      EdgeInsetsGeometry padding, double radius, BuildContext context) {
    final isIPhoneSE = context.isIPhoneSE;

    return Container(
      width: double.infinity,
      // ✅ CAPA 1: FONDO GLASSMORPHISM CON GRADIENTE
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kBrandPurple.withValues(alpha: 0.1),
            kAccentBlue.withValues(alpha: 0.08),
            kAccentGreen.withValues(alpha: 0.06),
            kBrandPurple.withValues(alpha: 0.04),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(radius + 8), // ✅ RADIO MÁS GRANDE
        boxShadow: [
          // ✅ SOMBRAS DEL FONDO GLASSMORPHISM
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.15),
            offset: const Offset(0, 8),
            blurRadius: 32,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: kAccentBlue.withValues(alpha: 0.08),
            offset: const Offset(0, 16),
            blurRadius: 48,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isIPhoneSE ? 8 : 12), // ✅ PADDING DEL FONDO
        child: Container(
          width: double.infinity,
          padding: padding,
          // ✅ CAPA 2: CARD BLANCO ENCIMA DEL GLASSMORPHISM
          decoration: BoxDecoration(
            color: Colors.white, // ✅ FONDO BLANCO SÓLIDO
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              // ✅ SOMBRAS DEL CARD BLANCO
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
                blurRadius: 16,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 8),
                blurRadius: 24,
                spreadRadius: -4,
              ),
            ],
            border: Border.all(
              color: kBorderSoft.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ CAPA 3: CONTENIDO SOBRE EL CARD BLANCO
              if (widget.showHeader) ...[
                BookingStepHeader(
                  icon: widget.icon,
                  title: widget.title,
                  subtitle: widget.subtitle,
                  accentColor: widget.accentColor,
                ),
                SizedBox(height: context.sectionSpacing),
              ],

              // ✅ CONTENIDO PRINCIPAL (siempre visible)
              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎨 FACTORY PARA CREAR WRAPPERS INTELIGENTES
class BookingStepWrapperFactory {
  static Widget create({
    required BuildContext context,
    required Widget child,
    bool animate = true,
    bool minimal = false,
    int? stepNumber,
    String? title,
    String? subtitle,
    IconData? icon,
    Color? accentColor,
  }) {
    if (minimal) {
      return BookingStepWrapperSimple(
        child: child,
        isMobile: context.isMobile,
      );
    }

    if (stepNumber != null && title != null) {
      return BookingStepWrapper(
        stepNumber: stepNumber,
        title: title,
        subtitle: subtitle ?? '',
        icon: icon ?? Icons.spa,
        accentColor: accentColor ?? kBrandPurple,
        animate: animate,
        child: child,
      );
    }

    return BookingStepWrapperSimple(
      child: child,
      isMobile: context.isMobile,
    );
  }
}

/// 📦 WRAPPER SIMPLE CON ESTRUCTURA LAYERED - ✅ PARA client_type_selection
class BookingStepWrapperSimple extends StatelessWidget {
  final Widget child;
  final bool isMobile;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const BookingStepWrapperSimple({
    super.key,
    required this.child,
    this.isMobile = false,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final containerPadding = padding ?? EdgeInsets.all(context.cardPadding);
    final radius = borderRadius ?? context.cardRadius;
    final isIPhoneSE = context.isIPhoneSE;

    return Container(
      width: double.infinity,
      // ✅ CAPA 1: FONDO GLASSMORPHISM (IGUAL QUE LA IMAGEN)
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kBrandPurple.withValues(alpha: 0.1),
            kAccentBlue.withValues(alpha: 0.08),
            kAccentGreen.withValues(alpha: 0.06),
            kBrandPurple.withValues(alpha: 0.04),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(radius + 8),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.15),
            offset: const Offset(0, 8),
            blurRadius: 32,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: kAccentBlue.withValues(alpha: 0.08),
            offset: const Offset(0, 16),
            blurRadius: 48,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isIPhoneSE ? 8 : 12), // ✅ ESPACIADO ENTRE CAPAS
        child: Container(
          width: double.infinity,
          padding: containerPadding,
          // ✅ CAPA 2: CARD BLANCO ENCIMA
          decoration: BoxDecoration(
            color: Colors.white, // ✅ FONDO BLANCO SÓLIDO
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
                blurRadius: 16,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 8),
                blurRadius: 24,
                spreadRadius: -4,
              ),
            ],
            border: Border.all(
              color: kBorderSoft.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          // ✅ CAPA 3: CONTENIDO SOBRE EL CARD BLANCO
          child: child,
        ),
      ),
    );
  }
}

/// 🎨 VARIANTE PREMIUM CON ANIMACIONES - MANTENER FUNCIONALIDAD EXISTENTE
class BookingStepWrapperAnimated extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool showProgress;
  final int currentStep;
  final int totalSteps;

  const BookingStepWrapperAnimated({
    super.key,
    required this.child,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.showProgress = false,
    this.currentStep = 1,
    this.totalSteps = 4,
  });

  @override
  State<BookingStepWrapperAnimated> createState() =>
      _BookingStepWrapperAnimatedState();
}

class _BookingStepWrapperAnimatedState extends State<BookingStepWrapperAnimated>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIPhoneSE = context.isIPhoneSE;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: double.infinity,
              // ✅ CAPA 1: FONDO GLASSMORPHISM ANIMADO
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accentColor.withValues(alpha: 0.1),
                    kAccentBlue.withValues(alpha: 0.08),
                    kAccentGreen.withValues(alpha: 0.06),
                    widget.accentColor.withValues(alpha: 0.04),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(isIPhoneSE ? 28 : 32),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.15),
                    offset: const Offset(0, 8),
                    blurRadius: 32,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: kAccentBlue.withValues(alpha: 0.08),
                    offset: const Offset(0, 16),
                    blurRadius: 48,
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(isIPhoneSE ? 8 : 12),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isIPhoneSE ? 20 : 32),
                  // ✅ CAPA 2: CARD BLANCO ANIMADO
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isIPhoneSE ? 20 : 24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        offset: const Offset(0, 4),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        offset: const Offset(0, 8),
                        blurRadius: 24,
                        spreadRadius: -4,
                      ),
                    ],
                    border: Border.all(
                      color: kBorderSoft.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  // ✅ CAPA 3: CONTENIDO ANIMADO
                  child: Column(
                    children: [
                      // Header animado
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: BookingStepHeader(
                              icon: widget.icon,
                              title: widget.title,
                              subtitle: widget.subtitle,
                              accentColor: widget.accentColor,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: context.sectionSpacing),

                      // Contenido principal animado
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: widget.child,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 📊 WRAPPER CON PROGRESS BAR
class BookingStepWrapperWithProgress extends StatelessWidget {
  final Widget child;
  final int currentStep;
  final int totalSteps;
  final Color accentColor;
  final String title;
  final String subtitle;
  final IconData icon;

  const BookingStepWrapperWithProgress({
    super.key,
    required this.child,
    required this.currentStep,
    required this.totalSteps,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    final isIPhoneSE = context.isIPhoneSE;

    return Container(
      width: double.infinity,
      // ✅ CAPA 1: FONDO GLASSMORPHISM
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.1),
            kAccentBlue.withValues(alpha: 0.08),
            kAccentGreen.withValues(alpha: 0.06),
            accentColor.withValues(alpha: 0.04),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(isIPhoneSE ? 28 : 32),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            offset: const Offset(0, 8),
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isIPhoneSE ? 8 : 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isIPhoneSE ? 20 : 32),
          // ✅ CAPA 2: CARD BLANCO
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isIPhoneSE ? 20 : 24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: kBorderSoft.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          // ✅ CAPA 3: CONTENIDO CON PROGRESS
          child: Column(
            children: [
              // Progress bar
              _buildProgressBar(context, progress),

              SizedBox(height: isIPhoneSE ? 16 : 24),

              // Header
              BookingStepHeader(
                icon: icon,
                title: title,
                subtitle: subtitle,
                accentColor: accentColor,
              ),

              SizedBox(height: context.sectionSpacing),

              // Contenido principal
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double progress) {
    final isIPhoneSE = context.isIPhoneSE;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paso $currentStep de $totalSteps',
              style: TextStyle(
                fontSize: isIPhoneSE ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
                fontFamily: kFontFamily,
              ),
            ),
            Text(
              '${(progress * 100).round()}% completado',
              style: TextStyle(
                fontSize: isIPhoneSE ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
                fontFamily: kFontFamily,
              ),
            ),
          ],
        ),
        SizedBox(height: isIPhoneSE ? 8 : 12),
        Container(
          height: isIPhoneSE ? 4 : 6,
          decoration: BoxDecoration(
            color: kBorderSoft,
            borderRadius: BorderRadius.circular(isIPhoneSE ? 2 : 3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, kAccentBlue],
                ),
                borderRadius: BorderRadius.circular(isIPhoneSE ? 2 : 3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 🎯 VARIANTE COMPACTA PARA ESPACIOS PEQUEÑOS
class BookingStepWrapperCompact extends StatelessWidget {
  final Widget child;
  final String title;
  final Color accentColor;
  final IconData? icon;

  const BookingStepWrapperCompact({
    super.key,
    required this.child,
    required this.title,
    required this.accentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isIPhoneSE = context.isIPhoneSE;

    return Container(
      width: double.infinity,
      // ✅ FONDO GLASSMORPHISM COMPACTO
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.06),
            accentColor.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(isIPhoneSE ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isIPhoneSE ? 6 : 8),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isIPhoneSE ? 16 : 20),
          // ✅ CARD BLANCO COMPACTO
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isIPhoneSE ? 12 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: kBorderSoft.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header compacto
              if (icon != null) ...[
                Row(
                  children: [
                    Icon(icon, color: accentColor, size: isIPhoneSE ? 16 : 20),
                    SizedBox(width: isIPhoneSE ? 8 : 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: isIPhoneSE ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: kFontFamily,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isIPhoneSE ? 12 : 16),
              ],

              // Contenido
              child,
            ],
          ),
        ),
      ),
    );
  }
}
