// lib/widgets/mensajes_por_categoria.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme.dart';

class MensajesPorCategoria extends StatefulWidget {
  const MensajesPorCategoria({Key? key}) : super(key: key);

  @override
  State<MensajesPorCategoria> createState() => _MensajesPorCategoriaState();
}

class _MensajesPorCategoriaState extends State<MensajesPorCategoria> {
  // Lista de los 11 estados predefinidos
  final List<String> _listaCategorias = [
    "Reservando",
    "Cita creada",
    "Pago pendiente",
    "Cita confirmada",
    "Cita realizada",
    "Cancelada",
    "Reagendando cita",
    "No llego cliente",
    "Rechazada",
    "Profesional en camino",
    "Profesional en sitio",
  ];

  // Categoría seleccionada, por defecto "Reservando"
  String _selectedCategoria = "Reservando";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mensajes en \"$_selectedCategoria\""),
        backgroundColor: kBrandPurple,
      ),
      body: Column(
        children: [
          // Dropdown para seleccionar la categoría
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Seleccione la Categoría",
                border: OutlineInputBorder(),
              ),
              value: _selectedCategoria,
              items: _listaCategorias.map((String categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (valor) {
                if (valor != null) {
                  setState(() {
                    _selectedCategoria = valor;
                  });
                }
              },
            ),
          ),
          // Listado de mensajes en la categoría seleccionada
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("estados_cita")
                  .doc(_selectedCategoria)
                  .collection("mensajes")
                  .orderBy("fechaCreacion", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                      child: Text("No hay mensajes en esta categoría."));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(
                            data['tipoDestino'] ?? "Sin receptor definido"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("WhatsApp: ${data['mensajeWhatsapp'] ?? ''}"),
                            Text("Correo: ${data['mensajeCorreo'] ?? ''}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: "Editar Mensaje",
                              onPressed: () => _editMessage(doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: "Eliminar Mensaje",
                              onPressed: () => _deleteMessage(doc),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // FAB para crear un nuevo mensaje en la categoría seleccionada
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBrandPurple,
        child: const Icon(Icons.add),
        onPressed: _createMessage,
      ),
    );
  }

  // Diálogo para crear un nuevo mensaje
  void _createMessage() {
    final whatsappCtrl = TextEditingController();
    final correoCtrl = TextEditingController();
    bool activo = true;
    String tipoDestino = "Clientes"; // Valor por defecto

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Crear Mensaje"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: whatsappCtrl,
                  decoration:
                      const InputDecoration(labelText: "Mensaje WhatsApp"),
                ),
                TextField(
                  controller: correoCtrl,
                  decoration:
                      const InputDecoration(labelText: "Mensaje Correo"),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: activo,
                      onChanged: (v) {
                        setState(() {
                          activo = v ?? true;
                        });
                      },
                      activeColor: kBrandPurple,
                    ),
                    const Text("Activo"),
                  ],
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Receptor (tipoDestino)",
                    border: OutlineInputBorder(),
                  ),
                  value: tipoDestino,
                  items: const [
                    DropdownMenuItem(
                        value: "Clientes", child: Text("Clientes")),
                    DropdownMenuItem(
                        value: "Profesionales", child: Text("Profesionales")),
                    DropdownMenuItem(
                        value: "Clientes Corporativos",
                        child: Text("Clientes Corporativos")),
                    DropdownMenuItem(
                        value: "Administradores",
                        child: Text("Administradores")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tipoDestino = value ?? "Clientes";
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("estados_cita")
                    .doc(_selectedCategoria)
                    .collection("mensajes")
                    .add({
                  "mensajeWhatsapp": whatsappCtrl.text.trim(),
                  "mensajeCorreo": correoCtrl.text.trim(),
                  "activo": activo,
                  "tipoDestino": tipoDestino,
                  "fechaCreacion": FieldValue.serverTimestamp(),
                });
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mensaje creado")),
                );
              },
              child: const Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  // Diálogo para editar un mensaje existente
  void _editMessage(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final whatsappCtrl =
        TextEditingController(text: data["mensajeWhatsapp"] ?? "");
    final correoCtrl = TextEditingController(text: data["mensajeCorreo"] ?? "");
    bool activo = data["activo"] ?? true;
    String tipoDestino = data["tipoDestino"] ?? "Clientes";

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Editar Mensaje"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: whatsappCtrl,
                  decoration:
                      const InputDecoration(labelText: "Mensaje WhatsApp"),
                ),
                TextField(
                  controller: correoCtrl,
                  decoration:
                      const InputDecoration(labelText: "Mensaje Correo"),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: activo,
                      onChanged: (v) {
                        setState(() {
                          activo = v ?? true;
                        });
                      },
                      activeColor: kBrandPurple,
                    ),
                    const Text("Activo"),
                  ],
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Receptor (tipoDestino)",
                    border: OutlineInputBorder(),
                  ),
                  value: tipoDestino,
                  items: const [
                    DropdownMenuItem(
                        value: "Clientes", child: Text("Clientes")),
                    DropdownMenuItem(
                        value: "Profesionales", child: Text("Profesionales")),
                    DropdownMenuItem(
                        value: "Clientes Corporativos",
                        child: Text("Clientes Corporativos")),
                    DropdownMenuItem(
                        value: "Administradores",
                        child: Text("Administradores")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tipoDestino = value ?? "Clientes";
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("estados_cita")
                    .doc(_selectedCategoria)
                    .collection("mensajes")
                    .doc(doc.id)
                    .update({
                  "mensajeWhatsapp": whatsappCtrl.text.trim(),
                  "mensajeCorreo": correoCtrl.text.trim(),
                  "activo": activo,
                  "tipoDestino": tipoDestino,
                });
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mensaje actualizado")),
                );
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // Función para eliminar un mensaje
  void _deleteMessage(QueryDocumentSnapshot doc) async {
    await FirebaseFirestore.instance
        .collection("estados_cita")
        .doc(_selectedCategoria)
        .collection("mensajes")
        .doc(doc.id)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mensaje eliminado")),
    );
  }
}
