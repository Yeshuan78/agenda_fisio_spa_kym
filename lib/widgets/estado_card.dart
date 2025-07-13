// estado_card.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme.dart';

class EstadoCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const EstadoCard({
    Key? key,
    required this.doc,
    required this.onSave,
    required this.onDelete,
    required this.onDuplicate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final whatsappCtrl = TextEditingController(
      text: data['mensajeWhatsapp'] ?? '',
    );
    final correoCtrl = TextEditingController(
      text: data['mensajeCorreo'] ?? '',
    );
    final bool esActivo = data['activo'] ?? true;

    // Título
    final titulo = data['titulo'] ?? '';
    // Categoría Estado
    final catEstado = data['categoriaEstado'] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: kBrandPurple.withValues(alpha: 0.04)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                // Reemplazamos 'Categoría: data['categoria']' por:
                'Categoría Estado: $catEstado',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: whatsappCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  labelText: 'Mensaje WhatsApp',
                  hintText: 'Mensaje de WhatsApp...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: correoCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  labelText: 'Mensaje Correo',
                  hintText: 'Mensaje de correo...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: esActivo,
                    onChanged: (v) async {
                      final newVal = v ?? false;
                      await FirebaseFirestore.instance
                          .collection("estados_cita")
                          .doc(doc.id)
                          .update({"activo": newVal});
                    },
                    activeColor: kBrandPurple,
                  ),
                  const Text('Activo'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: "Duplicar",
                    onPressed: onDuplicate,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    tooltip: "Eliminar",
                    onPressed: onDelete,
                  ),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton.icon(
                      onPressed: onSave,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text("Guardar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
