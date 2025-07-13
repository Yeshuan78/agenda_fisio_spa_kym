// [Archivo: lib/widgets/custom_app_bar.dart]
import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class CustomAppBar extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showLogo;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        // ✅ GRADIENTE PREMIUM DEL THEME
        gradient: kHeaderGradient,
        // ✅ SOMBRA PREMIUM DEL THEME
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.02),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // ✅ LOGO PREMIUM
            if (showLogo) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.03),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
            ],

            // ✅ TÍTULO O INFORMACIÓN
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title ?? 'Fisio Spa KYM',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: kFontFamily,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (title != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Sistema de gestión profesional',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.08),
                        fontFamily: kFontFamily,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ✅ ACCIONES PERSONALIZADAS
            if (actions != null) ...actions!,

            // ✅ ACCIONES POR DEFECTO
            if (actions == null) ...[
              // Notificaciones
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.01),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Implementar notificaciones
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificaciones - Próximamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  tooltip: 'Notificaciones',
                ),
              ),

              const SizedBox(width: 8),

              // Configuración
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.01),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Implementar configuración rápida
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuración rápida - Próximamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  tooltip: 'Configuración',
                ),
              ),

              const SizedBox(width: 8),

              // Perfil de usuario
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.03),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
