// [agenda_mini_calendar.dart]
// 📁 Ubicación: /lib/widgets/agenda/agenda_mini_calendar.dart
// 📅 MINI CALENDARIO LATERAL EMPRESARIAL CON NAVEGACIÓN RÁPIDA + QUICK ACTIONS INTEGRADAS

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/models/appointment_model.dart';

class AgendaMiniCalendar extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final Map<DateTime, List<AppointmentModel>> appointments;
  final Function(DateTime) onDateSelected;
  final Function(DateTime)? onMonthChanged;
  final bool showAppointmentIndicators;
  final bool showWeekNumbers;
  final bool compactMode;
  final double? width;
  final double? height;
  // 🆕 NUEVOS PARÁMETROS PARA QUICK ACTIONS
  final Function(String)? onNavigate;
  final Function(DateTime, String?)? onAppointmentCreate;

  const AgendaMiniCalendar({
    super.key,
    required this.selectedDate,
    required this.focusedMonth,
    required this.appointments,
    required this.onDateSelected,
    this.onMonthChanged,
    this.showAppointmentIndicators = true,
    this.showWeekNumbers = false,
    this.compactMode = false,
    this.width,
    this.height,
    // 🆕 NUEVOS PARÁMETROS OPCIONALES
    this.onNavigate,
    this.onAppointmentCreate,
  });

  @override
  State<AgendaMiniCalendar> createState() => _AgendaMiniCalendarState();
}

class _AgendaMiniCalendarState extends State<AgendaMiniCalendar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _hoverController;
  late AnimationController _pulseController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _hoverAnimation;
  late Animation<double> _pulseAnimation;

  DateTime _displayedMonth = DateTime.now();
  DateTime? _hoveredDate;
  bool _isNavigating = false;

  // ✅ CONFIGURACIÓN EMPRESARIAL
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const Duration _hoverDelay = Duration(milliseconds: 100);
  static const int _maxAppointmentIndicators = 3;

  @override
  void initState() {
    super.initState();
    _displayedMonth =
        DateTime(widget.focusedMonth.year, widget.focusedMonth.month);
    _initAnimations();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    _startPulseForToday();
  }

  void _startPulseForToday() {
    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final selectedNormalized = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    if (todayNormalized == selectedNormalized) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AgendaMiniCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusedMonth.month != oldWidget.focusedMonth.month ||
        widget.focusedMonth.year != oldWidget.focusedMonth.year) {
      _animateToMonth(widget.focusedMonth);
    }

    if (widget.selectedDate != oldWidget.selectedDate) {
      _startPulseForToday();
    }
  }

  void _animateToMonth(DateTime newMonth) {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
      _displayedMonth = DateTime(newMonth.year, newMonth.month);
    });

    _slideController.reverse().then((_) {
      if (mounted) {
        _slideController.forward().then((_) {
          setState(() => _isNavigating = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _hoverController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? (widget.compactMode ? 280 : 320),
      height: widget.height ?? (widget.compactMode ? 360 : 420),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kBorderColor.withValues(alpha: 0.02),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: kBrandPurple.withValues(alpha: 0.008),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildHeader(),
            _buildWeekdaysHeader(),
            Expanded(
              flex: 3,
              child: AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: _buildCalendarGrid(),
                  );
                },
              ),
            ),
            if (!widget.compactMode) _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(widget.compactMode ? 8 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.005),
            kAccentBlue.withValues(alpha: 0.002),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: kBorderColor.withValues(alpha: 0.01),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ✅ BOTÓN MES ANTERIOR
          _buildNavigationButton(
            icon: Icons.chevron_left,
            onPressed: () => _navigateMonth(-1),
            tooltip: 'Mes anterior',
          ),

          // ✅ TÍTULO DEL MES
          Expanded(
            child: GestureDetector(
              onTap: _showMonthYearPicker,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _hoveredDate != null
                      ? kBrandPurple.withValues(alpha: 0.005)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      _capitalize(
                          DateFormat('MMMM', 'es_MX').format(_displayedMonth)),
                      style: TextStyle(
                        fontSize: widget.compactMode ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: kBrandPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      DateFormat('yyyy').format(_displayedMonth),
                      style: TextStyle(
                        fontSize: widget.compactMode ? 9 : 10,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ BOTÓN MES SIGUIENTE
          _buildNavigationButton(
            icon: Icons.chevron_right,
            onPressed: () => _navigateMonth(1),
            tooltip: 'Mes siguiente',
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            onPressed();
            HapticFeedback.lightImpact();
          },
          child: Container(
            width: widget.compactMode ? 28 : 32,
            height: widget.compactMode ? 28 : 32,
            decoration: BoxDecoration(
              color: kBrandPurple.withValues(alpha: 0.005),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: kBrandPurple.withValues(alpha: 0.02),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: kBrandPurple,
              size: widget.compactMode ? 16 : 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdaysHeader() {
    const weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compactMode ? 8 : 12,
        vertical: widget.compactMode ? 6 : 8,
      ),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: widget.compactMode ? 8 : 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _generateCalendarDays();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compactMode ? 2 : 4,
        vertical: widget.compactMode ? 1 : 2,
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 0.8,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: daysInMonth.length,
        itemBuilder: (context, index) {
          final dayData = daysInMonth[index];
          return _buildDayCell(dayData);
        },
      ),
    );
  }

  Widget _buildDayCell(CalendarDay dayData) {
    final isSelected = _isSameDay(dayData.date, widget.selectedDate);
    final isToday = _isSameDay(dayData.date, DateTime.now());
    final appointments = _getAppointmentsForDay(dayData.date);
    final appointmentCount = appointments.length;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hoveredDate = dayData.date);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _hoveredDate = null);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: () {
          if (dayData.isCurrentMonth) {
            widget.onDateSelected(dayData.date);
            HapticFeedback.selectionClick();
          }
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverAnimation, _pulseAnimation]),
          builder: (context, child) {
            final isHovered =
                _hoveredDate != null && _isSameDay(_hoveredDate!, dayData.date);
            final scale = isSelected && isToday
                ? _pulseAnimation.value
                : isHovered
                    ? 1.0 + (_hoverAnimation.value * 0.05)
                    : 1.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      _getDayCellColor(dayData, isSelected, isToday, isHovered),
                  shape: BoxShape.circle,
                  border: _getDayCellBorder(
                      dayData, isSelected, isToday, isHovered),
                  boxShadow: _getDayCellShadow(isSelected, isToday, isHovered),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ✅ NÚMERO DEL DÍA
                    Text(
                      '${dayData.date.day}',
                      style: TextStyle(
                        fontSize: widget.compactMode ? 11 : 12,
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: _getDayTextColor(dayData, isSelected, isToday),
                      ),
                    ),

                    // ✅ INDICADORES DE CITAS
                    if (widget.showAppointmentIndicators &&
                        appointmentCount > 0)
                      _buildAppointmentIndicators(
                        appointmentCount,
                        appointments,
                        isSelected,
                      ),

                    // ✅ INDICADOR DE HOY
                    if (isToday && !isSelected)
                      Positioned(
                        bottom: 2,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: kAccentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentIndicators(
    int count,
    List<AppointmentModel> appointments,
    bool isSelected,
  ) {
    if (count == 0) return const SizedBox.shrink();

    if (count == 1) {
      // Un solo punto
      return Positioned(
        bottom: widget.compactMode ? 1 : 2,
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : kBrandPurple,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else if (count <= 3) {
      // Múltiples puntos
      return Positioned(
        bottom: widget.compactMode ? 1 : 2,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            count.clamp(1, _maxAppointmentIndicators),
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : _getAppointmentColor(appointments, index),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    } else {
      // Contador numérico para muchas citas
      return Positioned(
        top: 1,
        right: 1,
        child: Container(
          width: widget.compactMode ? 12 : 14,
          height: widget.compactMode ? 12 : 14,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : kBrandPurple,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count > 9 ? '9+' : '$count',
              style: TextStyle(
                fontSize: widget.compactMode ? 7 : 8,
                fontWeight: FontWeight.bold,
                color: isSelected ? kBrandPurple : Colors.white,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildFooter() {
    final selectedDayAppointments = _getAppointmentsForDay(widget.selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        border: Border(
          top: BorderSide(
            color: kBorderColor.withValues(alpha: 0.01),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ RESUMEN COMPACTO
          Text(
            _isSameDay(widget.selectedDate, DateTime.now())
                ? 'Hoy: ${selectedDayAppointments.length}'
                : '${DateFormat('dd/MM', 'es_MX').format(widget.selectedDate)}: ${selectedDayAppointments.length}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          // ✅ QUICK ACTIONS ULTRA COMPACTAS
          Row(
            children: [
              Expanded(
                child: _buildCompactAction(
                  icon: Icons.person_add,
                  color: kAccentBlue,
                  onTap: () => widget.onNavigate?.call('/clientes/nuevo'),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildCompactAction(
                  icon: Icons.event_available,
                  color: kAccentGreen,
                  onTap: () => widget.onAppointmentCreate
                      ?.call(widget.selectedDate, null),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildCompactAction(
                  icon: Icons.today,
                  color: kBrandPurple,
                  onTap: () => widget.onDateSelected(DateTime.now()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.008),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withValues(alpha: 0.02),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 14,
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // 🔧 MÉTODOS HELPER
  // ========================================================================

  List<CalendarDay> _generateCalendarDays() {
    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final startDate =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));

    final days = <CalendarDay>[];
    DateTime currentDate = startDate;

    // Generar 42 días (6 semanas completas)
    for (int i = 0; i < 42; i++) {
      days.add(CalendarDay(
        date: currentDate,
        isCurrentMonth: currentDate.month == _displayedMonth.month,
        isPreviousMonth: currentDate.month < _displayedMonth.month,
        isNextMonth: currentDate.month > _displayedMonth.month,
      ));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return days;
  }

  List<AppointmentModel> _getAppointmentsForDay(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return widget.appointments[normalized] ?? [];
  }

  Color _getDayCellColor(
      CalendarDay dayData, bool isSelected, bool isToday, bool isHovered) {
    if (isSelected) {
      return isToday ? kAccentGreen : kBrandPurple;
    }
    if (isHovered && dayData.isCurrentMonth) {
      return kBrandPurple.withValues(alpha: 0.01);
    }
    return Colors.transparent;
  }

  Border? _getDayCellBorder(
      CalendarDay dayData, bool isSelected, bool isToday, bool isHovered) {
    if (isToday && !isSelected) {
      return Border.all(color: kAccentGreen, width: 2);
    }
    if (isHovered && dayData.isCurrentMonth && !isSelected) {
      return Border.all(color: kBrandPurple.withValues(alpha: 0.03), width: 1);
    }
    return null;
  }

  List<BoxShadow>? _getDayCellShadow(
      bool isSelected, bool isToday, bool isHovered) {
    if (isSelected) {
      return [
        BoxShadow(
          color:
              (isToday ? kAccentGreen : kBrandPurple).withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return null;
  }

  Color _getDayTextColor(CalendarDay dayData, bool isSelected, bool isToday) {
    if (isSelected) {
      return Colors.white;
    }
    if (!dayData.isCurrentMonth) {
      return Colors.grey.shade400;
    }
    if (isToday) {
      return kAccentGreen;
    }
    return Colors.black87;
  }

  Color _getAppointmentColor(List<AppointmentModel> appointments, int index) {
    if (index >= appointments.length) return kBrandPurple;

    final appointment = appointments[index];
    switch (appointment.estado?.toLowerCase()) {
      case 'confirmado':
        return kAccentGreen;
      case 'reservado':
        return Colors.orange.shade600;
      case 'cancelado':
        return Colors.red.shade600;
      default:
        return kBrandPurple;
    }
  }

  void _navigateMonth(int direction) {
    final newMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + direction,
    );

    _animateToMonth(newMonth);
    widget.onMonthChanged?.call(newMonth);
    HapticFeedback.lightImpact();
  }

  void _showMonthYearPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _displayedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('es', 'MX'),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      _animateToMonth(picked);
      widget.onMonthChanged?.call(picked);
    }
  }

  void _showQuickAddDialog() {
    // TODO: Implementar diálogo rápido para crear cita
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de creación rápida próximamente'),
        backgroundColor: kBrandPurple,
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

// ========================================================================
// 📋 MODELO DE DATOS PARA DÍAS DEL CALENDARIO
// ========================================================================

class CalendarDay {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isPreviousMonth;
  final bool isNextMonth;

  CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.isPreviousMonth,
    required this.isNextMonth,
  });
}
