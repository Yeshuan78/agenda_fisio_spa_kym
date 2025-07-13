// [evento_card_animations.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/card/evento_card_animations.dart
// 🎯 EXTRACCIÓN QUIRÚRGICA: Controladores de animación del EventoCard original

import 'package:flutter/material.dart';

class EventoCardAnimations {
  // ✅ ANIMACIONES EXACTAS EXTRAÍDAS DE evento_card.dart líneas 50-120
  late AnimationController hoverController;
  late AnimationController copyController;
  late AnimationController stateController;

  // ✅ ANIMACIONES SUTILES EXACTAS
  late Animation<double> elevationAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> copyAnimation;
  late Animation<double> stateAnimation;

  /// 🎯 EXTRACCIÓN EXACTA del método _initAnimations()
  void initAnimations(TickerProvider vsync) {
    // ✅ ANIMACIÓN PRINCIPAL DE HOVER (SUTIL COMO PULSE CARD)
    hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: vsync,
    );

    // ✅ ANIMACIÓN DE COPIA (FEEDBACK VISUAL)
    copyController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );

    // ✅ ANIMACIÓN DEL SELECTOR DE ESTADOS
    stateController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );

    // ✅ ELEVACIÓN SUTIL (NO AGRESIVA)
    elevationAnimation = Tween<double>(
      begin: 2.0, // Muy sutil en reposo
      end: 8.0, // Moderado en hover
    ).animate(CurvedAnimation(
      parent: hoverController,
      curve: Curves.easeOutCubic,
    ));

    // ✅ ESCALA CASI IMPERCEPTIBLE
    scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01, // Solo 1% de crecimiento
    ).animate(CurvedAnimation(
      parent: hoverController,
      curve: Curves.easeOutCubic,
    ));

    // ✅ ANIMACIÓN DE COPIA
    copyAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: copyController,
      curve: Curves.elasticOut,
    ));

    // ✅ ANIMACIÓN DEL SELECTOR DE ESTADOS
    stateAnimation = CurvedAnimation(
      parent: stateController,
      curve: Curves.easeOutCubic,
    );
  }

  /// 🎯 EXTRACCIÓN EXACTA del método dispose()
  void dispose() {
    hoverController.dispose();
    copyController.dispose();
    stateController.dispose();
  }
}