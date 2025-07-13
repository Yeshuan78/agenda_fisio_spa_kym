import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MicrositioScreen extends StatefulWidget {
  final String empresaId;

  const MicrositioScreen({super.key, required this.empresaId});

  @override
  State<MicrositioScreen> createState() => _MicrositioScreenState();
}

class _MicrositioScreenState extends State<MicrositioScreen> {
  String? _servicioSeleccionado;
  DateTime _fechaSeleccionada = DateTime.now();
  String? _horaSeleccionada;

  final List<String> _servicios = [
    'Masaje relajante',
    'Masaje deportivo',
    'Drenaje linfático',
  ];

  final List<String> _horasDisponibles = ['09:00', '10:00', '11:00', '12:00'];

  final String nombreEmpresa = 'Clínica Integral Plus';

  void _seleccionarFecha(DateTime date) {
    setState(() => _fechaSeleccionada = date);
  }

  void _agendar() {
    if (_servicioSeleccionado != null && _horaSeleccionada != null) {
      final dt = DateFormat('d \'de\' MMMM \'de\' yyyy, HH:mm', 'es_MX').format(
        DateTime(
          _fechaSeleccionada.year,
          _fechaSeleccionada.month,
          _fechaSeleccionada.day,
          int.parse(_horaSeleccionada!.split(':')[0]),
          int.parse(_horaSeleccionada!.split(':')[1]),
        ),
      );
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Cita agendada'),
          content: Text(
            'Servicio: $_servicioSeleccionado\nFecha: $dt',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMMM yyyy', 'es_MX');
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFF),
                border: Border.all(color: Colors.purple, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.005),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', height: 60),
                  const SizedBox(height: 12),
                  Text('Agenda de servicios – $nombreEmpresa',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Atención personalizada para tu bienestar',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _Paso(label: '1 Elegir servicio', activo: true),
                      _Paso(label: '2 Seleccionar fecha y hora'),
                      _Paso(label: '3 Confirmar y agendar'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('1. Elegir servicio',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          children: _servicios.map((s) {
                            final selected = _servicioSeleccionado == s;
                            return ChoiceChip(
                              label: Text(s),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _servicioSeleccionado = s),
                              selectedColor: Colors.purple.shade100,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        const Text('2. Seleccionar fecha y hora',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  screenWidth < 600
                      ? Column(
                          children: [
                            _buildFechaCard(df),
                            const SizedBox(height: 12),
                            _buildResumenCard()
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildFechaCard(df)),
                            Expanded(child: _buildResumenCard()),
                          ],
                        ),
                  const SizedBox(height: 32),
                  Center(
                    child: SizedBox(
                      width: 260,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple),
                        onPressed: _agendar,
                        child: const Text('Agendar cita'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFechaCard(DateFormat df) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(right: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(df.format(_fechaSeleccionada).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            CalendarDatePicker(
              initialDate: _fechaSeleccionada,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
              onDateChanged: _seleccionarFecha,
            ),
            Wrap(
              spacing: 12,
              children: _horasDisponibles.map((h) {
                final selected = _horaSeleccionada == h;
                return ChoiceChip(
                  label: Text(h),
                  selected: selected,
                  onSelected: (_) => setState(() => _horaSeleccionada = h),
                  selectedColor: Colors.purple.shade200,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple, width: 2),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.person, color: Colors.purple, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Andrea López',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_servicioSeleccionado ?? 'Sin servicio'),
            if (_horaSeleccionada != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('d MMMM yyyy, HH:mm', 'es_MX').format(
                    DateTime(
                      _fechaSeleccionada.year,
                      _fechaSeleccionada.month,
                      _fechaSeleccionada.day,
                      int.parse(_horaSeleccionada!.split(':')[0]),
                      int.parse(_horaSeleccionada!.split(':')[1]),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Paso extends StatelessWidget {
  final String label;
  final bool activo;

  const _Paso({required this.label, this.activo = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: activo ? Colors.purple : Colors.grey.shade300,
          child: Text(label[0],
              style: const TextStyle(fontSize: 12, color: Colors.white)),
        ),
        const SizedBox(width: 6),
        Text(
          label.substring(2),
          style: TextStyle(
            color: activo ? Colors.black87 : Colors.grey,
            fontWeight: activo ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
