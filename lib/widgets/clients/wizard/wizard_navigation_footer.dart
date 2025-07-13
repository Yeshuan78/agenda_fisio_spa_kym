// [wizard_navigation_footer.dart] - FOOTER CON BOTONES DE NAVEGACIÓN HÍBRIDOS
// 📁 Ubicación: /lib/widgets/clients/wizard/wizard_navigation_footer.dart
// 🎯 OBJETIVO: Footer fijo 80px con botones adaptativos según modo de servicio
// ✅ FIX: Labels dinámicos según ClientServiceMode + MODO AMBOS

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/wizard_controller.dart';
import 'package:agenda_fisio_spa_kym/models/company/company_settings_model.dart';

/// 🎮 FOOTER DE NAVEGACIÓN CON BOTONES HÍBRIDOS INTELIGENTES
/// Altura fija: 80px | Botones adaptativos | Labels dinámicos según modo
class WizardNavigationFooter extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onFinish;

  const WizardNavigationFooter({
    super.key,
    this.onCancel,
    this.onPrevious,
    this.onNext,
    this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<WizardController>(
      builder: (context, wizard, child) {
        return Container(
          height: 80,
          decoration: _buildFooterDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              _buildCancelButton(wizard),
              const Spacer(),
              _buildNavigationButtons(wizard),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCancelButton(WizardController wizard) {
    return TextButton.icon(
      onPressed: wizard.isNavigating ? null : onCancel,
      icon: Icon(
        Icons.close,
        size: 18,
        color: wizard.isNavigating ? Colors.grey : kTextSecondary,
      ),
      label: Text(
        'Cancelar',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: wizard.isNavigating ? Colors.grey : kTextSecondary,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: kTextSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(WizardController wizard) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón Anterior (solo visible después del paso 1)
        if (!wizard.isFirstStep) ...[
          _buildPreviousButton(wizard),
          const SizedBox(width: 12),
        ],

        // Botón Siguiente o Finalizar
        if (wizard.isLastStep)
          _buildFinishButton(wizard)
        else
          _buildNextButton(wizard),
      ],
    );
  }

  Widget _buildPreviousButton(WizardController wizard) {
    return OutlinedButton.icon(
      onPressed: wizard.canGoPrevious ? onPrevious : null,
      icon: Icon(
        Icons.arrow_back,
        size: 18,
        color: wizard.canGoPrevious ? kBrandPurple : Colors.grey,
      ),
      label: Text(
        'Anterior',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: wizard.canGoPrevious ? kBrandPurple : Colors.grey,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: kAccentBlue,
        side: BorderSide(
          color: wizard.canGoPrevious
              ? kBrandPurple.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildNextButton(WizardController wizard) {
    final canProceed = wizard.canGoNext && !wizard.isNavigating;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: canProceed
            ? [
                BoxShadow(
                  color: kAccentBlue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: canProceed ? onNext : null,
        icon: wizard.isNavigating
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    canProceed ? Colors.white : Colors.grey,
                  ),
                ),
              )
            : Icon(
                Icons.arrow_forward,
                size: 18,
                color: canProceed ? Colors.white : Colors.grey,
              ),
        label: Text(
          wizard.isNavigating ? 'Validando...' : 'Siguiente',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: canProceed ? Colors.white : Colors.grey,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: canProceed ? kAccentBlue : Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: canProceed ? 3 : 0,
          shadowColor: kAccentBlue.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishButton(WizardController wizard) {
    final canFinish = wizard.canFinish && !wizard.isNavigating;

    // ✅ OBTENER MODO DE SERVICIO ACTUAL
    final serviceMode = wizard.currentServiceMode;

    // ✅ LABELS DINÁMICOS SEGÚN MODO DE SERVICIO + AMBOS
    final String finishLabel = _getFinishLabel(wizard, serviceMode);
    final IconData finishIcon = _getFinishIcon(wizard, serviceMode);
    final Color buttonColor = _getFinishColor(serviceMode);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: canFinish
            ? [
                BoxShadow(
                  color: buttonColor.withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: canFinish ? onFinish : null,
        icon: wizard.isNavigating
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    canFinish ? Colors.white : Colors.grey,
                  ),
                ),
              )
            : Icon(
                finishIcon,
                size: 18,
                color: canFinish ? Colors.white : Colors.grey,
              ),
        label: Text(
          wizard.isNavigating ? 'Guardando...' : finishLabel,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: canFinish ? Colors.white : Colors.grey,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: canFinish ? buttonColor : Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: canFinish ? 4 : 0,
          shadowColor: buttonColor.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  /// ✅ OBTENER LABEL DINÁMICO SEGÚN MODO DE SERVICIO + AMBOS
  String _getFinishLabel(
      WizardController wizard, ClientServiceMode serviceMode) {
    if (wizard.isEditMode) {
      return 'Actualizar Cliente';
    }

    switch (serviceMode) {
      case ClientServiceMode.sucursal:
        return 'Crear Cliente'; // 🏢 Modo tradicional
      case ClientServiceMode.domicilio:
        return 'Crear Cliente a Domicilio'; // 🏠 Modo domicilio
      case ClientServiceMode.ambos: // ✅ NUEVO
        return 'Crear Cliente Híbrido'; // ✅ NUEVO
    }
  }

  /// ✅ OBTENER ICONO DINÁMICO SEGÚN MODO DE SERVICIO + AMBOS
  IconData _getFinishIcon(
      WizardController wizard, ClientServiceMode serviceMode) {
    if (wizard.isEditMode) {
      return Icons.save;
    }

    switch (serviceMode) {
      case ClientServiceMode.sucursal:
        return Icons.person_add; // 🏢 Cliente tradicional
      case ClientServiceMode.domicilio:
        return Icons.home_work; // 🏠 Cliente a domicilio
      case ClientServiceMode.ambos: // ✅ NUEVO
        return Icons.swap_horiz; // ✅ NUEVO
    }
  }

  /// ✅ OBTENER COLOR DINÁMICO SEGÚN MODO DE SERVICIO + AMBOS
  Color _getFinishColor(ClientServiceMode serviceMode) {
    switch (serviceMode) {
      case ClientServiceMode.sucursal:
        return kAccentBlue; // 🏢 Azul para sucursal
      case ClientServiceMode.domicilio:
        return kAccentGreen; // 🏠 Verde para domicilio
      case ClientServiceMode.ambos: // ✅ NUEVO
        return kBrandPurple; // 🔄 Morado para híbrido // ✅ NUEVO
    }
  }

  Widget _buildValidationIndicator(WizardController wizard) {
    if (!wizard.hasStepErrors) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber,
            size: 16,
            color: Colors.orange.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            '${wizard.currentStepErrors.length} error${wizard.currentStepErrors.length == 1 ? '' : 'es'}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildFooterDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.white.withValues(alpha: 0.09),
          kAccentBlue.withValues(alpha: 0.05),
          kAccentBlue.withValues(alpha: 0.03),
        ],
      ),
      border: Border(
        top: BorderSide(
          color: kBorderSoft,
          width: 1,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    );
  }
}

/// 🎯 WIDGET HELPER PARA BOTONES CON LOADING HÍBRIDO
class _LoadingButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final bool isPrimary;

  const _LoadingButton({
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor = kBrandPurple,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    Widget buttonIcon = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isEnabled ? Colors.white : Colors.grey,
              ),
            ),
          )
        : Icon(
            icon,
            size: 18,
            color: isEnabled ? Colors.white : Colors.grey,
          );

    Widget buttonChild = isPrimary
        ? ElevatedButton.icon(
            onPressed: isEnabled ? onPressed : null,
            icon: buttonIcon,
            label: Text(
              isLoading ? 'Procesando...' : text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isEnabled ? Colors.white : Colors.grey,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isEnabled ? backgroundColor : Colors.grey.shade300,
              elevation: isEnabled ? 3 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: isEnabled ? onPressed : null,
            icon: buttonIcon,
            label: Text(
              isLoading ? 'Procesando...' : text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isEnabled ? backgroundColor : Colors.grey,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: backgroundColor,
              side: BorderSide(
                color: isEnabled
                    ? backgroundColor.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.3),
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

    return isEnabled && isPrimary
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: buttonChild,
          )
        : buttonChild;
  }
}
