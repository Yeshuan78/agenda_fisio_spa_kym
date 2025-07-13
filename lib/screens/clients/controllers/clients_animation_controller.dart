// [clients_animation_controller.dart] - CONTROLADOR DE ANIMACIONES
// 📁 Ubicación: /lib/screens/clients/controllers/clients_animation_controller.dart
// 🎯 OBJETIVO: Extraer toda la lógica de animaciones del screen principal

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/screens/clients/utils/client_constants.dart';

/// 🎬 CONTROLLER DE ANIMACIONES - EXTRAÍDO DEL SCREEN PRINCIPAL
class ClientsAnimationController extends ChangeNotifier {
  // ✅ CONTROLADORES DE ANIMACIÓN (COPIADO EXACTO)
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late AnimationController _fabAnimationController;
  late AnimationController _viewModeTransitionController;

  // ✅ ANIMACIONES (COPIADO EXACTO)
  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _fabAnimation;
  late Animation<double> _viewModeTransition;

  // ✅ ESTADO DE ANIMACIONES
  bool _isInitialized = false;

  // ====================================================================
  // 🎯 CONSTRUCTOR
  // ====================================================================

  ClientsAnimationController({required TickerProvider vsync}) {
    _initializeAnimations(vsync);
  }

  // ====================================================================
  // 🎯 GETTERS PÚBLICOS (COPIADO EXACTO)
  // ====================================================================

  Animation<double> get headerAnimation => _headerAnimation;
  Animation<double> get cardsAnimation => _cardsAnimation;
  Animation<double> get fabAnimation => _fabAnimation;
  Animation<double> get viewModeTransition => _viewModeTransition;

  AnimationController get headerAnimationController => _headerAnimationController;
  AnimationController get cardsAnimationController => _cardsAnimationController;
  AnimationController get fabAnimationController => _fabAnimationController;
  AnimationController get viewModeTransitionController => _viewModeTransitionController;

  bool get isInitialized => _isInitialized;

  // ====================================================================
  // 🚀 MÉTODOS DE INICIALIZACIÓN (COPIADO EXACTO)
  // ====================================================================

  void _initializeAnimations(TickerProvider vsync) {
    // Animación de header
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Animación de cards
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );
    _cardsAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutQuart,
    );

    // Animación de FAB
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    );

    // Animación para transición de vista
    _viewModeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
    _viewModeTransition = CurvedAnimation(
      parent: _viewModeTransitionController,
      curve: Curves.easeInOut,
    );

    _isInitialized = true;
    notifyListeners();
  }

  // ====================================================================
  // 🎬 MÉTODOS DE CONTROL DE ANIMACIONES (COPIADO EXACTO)
  // ====================================================================

  void startAnimations() {
    if (!_isInitialized) return;

    // Secuencia de animaciones
    _headerAnimationController.forward().then((_) {
      _cardsAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _fabAnimationController.forward();
      });
    });

    // Iniciar animación de transición de vista
    _viewModeTransitionController.forward();
  }

  void resetAnimations() {
    if (!_isInitialized) return;

    _headerAnimationController.reset();
    _cardsAnimationController.reset();
    _fabAnimationController.reset();
    _viewModeTransitionController.reset();
  }

  // ✅ ANIMACIONES ESPECÍFICAS PARA VIEW MODE TRANSITION
  Future<void> animateViewModeTransition() async {
    if (!_isInitialized) return;

    await _viewModeTransitionController.reverse();
    await _viewModeTransitionController.forward();
  }

  Future<void> startViewModeTransition() async {
    if (!_isInitialized) return;
    await _viewModeTransitionController.reverse();
  }

  Future<void> completeViewModeTransition() async {
    if (!_isInitialized) return;
    await _viewModeTransitionController.forward();
  }

  // ✅ MÉTODOS DE CONTROL INDIVIDUAL
  void pauseAllAnimations() {
    if (!_isInitialized) return;

    _headerAnimationController.stop();
    _cardsAnimationController.stop();
    _fabAnimationController.stop();
    _viewModeTransitionController.stop();
  }

  void resumeAllAnimations() {
    if (!_isInitialized) return;

    // Solo reanudar si no están completas
    if (_headerAnimationController.status == AnimationStatus.forward) {
      _headerAnimationController.forward();
    }
    if (_cardsAnimationController.status == AnimationStatus.forward) {
      _cardsAnimationController.forward();
    }
    if (_fabAnimationController.status == AnimationStatus.forward) {
      _fabAnimationController.forward();
    }
    if (_viewModeTransitionController.status == AnimationStatus.forward) {
      _viewModeTransitionController.forward();
    }
  }

  // ✅ HELPERS PARA ENTRADA Y SALIDA
  Future<void> animateOut() async {
    if (!_isInitialized) return;

    await Future.wait([
      _fabAnimationController.reverse(),
      _cardsAnimationController.reverse(),
      _headerAnimationController.reverse(),
    ]);
  }

  Future<void> animateIn() async {
    if (!_isInitialized) return;
    startAnimations();
  }

  // ====================================================================
  // 🎯 MÉTODOS DE ESTADO
  // ====================================================================

  bool get isAnimating {
    if (!_isInitialized) return false;

    return _headerAnimationController.isAnimating ||
           _cardsAnimationController.isAnimating ||
           _fabAnimationController.isAnimating ||
           _viewModeTransitionController.isAnimating;
  }

  bool get isCompleted {
    if (!_isInitialized) return false;

    return _headerAnimationController.isCompleted &&
           _cardsAnimationController.isCompleted &&
           _fabAnimationController.isCompleted &&
           _viewModeTransitionController.isCompleted;
  }

  // ====================================================================
  // 🗑️ CLEANUP
  // ====================================================================

  @override
  void dispose() {
    if (_isInitialized) {
      _headerAnimationController.dispose();
      _cardsAnimationController.dispose();
      _fabAnimationController.dispose();
      _viewModeTransitionController.dispose();
    }
    super.dispose();
  }
}