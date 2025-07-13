import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "../theme/theme.dart";

class PlantillaCard extends StatelessWidget {
  final DocumentSnapshot doc;
  final VoidCallback onSave;

  const PlantillaCard({Key? key, required this.doc, required this.onSave})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final whatsappCtrl = TextEditingController(
      text: data["mensajeWhatsapp"] ?? "",
    );
    final correoCtrl = TextEditingController(text: data["mensajeCorreo"] ?? "");
    bool activo = data["activo"] ?? true;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kBrandPurple.withValues(alpha: 0.04)),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data["titulo"] ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "Categoría: ${data["tipoDestino"] ?? "N/A"}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: whatsappCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Mensaje WhatsApp",
                hintText: "Mensaje de WhatsApp...",
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
                labelText: "Mensaje Correo",
                hintText: "Mensaje de correo...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: activo,
                  onChanged: (v) {
                    // La actualización se maneja en el widget padre si se requiere.
                  },
                  activeColor: kBrandPurple,
                ),
                const Text("Activo"),
                const Spacer(),
                ElevatedButton.icon(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
