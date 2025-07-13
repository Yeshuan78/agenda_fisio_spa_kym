// [user_avatar_widget.dart] - AVATAR DE USUARIO EXTRAÍDO
// 📁 Ubicación: /lib/widgets/layout/components/user_avatar_widget.dart
// 🎯 WIDGET AVATAR DE USUARIO

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kBrandPurple, kAccentBlue]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 24),
    );
  }
}