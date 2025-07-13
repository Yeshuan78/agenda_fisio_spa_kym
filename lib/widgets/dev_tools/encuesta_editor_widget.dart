import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EncuestaEditorWidget extends StatefulWidget {
  const EncuestaEditorWidget({super.key});

  @override
  State<EncuestaEditorWidget> createState() => _EncuestaEditorWidgetState();
}

class _EncuestaEditorWidgetState extends State<EncuestaEditorWidget> {
  List<Map<String, dynamic>> _preguntas = [];
  String? _docId;

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  }

  Future<void> _cargarPreguntas() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('encuestas').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      _docId = doc.id;
      final data = doc.data();
      if (data.containsKey('preguntas')) {
        setState(() {
          _preguntas = List<Map<String, dynamic>>.from(data['preguntas']);
        });
      } else {
        // Si no tiene preguntas, insertamos las default
        _preguntas = _crearPreguntasPorDefecto();
        await _guardar();
      }
    } else {
      // Si no hay documentos en la colección, crear uno nuevo con preguntas por defecto
      final newDoc =
          await FirebaseFirestore.instance.collection('encuestas').add({
        'preguntas': _crearPreguntasPorDefecto(),
      });
      _docId = newDoc.id;
      _preguntas = _crearPreguntasPorDefecto();
    }
    setState(() {});
  }

  List<Map<String, dynamic>> _crearPreguntasPorDefecto() {
    return [
      {
        "texto": "¿Cómo calificarías la atención del profesional?",
        "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
      },
      {
        "texto": "¿Qué tan cómodo(a) te sentiste durante el servicio?",
        "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
      },
      {
        "texto": "¿Qué opinas de la puntualidad en tu cita?",
        "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
      },
      {
        "texto": "¿Qué tan útil consideras este servicio para tu bienestar?",
        "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
      },
      {
        "texto": "¿Cómo calificarías la experiencia general del servicio?",
        "opciones": ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
      }
    ];
  }

  Future<void> _guardar() async {
    if (_docId == null) return;
    await FirebaseFirestore.instance
        .collection('encuestas')
        .doc(_docId)
        .set({'preguntas': _preguntas});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Encuesta guardada correctamente')),
    );
  }

  void _agregarPregunta() {
    setState(() {
      _preguntas.add({
        'texto': '',
        'opciones': ['⭐', '⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐', '⭐⭐⭐⭐⭐']
      });
    });
  }

  void _eliminarPregunta(int index) {
    setState(() {
      _preguntas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Editor de Encuesta',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _preguntas.length,
              itemBuilder: (context, index) {
                final pregunta = _preguntas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Texto de la pregunta'),
                          controller:
                              TextEditingController(text: pregunta['texto'])
                                ..selection = TextSelection.collapsed(
                                    offset: pregunta['texto'].length),
                          onChanged: (val) => pregunta['texto'] = val,
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(pregunta['opciones'].length,
                            (optIndex) {
                          return Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Opción'),
                                  controller: TextEditingController(
                                      text: pregunta['opciones'][optIndex])
                                    ..selection = TextSelection.collapsed(
                                        offset: pregunta['opciones'][optIndex]
                                            .length),
                                  onChanged: (val) =>
                                      pregunta['opciones'][optIndex] = val,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    pregunta['opciones'].removeAt(optIndex);
                                  });
                                },
                              )
                            ],
                          );
                        }),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              pregunta['opciones'].add('');
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar opción'),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _eliminarPregunta(index),
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Eliminar pregunta'),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton.icon(
            onPressed: _agregarPregunta,
            icon: const Icon(Icons.add),
            label: const Text('Nueva pregunta'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _guardar,
            child: const Text('Guardar encuesta'),
          ),
        ],
      ),
    );
  }
}
