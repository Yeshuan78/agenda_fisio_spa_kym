// [evento_asignaciones_section.dart] - SECCIÓN PREMIUM DE ASIGNACIONES
// 📁 Ubicación: /lib/widgets/eventos/components/evento_asignaciones_section.dart
// 🎯 OBJETIVO: Componente premium que mantiene EXACTA la lógica del archivo original

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class EventoAsignacionesSection extends StatefulWidget {
  // ✅ MANTENER CONEXIONES FIRESTORE REALES DEL ARCHIVO ORIGINAL
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> servicios;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> profesionales;
  final List<Map<String, dynamic>> asignaciones;
  final String horarioEventoInicio;
  final String horarioEventoFin;
  final VoidCallback onAddAsignacion;
  final Function(int index) onRemoveAsignacion;
  final Function(int index, String field, dynamic value) onUpdateAsignacion;

  const EventoAsignacionesSection({
    super.key,
    required this.servicios,
    required this.profesionales,
    required this.asignaciones,
    required this.horarioEventoInicio,
    required this.horarioEventoFin,
    required this.onAddAsignacion,
    required this.onRemoveAsignacion,
    required this.onUpdateAsignacion,
  });

  @override
  State<EventoAsignacionesSection> createState() =>
      _EventoAsignacionesSectionState();
}

class _EventoAsignacionesSectionState extends State<EventoAsignacionesSection>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _addController;
  late Animation<double> _headerAnimation;
  late Animation<double> _addAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _addController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _addAnimation = CurvedAnimation(
      parent: _addController,
      curve: Curves.elasticOut,
    );

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _addController.dispose();
    super.dispose();
  }

  void _addAsignacion() {
    // Usar el callback del padre
    widget.onAddAsignacion();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.005),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con contador animado
          _buildAsignacionesHeader(),

          // Lista de asignaciones - MANTENER ESTRUCTURA EXACTA del archivo original
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(widget.asignaciones.length, (index) {
                  final asignacion = widget.asignaciones[index];
                  return _buildAsignacionCard(asignacion, index);
                }),
              ),
            ),
          ),

          // Botón agregar asignación
          _buildAddAsignacionButton(),
        ],
      ),
    );
  }

  Widget _buildAsignacionesHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kBrandPurple.withValues(alpha: 0.05),
                    kAccentBlue.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kBrandPurple, kAccentBlue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: kBrandPurple.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Servicios Asignados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kBrandPurple,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Contador animado
                  AnimatedBuilder(
                    animation: _headerAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + (_headerAnimation.value * 0.2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kAccentGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: kAccentGreen.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${widget.asignaciones.length}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kAccentGreen,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAsignacionCard(Map<String, dynamic> asignacion, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kBrandPurpleLight.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kBorderColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kAccentBlue.withValues(alpha: 0.8),
                kAccentGreen.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          'Asignación ${index + 1}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kBrandPurple,
          ),
        ),
        subtitle: _buildAsignacionSubtitle(asignacion),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => widget.onRemoveAsignacion(index),
          tooltip: 'Eliminar asignación',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ COPIAR EXACTO la lógica de fecha del archivo original
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: asignacion['fecha'] ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            widget.onUpdateAsignacion(index, 'fecha', picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            asignacion['fecha'] != null
                                ? '${asignacion['fecha'].day.toString().padLeft(2, '0')}/${asignacion['fecha'].month.toString().padLeft(2, '0')}/${asignacion['fecha'].year}'
                                : 'Seleccionar fecha',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ MANTENER DropdownButtonFormField de servicios EXACTO líneas 290-310
                Row(
                  children: [
                    const Icon(Icons.miscellaneous_services, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: widget.servicios
                                .any((s) => s.id == asignacion['servicioId'])
                            ? asignacion['servicioId']
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Servicio',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: widget
                            .servicios // ✅ Lista real filtrada corporativo
                            .map((s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(
                                    s.data()['name'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          widget.onUpdateAsignacion(
                              index, 'servicioId', value!);
                        },
                        menuMaxHeight: 300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ MANTENER DropdownButtonFormField de profesionales EXACTO líneas 320-340
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: widget.profesionales
                                .any((p) => p.id == asignacion['profesionalId'])
                            ? asignacion['profesionalId']
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Profesional',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: widget.profesionales // ✅ Lista real de Firestore
                            .map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(
                                    p.data()['nombre'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          widget.onUpdateAsignacion(
                              index, 'profesionalId', value!);
                        },
                        menuMaxHeight: 300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ✅ AGREGAR horario con valores por defecto 9am-3pm
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kAccentGreen.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: kAccentGreen.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 18,
                            color: kAccentGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Horario del Servicio',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kAccentGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Hora de inicio
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  _selectTime(context, index, 'inicio'),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Hora Inicio',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  asignacion['horaInicio'] ??
                                      widget.horarioEventoInicio,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.arrow_forward,
                            color: kAccentGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          // Hora de fin
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context, index, 'fin'),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Hora Fin',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  asignacion['horaFin'] ??
                                      widget.horarioEventoFin,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsignacionSubtitle(Map<String, dynamic> asignacion) {
    final servicioNombre = widget.servicios
            .where((s) => s.id == asignacion['servicioId'])
            .map((s) => s.data()['name'] ?? 'Servicio')
            .firstOrNull ??
        'Sin servicio';

    final profesionalNombre = widget.profesionales
            .where((p) => p.id == asignacion['profesionalId'])
            .map((p) => p.data()['nombre'] ?? 'Profesional')
            .firstOrNull ??
        'Sin profesional';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$servicioNombre → $profesionalNombre',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        if (asignacion['horaInicio'] != null && asignacion['horaFin'] != null)
          Text(
            '${asignacion['horaInicio']} - ${asignacion['horaFin']}',
            style: TextStyle(
              fontSize: 11,
              color: kAccentGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildAddAsignacionButton() {
    return AnimatedBuilder(
      animation: _addAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_addAnimation.value * 0.1),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _addAsignacion,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Agregar Asignación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context, int index, String tipo) async {
    final asignacion = widget.asignaciones[index];
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _parseTimeOfDay(tipo == 'inicio'
          ? (asignacion['horaInicio'] ?? widget.horarioEventoInicio)
          : (asignacion['horaFin'] ?? widget.horarioEventoFin)),
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      if (tipo == 'inicio') {
        widget.onUpdateAsignacion(index, 'horaInicio', timeString);
      } else {
        widget.onUpdateAsignacion(index, 'horaFin', timeString);
      }
    }
  }

  TimeOfDay _parseTimeOfDay(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }
}
