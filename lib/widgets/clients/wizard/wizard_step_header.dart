// [wizard_step_header.dart] - HEADER COMPACTO 65px CON PROGRESO ANIMADO
// 📁 Ubicación: /lib/widgets/clients/wizard/wizard_step_header.dart
// 🎯 OBJETIVO: Header compacto 65px con progreso, título y botón cerrar optimizado
// ✅ REFACTOR: Altura reducida 80px → 65px, elementos más compactos

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/clients/wizard/wizard_controller.dart';

/// 📊 HEADER COMPACTO DEL WIZARD CON PROGRESO ANIMADO
/// Altura fija: 65px | Progreso visual | Título dinámico | Botón cerrar
class WizardStepHeader extends StatefulWidget {
  const WizardStepHeader({super.key});

  @override
  State<WizardStepHeader> createState() => _WizardStepHeaderState();
}

class _WizardStepHeaderState extends State<WizardStepHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  double _lastProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500), // ✅ REDUCIDO: 600 → 500
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress(double newProgress) {
    if (newProgress != _lastProgress) {
      _progressAnimation = Tween<double>(
        begin: _lastProgress,
        end: newProgress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));

      _progressController.reset();
      _progressController.forward();
      _lastProgress = newProgress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WizardController>(
      builder: (context, wizard, child) {
        // Actualizar progreso cuando cambie
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateProgress(wizard.progress);
          }
        });

        return Container(
          height: 65, // ✅ REDUCIDO: 80 → 65
          decoration: _buildHeaderDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8), // ✅ REDUCIDO: h16,v10 → h14,v8
            child: Row(
              children: [
                _buildCompactStepIndicator(wizard),
                const SizedBox(width: 8), // ✅ REDUCIDO: 10 → 8
                Expanded(child: _buildCompactTitleSection(wizard)),
                const SizedBox(width: 8), // ✅ REDUCIDO: 6 → 8 (equilibrio)
                _buildCompactProgressSection(wizard),
                const SizedBox(width: 8), // ✅ REDUCIDO: 6 → 8
                _buildCompactCloseButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ REFACTOR: INDICADOR DE PASO COMPACTO
  Widget _buildCompactStepIndicator(WizardController wizard) {
    return Container(
      width: 24, // ✅ REDUCIDO: 28 → 24
      height: 24, // ✅ REDUCIDO: 28 → 24
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.18), // ✅ REDUCIDO: 0.2 → 0.18
            kBrandPurple.withValues(alpha: 0.08), // ✅ REDUCIDO: 0.1 → 0.08
          ],
        ),
        borderRadius: BorderRadius.circular(5), // ✅ REDUCIDO: 6 → 5
        border: Border.all(
          color: kBrandPurple.withValues(alpha: 0.25), // ✅ REDUCIDO: 0.3 → 0.25
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '${wizard.stepNumber}',
          style: const TextStyle(
            fontSize: 11, // ✅ REDUCIDO: 12 → 11
            fontWeight: FontWeight.bold,
            color: kBrandPurple,
          ),
        ),
      ),
    );
  }

  /// ✅ REFACTOR: SECCIÓN DE TÍTULO COMPACTA
  Widget _buildCompactTitleSection(WizardController wizard) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1), // ✅ REDUCIDO: 2 → 1
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            wizard.currentStepTitle,
            style: const TextStyle(
              fontSize: 14, // ✅ REDUCIDO: 15 → 14
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1), // ✅ REDUCIDO: mínimo spacing
          Text(
            wizard.currentStepSubtitle,
            style: TextStyle(
              fontSize: 10, // ✅ REDUCIDO: 11 → 10
              color: kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// ✅ REFACTOR: SECCIÓN DE PROGRESO COMPACTA
  Widget _buildCompactProgressSection(WizardController wizard) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ CONTADOR DE PASOS COMPACTO
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 5, vertical: 2), // ✅ REDUCIDO: 6,2 → 5,2
          decoration: BoxDecoration(
            color:
                kBrandPurple.withValues(alpha: 0.08), // ✅ REDUCIDO: 0.1 → 0.08
            borderRadius: BorderRadius.circular(6), // ✅ REDUCIDO: 8 → 6
            border: Border.all(
              color: kBrandPurple.withValues(
                  alpha: 0.25), // ✅ REDUCIDO: 0.3 → 0.25
              width: 1,
            ),
          ),
          child: Text(
            '${wizard.stepNumber}/${WizardController.totalSteps}',
            style: const TextStyle(
              fontSize: 11, // ✅ REDUCIDO: 12 → 11
              fontWeight: FontWeight.w700,
              color: kBrandPurple,
              letterSpacing: 0.2,
            ),
          ),
        ),

        const SizedBox(width: 8), // ✅ REDUCIDO: 10 → 8

        // ✅ BARRA DE PROGRESO COMPACTA
        Container(
          width: 45, // ✅ REDUCIDO: 50 → 45
          height: 3, // ✅ REDUCIDO: 4 → 3
          decoration: BoxDecoration(
            color:
                kBrandPurple.withValues(alpha: 0.08), // ✅ REDUCIDO: 0.1 → 0.08
            borderRadius: BorderRadius.circular(1.5),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kBrandPurple, kAccentBlue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 5), // ✅ REDUCIDO: 6 → 5

        // ✅ PORCENTAJE COMPACTO
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            final percentage = (_progressAnimation.value * 100).round();
            return Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 10, // ✅ REDUCIDO: 11 → 10
                fontWeight: FontWeight.w700,
                color: kBrandPurple,
                letterSpacing: 0.1,
              ),
            );
          },
        ),
      ],
    );
  }

  /// ✅ REFACTOR: BOTÓN CERRAR COMPACTO
  Widget _buildCompactCloseButton() {
    return Container(
      width: 22, // ✅ REDUCIDO: 24 → 22
      height: 22, // ✅ REDUCIDO: 24 → 22
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08), // ✅ REDUCIDO: 0.1 → 0.08
        borderRadius: BorderRadius.circular(3), // ✅ REDUCIDO: 4 → 3
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.18), // ✅ REDUCIDO: 0.2 → 0.18
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(3),
          child: Icon(
            Icons.close,
            color: kTextSecondary,
            size: 12, // ✅ REDUCIDO: 14 → 12
          ),
        ),
      ),
    );
  }

  /// ✅ REFACTOR: DECORACIÓN HEADER OPTIMIZADA
  BoxDecoration _buildHeaderDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.88), // ✅ REDUCIDO: 0.9 → 0.88
          Colors.white.withValues(alpha: 0.68), // ✅ REDUCIDO: 0.7 → 0.68
          kAccentBlue.withValues(alpha: 0.025), // ✅ REDUCIDO: 0.03 → 0.025
        ],
      ),
      border: Border(
        bottom: BorderSide(
          color: kBorderSoft.withValues(alpha: 0.8), // ✅ MEJORADO CONTRASTE
          width: 1,
        ),
      ),
    );
  }
}
