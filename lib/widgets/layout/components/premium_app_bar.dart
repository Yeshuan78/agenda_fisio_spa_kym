// [premium_app_bar.dart] - APPBAR PREMIUM EXTRAÍDO
// 📁 Ubicación: /lib/widgets/layout/components/premium_app_bar.dart
// 🎯 WIDGET APPBAR PREMIUM

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/layout/components/breadcrumb_widget.dart';

class PremiumAppBar extends StatelessWidget {
  final String currentRoute;
  final Widget quickActionsRow;
  
  const PremiumAppBar({
    super.key,
    required this.currentRoute,
    required this.quickActionsRow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: kBorderColor.withValues(alpha: 0.01),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.003),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(child: BreadcrumbWidget(currentRoute: currentRoute)),
            quickActionsRow,
          ],
        ),
      ),
    );
  }
}