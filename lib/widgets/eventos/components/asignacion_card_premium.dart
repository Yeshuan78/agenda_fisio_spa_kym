// [asignacion_card.dart]
// 📁 Ubicación: /lib/widgets/eventos/components/asignacion_card.dart
// 🎯 OBJETIVO: Card premium para asignaciones individuales con expansión

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/eventos/components/asignacion_time_range_picker.dart';

class EventoAsignacion {
  final String servicioId;
  final String profesionalId;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;

  const EventoAsignacion({
    required this.servicioId,
    required this.profesionalId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
  });

  EventoAsignacion copyWith({
    String? servicioId,
    String? profesionalId,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
  }) {
    return EventoAsignacion(
      servicioId: servicioId ?? this.servicioId,
      profesionalId: profesionalId ?? this.profesionalId,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
    );
  }
}

class AsignacionCard extends StatefulWidget {
  final EventoAsignacion asignacion;
  final int index;
  final Function(int, EventoAsignacion) onUpdate;
  final Function(int) onRemove;
  final String horarioEventoInicio;
  final String horarioEventoFin;
  final List<Map<String, dynamic>> servicios;
  final List<Map<String, dynamic>> profesionales;

  const AsignacionCard({
    super.key,
    required this.asignacion,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
    required this.horarioEventoInicio,
    required this.horarioEventoFin,
    required this.servicios,
    required this.profesionales,
  });

  @override
  State<AsignacionCard> createState() => _AsignacionCardState();
}

class _AsignacionCardState extends State<AsignacionCard>
    with TickerProviderStateMixin {
  late AnimationController _expansionController;
  late AnimationController _hoverController;
  late Animation<double> _expansionAnimation;
  late Animation<double> _elevationAnimation;
  bool _isExpanded = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeInOutCubic,
    );
    _elevationAnimation = Tween<double>(
      begin: 2,
      end: 8,
    ).animate(_hoverController);
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _expansionController.forward();
    } else {
      _expansionController.reverse();
    }
  }

  void _updateFecha(DateTime fecha) {
    final updatedAsignacion = widget.asignacion.copyWith(fecha: fecha);
    widget.onUpdate(widget.index, updatedAsignacion);
  }

  void _updateServicio(String servicioId) {
    final updatedAsignacion = widget.asignacion.copyWith(servicioId: servicioId);
    widget.onUpdate(widget.index, updatedAsignacion);
  }

  void _updateProfesional(String profesionalId) {
    final updatedAsignacion = widget.asignacion.copyWith(profesionalId: profesionalId);
    widget.onUpdate(widget.index, updatedAsignacion);
  }

  void _updateHorario(String inicio, String fin) {
    final updatedAsignacion = widget.asignacion.copyWith(
      horaInicio: inicio,
      horaFin: fin,
    );
    widget.onUpdate(widget.index, updatedAsignacion);
  }

  String _getServicioNombre() {
    final servicio = widget.servicios.firstWhere(
      (s) => s['id'] == widget.asignacion.servicioId,
      orElse: () => {'name': 'Servicio no encontrado'},
    );
    return servicio['name'] ?? 'Sin nombre';
  }

  String _getProfesionalNombre() {
    final profesional = widget.profesionales.firstWhere(
      (p) => p['id'] == widget.asignacion.profesionalId,
      orElse: () => {'nombre': 'Profesional no encontrado'},
    );
    return profesional['nombre'] ?? 'Sin nombre';
  }

  Widget _buildAsignacionSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getServicioNombre()} • ${_getProfesionalNombre()}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${DateFormat('dd/MM/yyyy').format(widget.asignacion.fecha)} • ${widget.asignacion.horaInicio} - ${widget.asignacion.horaFin}',
          style: TextStyle(
            fontSize: 11,
            color: kAccentGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_expansionAnimation, _elevationAnimation]),
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isExpanded 
                    ? kBrandPurple.withValues(alpha: 0.3)
                    : kBorderColor.withValues(alpha: 0.1),
                width: _isExpanded ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: kBrandPurple.withValues(alpha: 0.08),
                  blurRadius: _elevationAnimation.value * 2,
                  offset: Offset(0, _elevationAnimation.value),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value * 0.5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header expansible
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _toggleExpansion,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icono con gradiente
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [kAccentBlue, kAccentGreen],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: kAccentBlue.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.assignment_ind,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Contenido principal
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Asignación ${widget.index + 1}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildAsignacionSubtitle(),
                              ],
                            ),
                          ),
                          
                          // Acciones
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Botón editar
                              PremiumIconButton(
                                icon: Icons.edit,
                                color: kAccentBlue,
                                onPressed: _toggleExpansion,
                                tooltip: 'Editar asignación',
                              ),
                              const SizedBox(width: 8),
                              // Botón eliminar
                              PremiumIconButton(
                                icon: Icons.delete_outline,
                                color: Colors.red.shade400,
                                onPressed: () => widget.onRemove(widget.index),
                                tooltip: 'Eliminar asignación',
                              ),
                              const SizedBox(width: 8),
                              // Indicador de expansión
                              AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  Icons.expand_more,
                                  color: kBrandPurple,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Contenido expandible
                SizeTransition(
                  sizeFactor: _expansionAnimation,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        Container(
                          height: 1,
                          color: kBorderColor.withValues(alpha: 0.1),
                          margin: const EdgeInsets.only(bottom: 16),
                        ),
                        
                        // Fecha con DatePicker premium
                        PremiumDatePicker(
                          date: widget.asignacion.fecha,
                          onChanged: _updateFecha,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Servicio y Profesional en fila
                        Row(
                          children: [
                            // Servicio dropdown
                            Expanded(
                              child: PremiumDropdown<String>(
                                label: 'Servicio',
                                value: widget.asignacion.servicioId.isEmpty 
                                    ? null 
                                    : widget.asignacion.servicioId,
                                items: widget.servicios.map((s) => DropdownMenuItem<String>(
                                  value: s['id'],
                                  child: Text(
                                    s['name'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )).toList(),
                                onChanged: (servicioId) {
                                  if (servicioId != null) _updateServicio(servicioId);
                                },
                                icon: Icons.miscellaneous_services,
                                color: kAccentGreen,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Profesional dropdown
                            Expanded(
                              child: PremiumDropdown<String>(
                                label: 'Profesional',
                                value: widget.asignacion.profesionalId.isEmpty 
                                    ? null 
                                    : widget.asignacion.profesionalId,
                                items: widget.profesionales.map((p) => DropdownMenuItem<String>(
                                  value: p['id'],
                                  child: Text(
                                    p['nombre'] ?? '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )).toList(),
                                onChanged: (profId) {
                                  if (profId != null) _updateProfesional(profId);
                                },
                                icon: Icons.person_outline,
                                color: kAccentBlue,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Horario específico con validación
                        AsignacionTimeRangePicker(
                          startTime: widget.asignacion.horaInicio,
                          endTime: widget.asignacion.horaFin,
                          eventoStartTime: widget.horarioEventoInicio,
                          eventoEndTime: widget.horarioEventoFin,
                          onChanged: _updateHorario,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PremiumIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final String tooltip;

  const PremiumIconButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.tooltip = '',
  });

  @override
  State<PremiumIconButton> createState() => _PremiumIconButtonState();
}

class _PremiumIconButtonState extends State<PremiumIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_scaleController);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  _scaleController.forward().then((_) {
                    _scaleController.reverse();
                  });
                  widget.onPressed();
                },
                child: Tooltip(
                  message: widget.tooltip,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PremiumDatePicker extends StatelessWidget {
  final DateTime date;
  final Function(DateTime) onChanged;

  const PremiumDatePicker({
    super.key,
    required this.date,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kAccentBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentBlue.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: kAccentBlue,
                      onSurface: Colors.black87,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccentBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha de Asignación',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kAccentBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd/MM/yyyy').format(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: kAccentBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final IconData icon;
  final Color color;

  const PremiumDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: color, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        items: items,
        onChanged: onChanged,
        dropdownColor: Colors.white,
        menuMaxHeight: 300,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}