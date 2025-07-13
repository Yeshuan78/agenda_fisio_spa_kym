// [wizard_step_content.dart] - CONTENEDOR DE PASOS CON TRANSICIONES - SIN SCROLL
// 📁 Ubicación: /lib/widgets/clients/wizard/wizard_step_content.dart
// 🎯 OBJETIVO: Contenedor que maneja las transiciones entre los 3 pasos del wizard SIN SCROLL

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/wizard_controller.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/steps/personal_info_step.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/steps/address_info_step.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/steps/tags_summary_step.dart';

/// 📦 CONTENEDOR DE PASOS CON TRANSICIONES ANIMADAS - SIN SCROLL
/// Maneja el cambio entre los 3 pasos del wizard con animaciones suaves
class WizardStepContent extends StatefulWidget {
  const WizardStepContent({super.key});

  @override
  State<WizardStepContent> createState() => _WizardStepContentState();
}

class _WizardStepContentState extends State<WizardStepContent>
    with TickerProviderStateMixin {
  // ✅ CONTROLADOR DE TRANSICIONES
  late AnimationController _transitionController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _lastStep = 0;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  Future<void> _handleStepChange(int newStep) async {
    if (_isTransitioning || newStep == _lastStep) return;

    setState(() {
      _isTransitioning = true;
    });

    // Determinar dirección de la transición
    final isMovingForward = newStep > _lastStep;

    // Configurar animación de salida
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(isMovingForward ? -1.0 : 1.0, 0),
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    // Ejecutar transición de salida
    await _transitionController.forward();

    // Cambiar el paso
    setState(() {
      _lastStep = newStep;
    });

    // Configurar animación de entrada
    _slideAnimation = Tween<Offset>(
      begin: Offset(isMovingForward ? 1.0 : -1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));

    // Reset y ejecutar transición de entrada
    _transitionController.reset();
    await _transitionController.forward();

    setState(() {
      _isTransitioning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WizardController>(
      builder: (context, wizard, child) {
        // Detectar cambio de paso y animar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && wizard.currentStep != _lastStep) {
            _handleStepChange(wizard.currentStep);
          }
        });

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _buildContentDecoration(),
          child: _buildStepContent(wizard),
        );
      },
    );
  }

  Widget _buildStepContent(WizardController wizard) {
    return AnimatedBuilder(
      animation: _transitionController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildCurrentStep(wizard),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStep(WizardController wizard) {
    // Si está en transición, mostrar el paso anterior hasta que termine
    final stepToShow = _isTransitioning ? _lastStep : wizard.currentStep;

    return Column(
      children: [
        // ✅ BANNER ULTRA COMPACTO SOLO SI HAY ERRORES Y EL USUARIO YA INTENTÓ AVANZAR
        if (wizard.hasStepErrors) ...[
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: _buildErrorIndicator(wizard),
          ),
        ],

        // ✅ CONTENIDO DEL PASO ACTUAL - EXPANDED PARA LLENAR ESPACIO DISPONIBLE
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _getStepWidget(stepToShow, wizard),
          ),
        ),
      ],
    );
  }

  /// ✅ BANNER ULTRA COMPACTO - FIX APLICADO
  Widget _buildErrorIndicator(WizardController wizard) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // ✅ ULTRA REDUCIDO
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08), // ✅ MÁS SUTIL
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 14, // ✅ ICONO PEQUEÑO
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Revisa los campos por llenar', // ✅ TEXTO ULTRA SIMPLE
              style: TextStyle(
                fontSize: 11, // ✅ FUENTE PEQUEÑA
                fontWeight: FontWeight.w500,
                color: Colors.red.shade700,
              ),
              maxLines: 1, // ✅ UNA SOLA LÍNEA
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // ✅ CONTADOR COMPACTO
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${wizard.currentStepErrors.length}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStepWidget(int stepIndex, WizardController wizard) {
    // ✅ CADA STEP WIDGET DEBE MANEJAR SU PROPIO LAYOUT SIN SCROLL
    switch (stepIndex) {
      case 0: // Paso 1: Información Personal
        return PersonalInfoStep(
          formController: wizard.formController,
          key: const ValueKey('personal_info_step'),
        );

      case 1: // Paso 2: Dirección
        return AddressInfoStep(
          formController: wizard.formController,
          key: const ValueKey('address_info_step'),
        );

      case 2: // Paso 3: Etiquetas y Confirmación
        return TagsSummaryStep(
          formController: wizard.formController,
          isEditMode: wizard.isEditMode,
          key: const ValueKey('tags_summary_step'),
        );

      default:
        return _buildErrorStep();
    }
  }

  Widget _buildErrorStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // ✅ TAMAÑO MÍNIMO
        children: [
          Icon(
            Icons.error_outline,
            size: 48, // ✅ TAMAÑO REDUCIDO
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Error: Paso no encontrado',
            style: TextStyle(
              fontSize: 16, // ✅ FUENTE REDUCIDA
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Por favor, reinicie el proceso',
            style: TextStyle(
              fontSize: 12, // ✅ FUENTE REDUCIDA
              color: kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildContentDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.02),
          kBrandPurple.withValues(alpha: 0.01),
        ],
      ),
    );
  }

  // ========================================================================
  // 📊 MÉTODOS DE DEBUG
  // ========================================================================

  void _logTransitionState() {
    debugPrint('📊 WizardStepContent Transition:');
    debugPrint('   lastStep: $_lastStep');
    debugPrint('   isTransitioning: $_isTransitioning');
    debugPrint('   animationValue: ${_transitionController.value}');
  }
}
