// [breadcrumb_widget.dart] - BREADCRUMB EXTRAÍDO
// 📁 Ubicación: /lib/widgets/layout/components/breadcrumb_widget.dart
// 🎯 WIDGET BREADCRUMB DE NAVEGACIÓN

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/widgets/layout/models/route_helper.dart';
import 'package:agenda_fisio_spa_kym/widgets/layout/components/route_badge_widget.dart';

class BreadcrumbWidget extends StatelessWidget {
  final String currentRoute;
  
  const BreadcrumbWidget({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final routeParts = currentRoute.split('/').where((p) => p.isNotEmpty).toList();

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: RouteHelper.getGradientColors(currentRoute),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            RouteHelper.getIcon(currentRoute),
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      RouteHelper.getTitle(currentRoute),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (currentRoute == '/agenda/premium')
                    RouteBadgeWidget(text: 'PREMIUM', color: Colors.orange.shade600),
                  if (currentRoute == '/agenda/semanal')
                    RouteBadgeWidget(text: 'LEGACY', color: Colors.grey.shade500),
                ],
              ),
              if (routeParts.length > 1) ...[
                const SizedBox(height: 2),
                Text(
                  routeParts.map(RouteHelper.capitalizeFirst).join(' › '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}