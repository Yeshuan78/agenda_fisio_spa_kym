// File: lib/widgets/reminders/reminder_filters_sidebar.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class ReminderFilters {
  final String? tipoUsuario;
  final String? estado;
  final DateTime? fechaDesde;

  ReminderFilters({this.tipoUsuario, this.estado, this.fechaDesde});
}

class ReminderFiltersSidebar extends StatefulWidget {
  final ReminderFilters? initialFilters;
  final void Function(ReminderFilters filtros) onFilterChanged;

  const ReminderFiltersSidebar({
    super.key,
    this.initialFilters,
    required this.onFilterChanged,
  });

  @override
  State<ReminderFiltersSidebar> createState() => _ReminderFiltersSidebarState();
}

class _ReminderFiltersSidebarState extends State<ReminderFiltersSidebar> {
  String? _tipoUsuario;
  String? _estado;
  DateTime? _fechaDesde;

  final List<String> tiposUsuario = [
    'cliente',
    'profesional',
    'admin',
    'corporativo',
  ];

  final List<String> estados = [
    'reservado',
    'confirmado',
    'en camino',
    'llegamos',
    'cancelado',
  ];

  @override
  void initState() {
    super.initState();
    _tipoUsuario = widget.initialFilters?.tipoUsuario;
    _estado = widget.initialFilters?.estado;
    _fechaDesde = widget.initialFilters?.fechaDesde;
  }

  void _aplicarFiltros() {
    widget.onFilterChanged(ReminderFilters(
      tipoUsuario: _tipoUsuario,
      estado: _estado,
      fechaDesde: _fechaDesde,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBrandPurple.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filtros",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kBrandPurple,
            ),
          ),
          const SizedBox(height: 16),

          // Tipo de usuario
          DropdownButtonFormField<String>(
            value: _tipoUsuario,
            decoration: const InputDecoration(labelText: "Tipo de usuario"),
            items: tiposUsuario
                .map((tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo[0].toUpperCase() + tipo.substring(1)),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _tipoUsuario = value),
          ),
          const SizedBox(height: 12),

          // Estado
          DropdownButtonFormField<String>(
            value: _estado,
            decoration: const InputDecoration(labelText: "Estado de cita"),
            items: estados
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => setState(() => _estado = value),
          ),
          const SizedBox(height: 12),

          // Fecha
          InkWell(
            onTap: () async {
              final fecha = await showDatePicker(
                context: context,
                initialDate: _fechaDesde ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 60)),
                lastDate: DateTime.now().add(const Duration(days: 60)),
                locale: const Locale('es', 'MX'),
              );
              if (fecha != null) {
                setState(() {
                  _fechaDesde = fecha;
                });
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: "Desde fecha",
                border: OutlineInputBorder(),
              ),
              child: Text(
                _fechaDesde != null
                    ? DateFormat.yMMMMd('es_MX').format(_fechaDesde!)
                    : 'Seleccionar fecha',
              ),
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _aplicarFiltros,
              icon: const Icon(Icons.filter_alt),
              label: const Text("Aplicar filtros"),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
