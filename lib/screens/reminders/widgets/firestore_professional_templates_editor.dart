// lib/widgets/reminders/firestore_professional_templates_editor.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class FirestoreProfessionalTemplatesEditor extends StatefulWidget {
  const FirestoreProfessionalTemplatesEditor({Key? key}) : super(key: key);

  @override
  State<FirestoreProfessionalTemplatesEditor> createState() =>
      _FirestoreProfessionalTemplatesEditorState();
}

class _FirestoreProfessionalTemplatesEditorState
    extends State<FirestoreProfessionalTemplatesEditor> {
  final Map<String, TextEditingController> controllers = {};
  List<String> estados = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
  }

  Future<void> _cargarMensajes() async {
    final col = FirebaseFirestore.instance
        .collection('notificaciones_config')
        .doc('templates')
        .collection('whatsapp_profesional');
    final snap = await col.get();

    estados = [];
    controllers.clear();
    for (final doc in snap.docs) {
      final estado = doc.id;
      estados.add(estado);
      controllers[estado] =
          TextEditingController(text: doc['mensaje'] as String? ?? '');
    }

    setState(() => cargando = false);
  }

  Future<void> _guardarMensaje(String estado) async {
    final texto = controllers[estado]!.text.trim();
    final docRef = FirebaseFirestore.instance
        .collection('notificaciones_config')
        .doc('templates')
        .collection('whatsapp_profesional')
        .doc(estado);

    await docRef.set({
      'mensaje': texto,
      'estado': estado,
      'tipoUsuario': 'profesional',
      'canal': 'whatsapp',
      'activo': true,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensaje guardado correctamente ✅')),
    );
  }

  Future<void> _eliminarMensaje(String estado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar plantilla'),
        content: Text('¿Deseas eliminar la plantilla del estado "$estado"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar == true) {
      await FirebaseFirestore.instance
          .collection('notificaciones_config')
          .doc('templates')
          .collection('whatsapp_profesional')
          .doc(estado)
          .delete();
      await _cargarMensajes();
    }
  }

  Future<void> _clonarAMensajeCorreo(String estado) async {
    final contenido = controllers[estado]?.text.trim() ?? '';
    if (contenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay mensaje para clonar 📄')),
      );
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection('notificaciones_config')
        .doc('templates')
        .collection('email_profesional');
    final docRef = ref.doc(estado);

    await docRef.set({
      'mensaje': contenido,
      'estado': estado,
      'tipoUsuario': 'profesional',
      'canal': 'email',
      'activo': true,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensaje clonado exitosamente a correo ✅')),
    );
  }

  void _agregarEstadoDialog() {
    final estadoController = TextEditingController();
    final mensajeController = TextEditingController();
    final sugeridos = [
      'asignado',
      'confirmado',
      'cancelado',
      'recordatorio',
      'cita_realizada'
    ];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar estado personalizado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: sugeridos.map((e) {
                return InputChip(
                  label: Text(e),
                  onPressed: () => estadoController.text = e,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: estadoController,
              decoration: const InputDecoration(labelText: 'Nombre del estado'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: mensajeController,
              maxLines: 4,
              decoration:
                  const InputDecoration(labelText: 'Mensaje de la plantilla'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () async {
                final estado = estadoController.text.trim();
                final mensaje = mensajeController.text.trim();
                if (estado.isEmpty || mensaje.isEmpty) return;

                final docRef = FirebaseFirestore.instance
                    .collection('notificaciones_config')
                    .doc('templates')
                    .collection('whatsapp_profesional')
                    .doc(estado);

                await docRef.set({
                  'estado': estado,
                  'mensaje': mensaje,
                  'tipoUsuario': 'profesional',
                  'canal': 'whatsapp',
                  'activo': true,
                });
                Navigator.pop(context);
                await _cargarMensajes();
              },
              child: const Text('Guardar plantilla')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Plantillas para Profesional / WhatsApp',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kBrandPurple,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _agregarEstadoDialog,
                icon: const Icon(Icons.add),
                label: const Text('Agregar estado personalizado'),
              ),
              const SizedBox(height: 12),
              ...estados.map((estado) {
                return Column(
                  children: [
                    Card(
                      color: Colors.grey[50],
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Estado: ${estado[0].toUpperCase()}${estado.substring(1)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _eliminarMensaje(estado),
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Eliminar plantilla',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: controllers[estado],
                              maxLines: 3,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.all(12),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color:
                                          kBrandPurple.withValues(alpha: 0.05)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: kBrandPurple, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildVariablesHelpChips(),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.visibility),
                              label: const Text('Vista previa del mensaje'),
                              onPressed: () => _showPreview(
                                  context, controllers[estado]!.text),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.save,
                                  size: 16, color: kBrandPurple),
                              label: const Text(
                                'Guardar',
                                style: TextStyle(
                                    color: kBrandPurple, fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                side: const BorderSide(color: kBrandPurple),
                                minimumSize: const Size.fromHeight(40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _guardarMensaje(estado),
                            ),
                            const SizedBox(height: 6),
                            TextButton.icon(
                              icon: const Icon(Icons.copy),
                              label: const Text('Clonar a correo'),
                              onPressed: () => _clonarAMensajeCorreo(estado),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVariablesHelpChips() {
    const variables = [
      '{{nombre}}',
      '{{fecha}}',
      '{{hora}}',
      '{{servicio}}',
      '{{profesional}}',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: variables.map((v) {
        return Chip(
          label: Text(v,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }).toList(),
    );
  }

  void _showPreview(BuildContext context, String template) {
    const ejemplo = {
      'nombre': 'Andrea',
      'fecha': '20 de abril',
      'hora': '13:00',
      'servicio': 'Masaje relajante',
      'profesional': 'Julia González',
    };
    var mensaje = template;
    ejemplo.forEach((k, v) {
      mensaje = mensaje.replaceAll('{{$k}}', v);
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Vista previa del mensaje'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
