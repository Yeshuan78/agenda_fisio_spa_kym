// [client_wizard_modal.dart] - MODAL ALTURA CORREGIDA - 700px COMPLETO
// 📁 Ubicación: /lib/widgets/clients/wizard/client_wizard_modal.dart
// 🎯 OBJETIVO: Modal con altura suficiente para evitar overflows - AUMENTADO 50px
// ✅ FIX: 650px → 700px para elementos interactivos - CÓDIGO COMPLETO

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/clients/client_model.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/wizard_controller.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/wizard_step_header.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/wizard_step_content.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/wizard_navigation_footer.dart';
import 'package:agenda_fisio_spa_kym/services/company/company_settings_service.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';

/// 🏢 MODAL WIZARD ENTERPRISE CON ALTURA CORREGIDA PARA CREAR/EDITAR CLIENTES
/// Modal centrado 800px × 700px con 3 pasos: Personal → Dirección → Tags+Confirmación
class ClientWizardModal extends StatefulWidget {
  final ClientModel? existingClient;
  final VoidCallback? onClientSaved;
  final VoidCallback? onCancelled;

  const ClientWizardModal({
    super.key,
    this.existingClient,
    this.onClientSaved,
    this.onCancelled,
  });

  @override
  State<ClientWizardModal> createState() => _ClientWizardModalState();
}

class _ClientWizardModalState extends State<ClientWizardModal>
    with TickerProviderStateMixin {
  // ✅ CONTROLADORES DE ANIMACIÓN
  late AnimationController _overlayController;
  late AnimationController _modalController;
  late AnimationController _contentController;

  late Animation<double> _overlayAnimation;
  late Animation<double> _modalScaleAnimation;
  late Animation<Offset> _modalSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  // ✅ CONTROLADOR DEL WIZARD
  late WizardController _wizardController;
  bool _isInitialized = false;
  bool _isClosing = false;

  // ✅ CONFIGURACIÓN DEL MODAL CON ALTURA CORREGIDA
  static const double modalWidth = 800.0;
  static const double modalHeight = 720.0; // ✅ AUMENTADO: 650 → 700 (+50px)
  static const double borderRadius = 20.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeWizardController();

    // ✅ PLAN FASE 5: Cargar configuración simple
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanyConfiguration();
    });

    _startEntryAnimations();
  }

  /// ✅ PLAN FASE 5: CARGAR CONFIGURACIÓN SEGÚN EL PLAN
  Future<void> _loadCompanyConfiguration() async {
    try {
      final settingsService = CompanySettingsService();
      await settingsService.initialize();
      final settings = settingsService.currentSettings;
      _wizardController.setDefaultServiceMode(settings);
      debugPrint('✅ Configuración cargada: ${settings.businessType.label}');
    } catch (e) {
      debugPrint('⚠️ Error cargando configuración: $e');
      // Continuar con configuración por defecto
    }
  }

  void _initializeAnimations() {
    // Overlay fade in/out
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 250), // ✅ REDUCIDO: 300 → 250
      vsync: this,
    );
    _overlayAnimation = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeOut,
    );

    // Modal scale + slide
    _modalController = AnimationController(
      duration: const Duration(milliseconds: 350), // ✅ REDUCIDO: 400 → 350
      vsync: this,
    );
    _modalScaleAnimation = Tween<double>(
      begin: 0.85, // ✅ REDUCIDO: 0.8 → 0.85
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _modalController,
      curve: Curves.easeOutCubic,
    ));
    _modalSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08), // ✅ REDUCIDO: 0.1 → 0.08
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _modalController,
      curve: Curves.easeOutCubic,
    ));

    // Content fade in
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 250), // ✅ REDUCIDO: 300 → 250
      vsync: this,
    );
    _contentFadeAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
  }

  void _initializeWizardController() {
    _wizardController = WizardController(existingClient: widget.existingClient);

    // Esperar a que el controller esté listo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _wizardController.isInitialized) {
        setState(() {
          _isInitialized = true;
        });
        _contentController.forward();
      }
    });
  }

  void _startEntryAnimations() {
    _overlayController.forward();

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        _modalController.forward();
      }
    });
  }

  Future<void> _startExitAnimations() async {
    if (_isClosing) return;
    _isClosing = true;

    await Future.wait([
      _contentController.reverse(),
      _modalController.reverse(),
    ]);

    await _overlayController.reverse();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _modalController.dispose();
    _contentController.dispose();
    _wizardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _wizardController,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            _handleBackPress();
          }
        },
        child: _buildModalScaffold(),
      ),
    );
  }

  Widget _buildModalScaffold() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _overlayAnimation,
        builder: (context, child) {
          return Container(
            color: Colors.black.withValues(
                alpha:
                    0.65 * _overlayAnimation.value), // ✅ REDUCIDO: 0.7 → 0.65
            child: Center(
              child: _buildResponsiveModal(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveModal() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: 90% en móvil, tamaño fijo en desktop
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        final effectiveWidth =
            screenWidth > 900 ? modalWidth : screenWidth * 0.9;

        // ✅ ALTURA RESPONSIVE CON NUEVA ALTURA MÍNIMA
        final effectiveHeight = screenHeight > 800 // ✅ AJUSTADO: 750 → 800
            ? modalHeight // ✅ NUEVA ALTURA: 700px
            : screenHeight * 0.85;

        return AnimatedBuilder(
          animation: _modalController,
          builder: (context, child) {
            return Transform.scale(
              scale: _modalScaleAnimation.value,
              child: Transform.translate(
                offset: _modalSlideAnimation.value * 40, // ✅ REDUCIDO: 50 → 40
                child: Container(
                  width: effectiveWidth,
                  height: effectiveHeight,
                  child: _buildModalContent(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalContent() {
    if (!_isInitialized) {
      return _buildLoadingModal();
    }

    return Container(
      decoration: _buildGlassmorphismDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Column(
          children: [
            // ✅ HEADER COMPACTO: 65px (reducido de 80px)
            const SizedBox(
              height: 65, // ✅ REDUCIDO: 80 → 65
              child: WizardStepHeader(),
            ),

            // ✅ CONTENT: Expandido (~555px ahora vs ~505px antes = +50px)
            Expanded(
              child: AnimatedBuilder(
                animation: _contentFadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _contentFadeAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, // ✅ REDUCIDO: 24 → 20
                        vertical: 12, // ✅ REDUCIDO: 16 → 12
                      ),
                      child: const WizardStepContent(),
                    ),
                  );
                },
              ),
            ),

            // ✅ FOOTER COMPACTO: 65px (reducido de 80px)
            SizedBox(
              height: 65, // ✅ REDUCIDO: 80 → 65
              child: WizardNavigationFooter(
                onCancel: _handleCancel,
                onPrevious: _handlePrevious,
                onNext: _handleNext,
                onFinish: _handleFinish,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingModal() {
    return Container(
      decoration: _buildGlassmorphismDecoration(),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
              strokeWidth: 3,
            ),
            SizedBox(height: 20), // ✅ REDUCIDO: 24 → 20
            Text(
              'Inicializando formulario...',
              style: TextStyle(
                fontSize: 15, // ✅ REDUCIDO: 16 → 15
                fontWeight: FontWeight.w500,
                color: kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ REFACTOR: GLASSMORPHISM OPTIMIZADO
  BoxDecoration _buildGlassmorphismDecoration() {
    return BoxDecoration(
      // Gradiente glassmorphism multicapa optimizado
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.93), // ✅ REDUCIDO: 0.95 → 0.93
          Colors.white.withValues(alpha: 0.83), // ✅ REDUCIDO: 0.85 → 0.83
          kAccentBlue.withValues(alpha: 0.04), // ✅ REDUCIDO: 0.05 → 0.04
          kAccentBlue.withValues(alpha: 0.03), // ✅ REDUCIDO: 0.04 → 0.03
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ),

      borderRadius: BorderRadius.circular(borderRadius),

      // Borde glassmorphism
      border: Border.all(
        color: kAccentBlue.withValues(alpha: 0.18), // ✅ REDUCIDO: 0.2 → 0.18
        width: 1.5, // ✅ REDUCIDO: 2 → 1.5
      ),

      // Sombras multicapa profesionales optimizadas
      boxShadow: [
        // Sombra principal coloreada
        BoxShadow(
          color: kAccentBlue.withValues(alpha: 0.15), // ✅ REDUCIDO: 0.2 → 0.15
          blurRadius: 25, // ✅ REDUCIDO: 30 → 25
          spreadRadius: 3, // ✅ REDUCIDO: 5 → 3
          offset: const Offset(0, 12), // ✅ REDUCIDO: (0, 15) → (0, 12)
        ),
        // Sombra interna glassmorphism
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.75), // ✅ REDUCIDO: 0.8 → 0.75
          blurRadius: 16, // ✅ REDUCIDO: 20 → 16
          spreadRadius: -6, // ✅ REDUCIDO: -8 → -6
          offset: const Offset(0, -6), // ✅ REDUCIDO: (0, -8) → (0, -6)
        ),
        // Sombra de profundidad
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08), // ✅ REDUCIDO: 0.1 → 0.08
          blurRadius: 40, // ✅ REDUCIDO: 50 → 40
          spreadRadius: 0,
          offset: const Offset(0, 20), // ✅ REDUCIDO: (0, 25) → (0, 20)
        ),
        // Sombra secundaria azul
        BoxShadow(
          color: kAccentBlue.withValues(alpha: 0.08), // ✅ REDUCIDO: 0.1 → 0.08
          blurRadius: 32, // ✅ REDUCIDO: 40 → 32
          spreadRadius: 1, // ✅ REDUCIDO: 2 → 1
          offset: const Offset(4, 16), // ✅ REDUCIDO: (5, 20) → (4, 16)
        ),
      ],
    );
  }

  // ========================================================================
  // 🎮 MANEJADORES DE EVENTOS (SIN CAMBIOS - FUNCIONALIDAD PRESERVADA)
  // ========================================================================

  void _handleBackPress() {
    _handleCancel();
  }

  Future<void> _handleCancel() async {
    // Mostrar confirmación si hay datos sin guardar
    final hasUnsavedData =
        _wizardController.formData.personalInfo.nombre.isNotEmpty ||
            _wizardController.formData.personalInfo.email.isNotEmpty;

    if (hasUnsavedData && !_wizardController.isEditMode) {
      final shouldClose = await _showCancelConfirmation();
      if (!shouldClose) return;
    }

    await _closeModal(cancelled: true);
  }

  Future<void> _handlePrevious() async {
    HapticFeedback.lightImpact();
    await _wizardController.previousStep();
  }

  Future<void> _handleNext() async {
    HapticFeedback.lightImpact();
    await _wizardController.nextStep();
  }

  Future<void> _handleFinish() async {
    try {
      HapticFeedback.mediumImpact();

      // Mostrar loading
      _showLoadingOverlay();

      // Intentar guardar
      final success = await _wizardController.finishWizard();

      // Cerrar loading overlay SIEMPRE
      _hideLoadingOverlay();

      if (success) {
        // Pequeña pausa para que se vea el loading cerrado
        await Future.delayed(const Duration(milliseconds: 100));

        // Éxito: cerrar modal y notificar
        await _closeModal(success: true);
      } else {
        // Error: mostrar mensaje
        _showErrorDialog(
          'Error al Guardar',
          'No se pudo guardar el cliente. Por favor, revise los datos e intente nuevamente.',
        );
      }
    } catch (e) {
      // Asegurar que se cierre el loading overlay
      _hideLoadingOverlay();
      _showErrorDialog(
        'Error Inesperado',
        'Ocurrió un error inesperado: $e',
      );
    }
  }

  Future<void> _closeModal(
      {bool success = false, bool cancelled = false}) async {
    if (_isClosing) return;

    // Marcar como cerrando para evitar múltiples ejecuciones
    _isClosing = true;

    try {
      // Ejecutar animaciones de salida
      await _startExitAnimations();

      if (mounted) {
        // Cerrar el modal
        Navigator.of(context).pop();

        // Ejecutar callbacks después del cierre
        if (success && widget.onClientSaved != null) {
          // Pequeña pausa para que se complete la animación de cierre
          await Future.delayed(const Duration(milliseconds: 100));
          widget.onClientSaved!();
        } else if (cancelled && widget.onCancelled != null) {
          widget.onCancelled!();
        }
      }
    } catch (e) {
      debugPrint('Error cerrando modal: $e');
      // Forzar cierre si hay error
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  // ========================================================================
  // 🎭 DIÁLOGOS Y FEEDBACK COMPACTOS
  // ========================================================================

  Future<bool> _showCancelConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber,
                    color: Colors.orange, size: 20), // ✅ REDUCIDO: → 20
                SizedBox(width: 10), // ✅ REDUCIDO: 12 → 10
                Expanded(
                  // ✅ NUEVO: Evitar overflow
                  child: Text(
                    '¿Cancelar creación?',
                    style: TextStyle(fontSize: 16), // ✅ REDUCIDO: 18 → 16
                  ),
                ),
              ],
            ),
            content: const Text(
              'Hay información sin guardar que se perderá. ¿Está seguro de que desea cancelar?',
              style: TextStyle(fontSize: 14), // ✅ REDUCIDO: 16 → 14
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Continuar Editando'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Sí, Cancelar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20), // ✅ REDUCIDO: 24 → 20
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
                ),
                SizedBox(height: 14), // ✅ REDUCIDO: 16 → 14
                Text(
                  'Guardando cliente...',
                  style: TextStyle(fontSize: 15), // ✅ REDUCIDO: 16 → 15
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hideLoadingOverlay() {
    if (mounted) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (e) {
        // Si no hay overlay que cerrar, continuar silenciosamente
        debugPrint('No hay loading overlay para cerrar');
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error,
                color: Colors.red, size: 20), // ✅ REDUCIDO: → 20
            const SizedBox(width: 10), // ✅ REDUCIDO: 12 → 10
            Expanded(
              // ✅ NUEVO: Evitar overflow
              child: Text(
                title,
                style: const TextStyle(fontSize: 16), // ✅ REDUCIDO: 18 → 16
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14), // ✅ REDUCIDO: 16 → 14
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // 📊 MÉTODOS DE DEBUG (SIN CAMBIOS)
  // ========================================================================

  void _logModalState() {
    debugPrint('📊 ClientWizardModal State:');
    debugPrint('   isInitialized: $_isInitialized');
    debugPrint('   isClosing: $_isClosing');
    debugPrint(
        '   existingClient: ${widget.existingClient?.fullName ?? "null"}');
    if (_isInitialized) {
      _wizardController.logCurrentState();
    }
  }
}

/// 🎯 FUNCIÓN HELPER PARA MOSTRAR EL MODAL (SIN CAMBIOS)
/// Uso: showClientWizardModal(context, existingClient: client)
Future<bool?> showClientWizardModal(
  BuildContext context, {
  ClientModel? existingClient,
  VoidCallback? onClientSaved,
  VoidCallback? onCancelled,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent, // El modal maneja su propio overlay
    builder: (context) => ClientWizardModal(
      existingClient: existingClient,
      onClientSaved: onClientSaved,
      onCancelled: onCancelled,
    ),
  );
}
