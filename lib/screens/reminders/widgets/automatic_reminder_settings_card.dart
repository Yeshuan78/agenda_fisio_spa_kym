import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class AutomaticReminderSettingsCard extends StatefulWidget {
  const AutomaticReminderSettingsCard({super.key});

  @override
  State<AutomaticReminderSettingsCard> createState() =>
      _AutomaticReminderSettingsCardState();
}

class _AutomaticReminderSettingsCardState
    extends State<AutomaticReminderSettingsCard> {
  int horasAntes = 2;
  bool whatsappActivo = true;
  bool correoActivo = true;

  final docRef = FirebaseFirestore.instance
      .collection('notificaciones_config')
      .doc('global');

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data()!;
      horasAntes = data['horasAntes'] ?? 2;
      whatsappActivo = data['whatsappActivo'] ?? true;
      correoActivo = data['correoActivo'] ?? true;
      setState(() {});
    }
  }

  Future<void> _guardarConfiguracion() async {
    await docRef.set({
      'horasAntes': horasAntes,
      'whatsappActivo': whatsappActivo,
      'correoActivo': correoActivo,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Configuración actualizada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorderColor.withAlpha(80)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Text(
              'Envío Automático',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: kBrandPurple,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Selector de horas antes
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('¿Cuántas horas antes?',
                          style: TextStyle(fontSize: 13)),
                    ),
                    DropdownButton<int>(
                      value: horasAntes,
                      isExpanded: true,
                      items: [1, 2, 3, 4, 5, 6]
                          .map((h) => DropdownMenuItem(
                              value: h, child: Text('$h horas antes')))
                          .toList(),
                      onChanged: (v) => setState(() => horasAntes = v ?? 2),
                    ),
                    const SizedBox(height: 16),

                    // Switch WhatsApp
                    SwitchListTile(
                      title: const Text('Enviar por WhatsApp'),
                      value: whatsappActivo,
                      onChanged: (v) => setState(() => whatsappActivo = v),
                      activeColor: kBrandPurple,
                    ),

                    // Switch Correo
                    SwitchListTile(
                      title: const Text('Enviar por correo electrónico'),
                      value: correoActivo,
                      onChanged: (v) => setState(() => correoActivo = v),
                      activeColor: kBrandPurple,
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: _guardarConfiguracion,
                      icon: const Icon(Icons.save),
                      label: const Text("Guardar cambios"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandPurple,
                        minimumSize: const Size.fromHeight(40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
