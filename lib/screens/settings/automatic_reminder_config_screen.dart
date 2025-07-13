import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class AutomaticReminderConfigScreen extends StatefulWidget {
  const AutomaticReminderConfigScreen({super.key});

  @override
  State<AutomaticReminderConfigScreen> createState() =>
      _AutomaticReminderConfigScreenState();
}

class _AutomaticReminderConfigScreenState
    extends State<AutomaticReminderConfigScreen> {
  TimeOfDay? _horaSeleccionada;
  bool _whatsappActivo = true;
  bool _correoActivo = true;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarHoraDesdeFirestore();
  }

  Future<void> _cargarHoraDesdeFirestore() async {
    final doc = await FirebaseFirestore.instance
        .collection('configuracion')
        .doc('envio_automatico')
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final horaString = data['hora'] as String? ?? '08:00';

      final partes = horaString.split(':');
      if (partes.length == 2) {
        final hora = int.tryParse(partes[0]);
        final minuto = int.tryParse(partes[1]);
        if (hora != null && minuto != null) {
          _horaSeleccionada = TimeOfDay(hour: hora, minute: minuto);
        }
      }

      _whatsappActivo = data['whatsappActivo'] ?? true;
      _correoActivo = data['correoActivo'] ?? true;
    }

    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar envío automático'),
        backgroundColor: kBrandPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hora programada para enviar recordatorios:',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrandPurple,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    _horaSeleccionada != null
                        ? '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}'
                        : 'Seleccionar hora',
                    style: const TextStyle(fontSize: 16),
                  ),
                  onPressed: _mostrarSelectorHora,
                ),
                const SizedBox(height: 20),

                // Switches
                SwitchListTile(
                  title: const Text('Activar envío por WhatsApp'),
                  value: _whatsappActivo,
                  onChanged: (valor) => setState(() => _whatsappActivo = valor),
                  activeColor: kBrandPurple,
                ),
                SwitchListTile(
                  title: const Text('Activar envío por correo electrónico'),
                  value: _correoActivo,
                  onChanged: (valor) => setState(() => _correoActivo = valor),
                  activeColor: kBrandPurple,
                ),

                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _guardarHoraEnFirestore,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar configuración'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: kBrandPurple,
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: kBrandPurple),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarSelectorHora() async {
    final nuevaHora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay(hour: 8, minute: 0),
    );
    if (nuevaHora != null) {
      setState(() {
        _horaSeleccionada = nuevaHora;
      });
    }
  }

  Future<void> _guardarHoraEnFirestore() async {
    if (_horaSeleccionada == null) return;

    final horaStr =
        '${_horaSeleccionada!.hour.toString().padLeft(2, '0')}:${_horaSeleccionada!.minute.toString().padLeft(2, '0')}';

    await FirebaseFirestore.instance
        .collection('configuracion')
        .doc('envio_automatico')
        .set({
      'hora': horaStr,
      'whatsappActivo': _whatsappActivo,
      'correoActivo': _correoActivo,
    }, SetOptions(merge: true));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Configuración guardada correctamente'),
      ),
    );
  }
}
