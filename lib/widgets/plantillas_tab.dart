import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme.dart';

class PlantillasTab extends StatefulWidget {
  const PlantillasTab({Key? key}) : super(key: key);

  @override
  State<PlantillasTab> createState() => _PlantillasTabState();
}

class _PlantillasTabState extends State<PlantillasTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Global key para el formulario de creación/edición.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores de los campos del formulario.
  final TextEditingController _tituloCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();
  final TextEditingController _mensajeWhatsappCtrl = TextEditingController();
  final TextEditingController _mensajeCorreoCtrl = TextEditingController();

  // Variables de estado para la plantilla.
  bool _esActivo = true;
  String _tipoPlantilla = "Clientes";

  // Diálogo para crear o editar una plantilla.
  Future<void> _showPlantillaDialog({DocumentSnapshot? plantilla}) async {
    if (plantilla != null) {
      final data = plantilla.data() as Map<String, dynamic>;
      _tituloCtrl.text = data['titulo'] ?? "";
      _descripcionCtrl.text = data['descripcion'] ?? "";
      _mensajeWhatsappCtrl.text = data['mensajeWhatsapp'] ?? "";
      _mensajeCorreoCtrl.text = data['mensajeCorreo'] ?? "";
      _esActivo = data['activo'] ?? true;
      _tipoPlantilla = data['tipoPlantilla'] ?? "Clientes";
    } else {
      _tituloCtrl.clear();
      _descripcionCtrl.clear();
      _mensajeWhatsappCtrl.clear();
      _mensajeCorreoCtrl.clear();
      _esActivo = true;
      _tipoPlantilla = "Clientes";
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            plantilla != null ? "Editar Plantilla" : "Crear Nueva Plantilla",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Campo para el título.
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: const InputDecoration(
                      labelText: "Título",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "El título es requerido";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Campo para descripción (opcional).
                  TextFormField(
                    controller: _descripcionCtrl,
                    decoration: const InputDecoration(
                      labelText: "Descripción (opcional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Campo para el mensaje de WhatsApp.
                  TextFormField(
                    controller: _mensajeWhatsappCtrl,
                    decoration: const InputDecoration(
                      labelText: "Mensaje para WhatsApp",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  // Campo para el mensaje de Correo.
                  TextFormField(
                    controller: _mensajeCorreoCtrl,
                    decoration: const InputDecoration(
                      labelText: "Mensaje para Correo",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  // Checkbox para activar/desactivar.
                  Row(
                    children: [
                      Checkbox(
                        value: _esActivo,
                        onChanged: (val) {
                          setState(() {
                            _esActivo = val ?? true;
                          });
                        },
                        activeColor: kBrandPurple,
                      ),
                      const Text(
                        "Activo",
                        style: TextStyle(color: kBrandPurple),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Dropdown para seleccionar el tipo de plantilla.
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Tipo de plantilla",
                      border: OutlineInputBorder(),
                    ),
                    value: _tipoPlantilla,
                    items: const [
                      DropdownMenuItem(
                        value: "Clientes",
                        child: Text("Clientes"),
                      ),
                      DropdownMenuItem(
                        value: "Profesionales",
                        child: Text("Profesionales"),
                      ),
                      DropdownMenuItem(
                        value: "Clientes Corporativos",
                        child: Text("Clientes Corporativos"),
                      ),
                      DropdownMenuItem(
                        value: "Administradores",
                        child: Text("Administradores"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _tipoPlantilla = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kBrandPurple,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (_formKey.currentState != null &&
                    _formKey.currentState!.validate()) {
                  final plantillaData = {
                    "titulo": _tituloCtrl.text.trim(),
                    "descripcion": _descripcionCtrl.text.trim(),
                    "mensajeWhatsapp": _mensajeWhatsappCtrl.text.trim(),
                    "mensajeCorreo": _mensajeCorreoCtrl.text.trim(),
                    "activo": _esActivo,
                    "tipoPlantilla": _tipoPlantilla,
                    "createdAt": FieldValue.serverTimestamp(),
                  };
                  if (plantilla != null) {
                    await FirebaseFirestore.instance
                        .collection("plantillas")
                        .doc(plantilla.id)
                        .update(plantillaData);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Plantilla actualizada con éxito"),
                      ),
                    );
                  } else {
                    await FirebaseFirestore.instance
                        .collection("plantillas")
                        .add(plantillaData);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Plantilla creada con éxito"),
                      ),
                    );
                  }
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // Función para eliminar una plantilla.
  Future<void> _eliminarPlantilla(DocumentSnapshot doc) async {
    await FirebaseFirestore.instance
        .collection("plantillas")
        .doc(doc.id)
        .delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Plantilla eliminada con éxito")),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // Se elimina el título redundante del AppBar.
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kBrandPurple),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("plantillas")
                .orderBy("createdAt", descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final plantillas = snapshot.data!.docs;
          if (plantillas.isEmpty) {
            return const Center(child: Text("No hay plantillas registradas."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plantillas.length,
            itemBuilder: (ctx, index) {
              final data = plantillas[index].data() as Map<String, dynamic>;
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: kBrandPurple, width: 1),
                ),
                child: ListTile(
                  title: Text(
                    data['titulo'] ?? "Sin Título",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: kBrandPurple,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((data['descripcion'] ?? "").isNotEmpty)
                        Text(data['descripcion']),
                      const SizedBox(height: 5),
                      Text("WhatsApp: ${data['mensajeWhatsapp'] ?? ""}"),
                      Text("Correo: ${data['mensajeCorreo'] ?? ""}"),
                      Text("Tipo: ${data['tipoPlantilla'] ?? ""}"),
                      Text("Activo: ${data['activo'] ? 'Sí' : 'No'}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: kBrandPurple),
                        onPressed:
                            () => _showPlantillaDialog(
                              plantilla: plantillas[index],
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarPlantilla(plantillas[index]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBrandPurple,
        onPressed: () => _showPlantillaDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
