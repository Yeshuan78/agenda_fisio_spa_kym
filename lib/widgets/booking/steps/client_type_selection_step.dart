// [client_type_selection_step.dart] - ✅ FIX: Botones más bajos y anchos
// 📁 Ubicación: /lib/widgets/booking/steps/client_type_selection_step.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/booking/components/booking_step_header.dart';

class ClientTypeSelectionStep extends StatelessWidget {
  final Color accentColor;
  final Function(bool isExisting) onClientTypeSelected;

  const ClientTypeSelectionStep({
    super.key,
    required this.accentColor,
    required this.onClientTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: kSombraCard,
      ),
      child: Column(
        children: [
          BookingStepHeader(
            icon: Icons.person_search,
            title: '¿Eres cliente registrado?',
            subtitle: 'Esto nos ayudará a agilizar tu reserva',
            accentColor: accentColor,
          ),
          const SizedBox(height: 32),

          // ✅ BOTONES ANCHOS Y BAJOS
          _buildOptionButton(
            context: context,
            icon: Icons.check_circle_outline,
            title: 'Sí, soy cliente',
            subtitle: 'Usar mi teléfono registrado',
            color: kAccentGreen,
            onTap: () => onClientTypeSelected(true),
          ),
          const SizedBox(height: 16), // ✅ PADDING ENTRE BOTONES
          _buildOptionButton(
            context: context,
            icon: Icons.person_add_outlined,
            title: 'Cliente nuevo',
            subtitle: 'Agregar datos',
            color: kAccentBlue,
            onTap: () => onClientTypeSelected(false),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // ✅ ANCHO COMPLETO
        height: 70, // ✅ ALTURA BAJA FIJA
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: kTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
