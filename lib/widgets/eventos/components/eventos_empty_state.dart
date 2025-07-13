// [eventos_empty_state.dart] - EXTRACCIÓN QUIRÚRGICA EXACTA
// 📁 Ubicación: /lib/widgets/eventos/components/eventos_empty_state.dart
// 🎯 COPY-PASTE EXACTO de líneas 800-900 eventos_screen.dart

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EventosEmptyState extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;
  final VoidCallback onCreateEvento;

  const EventosEmptyState({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onCreateEvento,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: kBrandPurpleLight.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  searchQuery.isNotEmpty || selectedFilter != 'Todos'
                      ? Icons.search_off_rounded
                      : Icons.event_busy_rounded,
                  size: 64,
                  color: kBrandPurple,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                searchQuery.isNotEmpty || selectedFilter != 'Todos'
                    ? 'No se encontraron eventos'
                    : 'No hay eventos registrados',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                searchQuery.isNotEmpty || selectedFilter != 'Todos'
                    ? 'Intenta ajustar los filtros de búsqueda'
                    : 'Crea tu primer evento para comenzar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (searchQuery.isEmpty && selectedFilter == 'Todos')
                ElevatedButton.icon(
                  onPressed: onCreateEvento,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Crear Evento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrandPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}