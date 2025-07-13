// [quick_actions_row.dart] - ACCIONES RÁPIDAS EXTRAÍDAS
// 📁 Ubicación: /lib/widgets/layout/components/quick_actions_row.dart
// 🎯 WIDGET ROW DE ACCIONES RÁPIDAS

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/layout/components/user_avatar_widget.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onSearchPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onSettingsPressed;
  final int notificationCount;
  
  const QuickActionsRow({
    super.key,
    required this.onSearchPressed,
    required this.onNotificationsPressed,
    required this.onSettingsPressed,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQuickAction(
          Icons.search,
          'Búsqueda Global (⌘K)',
          onSearchPressed,
          isSpecial: true,
        ),
        const SizedBox(width: 16),
        _buildQuickAction(
          Icons.notifications_outlined,
          'Centro de Notificaciones',
          onNotificationsPressed,
          badge: notificationCount,
        ),
        const SizedBox(width: 16),
        _buildQuickAction(
          Icons.settings_outlined,
          'Configuración',
          onSettingsPressed,
        ),
        const SizedBox(width: 24),
        const UserAvatarWidget(),
      ],
    );
  }

  Widget _buildQuickAction(
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    int? badge,
    bool isSpecial = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: isSpecial
                  ? const LinearGradient(colors: [kBrandPurple, kAccentBlue])
                  : null,
              color: isSpecial ? null : kBrandPurple.withValues(alpha: 0.005),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSpecial
                    ? Colors.transparent
                    : kBrandPurple.withValues(alpha: 0.01),
                width: 1,
              ),
              boxShadow: isSpecial
                  ? [
                      BoxShadow(
                        color: kBrandPurple.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    color: isSpecial ? Colors.white : kBrandPurple,
                    size: 20,
                  ),
                ),
                if (badge != null && badge > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Colors.red, Colors.redAccent]),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          badge > 9 ? '9+' : '$badge',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}