// [agenda_animation_controller.dart]
// 📁 Ubicación: /lib/controllers/agenda_animation_controller.dart
// 🔧 EXTRACCIÓN QUIRÚRGICA: Controllers y secuencias de animación
// ✅ COPY-PASTE EXACTO del archivo original - CERO MODIFICACIONES

import 'package:flutter/material.dart';

class AgendaAnimationController {
  // ✅ ANIMATION CONTROLLERS EXACTOS DEL ORIGINAL
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late AnimationController _fabController;
  late AnimationController _liveController;

  // ✅ ANIMATIONS EXACTAS DEL ORIGINAL
  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _fabAnimation;
  late Animation<double> _liveAnimation;

  // ========================================================================
  // 🎯 GETTERS EXACTOS DEL ORIGINAL
  // ========================================================================

  // ✅ ANIMATION CONTROLLERS GETTERS
  AnimationController get headerController => _headerController;
  AnimationController get cardsController => _cardsController;
  AnimationController get fabController => _fabController;
  AnimationController get liveController => _liveController;

  // ✅ ANIMATIONS GETTERS
  Animation<double> get headerAnimation => _headerAnimation;
  Animation<double> get cardsAnimation => _cardsAnimation;
  Animation<double> get fabAnimation => _fabAnimation;
  Animation<double> get liveAnimation => _liveAnimation;

  // ========================================================================
  // 🎯 INIT ANIMATIONS EXACTO DEL ORIGINAL
  // ========================================================================

  // ✅ INIT ANIMATIONS EXACTO DEL ORIGINAL
  void initAnimations(TickerProvider vsync) {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );
    _cardsAnimation = CurvedAnimation(
      parent: _cardsController,
      curve: Curves.easeOutCubic,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );

    _liveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );
    _liveAnimation = CurvedAnimation(
      parent: _liveController,
      curve: Curves.easeInOut,
    );

    startAnimationSequence();
    _liveController.repeat(reverse: true);
  }

  // ========================================================================
  // 🎯 SECUENCIA DE ANIMACIONES EXACTA DEL ORIGINAL
  // ========================================================================

  // ✅ START ANIMATION SEQUENCE EXACTO DEL ORIGINAL
  void startAnimationSequence() async {
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardsController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _fabController.forward();
  }

  // ========================================================================
  // 🎯 DISPOSE EXACTO DEL ORIGINAL
  // ========================================================================

  // ✅ DISPOSE EXACTO DEL ORIGINAL
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    _fabController.dispose();
    _liveController.dispose();
  }
}