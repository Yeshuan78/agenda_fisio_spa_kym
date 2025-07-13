// lib/widgets/mensajes_tab.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme.dart';

class MensajesTab extends StatefulWidget {
  // Usamos siempre el StreamBuilder (no se utiliza cachedEstados)
  const MensajesTab({Key? key}) : super(key: key);

  @override
  State<MensajesTab> createState() => _MensajesTabState();
}

class _MensajesTabState extends State<MensajesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Mapa: docID => bool para checkbox "Seleccionar"
  final Map<String, bool> _selectedItems = {};

  // Lista de 11 estados (categorías) que se usarán en el dropdown
  final List<String> _listaCategoriaEstado = [
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Siempre usamos el stream para actualizar la UI en tiempo real
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('estados_cita')
          .orderBy('orden')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent(snapshot.data!.docs);
      },
    );
  }

  Widget _buildContent(List<QueryDocumentSnapshot> docs) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Botón superior: Sólo se muestra "Crear Estados Flujo"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _initEstadosFlujoCita,
                  icon: const Icon(Icons.add_task, color: kBrandPurple),
                  label: const Text(
                    'Crear Estados Flujo',
                    style: TextStyle(color: kBrandPurple),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kBrandPurple),
                  ),
                ),
              ],
            ),
          ),
          // Sección de columnas agrupadas por tipoDestino
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              _buildCategoryColumn('Clientes', docs),
              _buildCategoryColumn('Profesionales', docs),
              _buildCategoryColumn('Clientes Corporativos', docs),
              _buildCategoryColumn('Administradores', docs),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1) Función: Crear/Actualizar los 11 estados de flujo en la nueva estructura
  // Cada documento se crea en la colección "estados_cita" con los campos "titulo"
  // y "categoriaEstado" iguales, y luego se guardará la subcolección "mensajes"
  // cuando se añadan mensajes.
  // ---------------------------------------------------------------------------
  Future<void> _initEstadosFlujoCita() async {
    try {
      for (var i = 0; i < _listaCategoriaEstado.length; i++) {
        final estadoValor = _listaCategoriaEstado[i];
        final orden = i + 1;

        final query = await FirebaseFirestore.instance
            .collection("estados_cita")
            .where("titulo", isEqualTo: estadoValor)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          await FirebaseFirestore.instance.collection("estados_cita").add({
            "titulo": estadoValor,
            "orden": orden,
            "activo": true,
            "categoriaEstado": estadoValor, // mismo valor que titulo
            "tipoDestino": "Clientes",
            "mensajeWhatsapp": "",
            "mensajeCorreo": "",
          });
        } else {
          final docID = query.docs.first.id;
          await FirebaseFirestore.instance
              .collection("estados_cita")
              .doc(docID)
              .update({
            "orden": orden,
            "activo": true,
            "categoriaEstado": estadoValor,
          });
        }
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Se han creado/actualizado los 11 estados de flujo.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error creando estados: $e')));
    }
  }

  // ---------------------------------------------------------------------------
  // 2) Función: Construir columna para cada "tipoDestino"
  // ---------------------------------------------------------------------------
  Widget _buildCategoryColumn(
    String subcategoria,
    List<QueryDocumentSnapshot> allDocs,
  ) {
    final filteredDocs = allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final tipoDestino = (data['tipoDestino'] ?? '').toString().trim();
      if (tipoDestino.isEmpty) {
        return subcategoria == 'Clientes';
      } else {
        return tipoDestino == subcategoria;
      }
    }).toList();

    final docIDs = filteredDocs.map((doc) => doc.id).toList();

    return SizedBox(
      width: 310,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Encabezado con botones para seleccionar/deseleccionar y borrar masivamente
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subcategoria,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              if (filteredDocs.isNotEmpty)
                IconButton(
                  tooltip: "Seleccionar / Deseleccionar todos",
                  icon: const Icon(Icons.checklist, color: Colors.blueGrey),
                  onPressed: () => _toggleSelectAll(docIDs),
                ),
              if (filteredDocs.isNotEmpty)
                IconButton(
                  tooltip: "Borrar seleccionados",
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _borrarSeleccionados(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (filteredDocs.isEmpty) const Text('No hay mensajes.'),
          for (var doc in filteredDocs) _buildEstadoCard(doc),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3) Función: Construir la tarjeta individual para cada mensaje
  // ---------------------------------------------------------------------------
  Widget _buildEstadoCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final docID = doc.id;
    final titulo = data['titulo'] ?? '';
    final catEstado = data['categoriaEstado'] ?? 'N/A';
    final esActivo = data['activo'] ?? true; // Valor real en Firestore

    final whatsappCtrl = TextEditingController(
      text: data['mensajeWhatsapp'] ?? '',
    );
    final correoCtrl = TextEditingController(
      text: data['mensajeCorreo'] ?? '',
    );

    // Checkbox "Seleccionar" para borrado en masa
    final isSelected = _selectedItems[docID] ?? false;

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
              // Se muestra el título (y por ende la categoría)
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Categoría Estado: $catEstado',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              // Campo: Mensaje WhatsApp
              TextField(
                controller: whatsappCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  labelText: 'Mensaje WhatsApp',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Campo: Mensaje Correo
              TextField(
                controller: correoCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  labelText: 'Mensaje Correo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Fila: Checkbox "Seleccionar"
              Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        _selectedItems[docID] = val ?? false;
                      });
                    },
                    activeColor: Colors.orange,
                  ),
                  const Text('Seleccionar'),
                ],
              ),
              // Fila: Checkbox "Activo" (sin contenedor extra)
              Row(
                children: [
                  Checkbox(
                    value: esActivo,
                    onChanged: (bool? v) async {
                      final newVal = v ?? false;
                      await FirebaseFirestore.instance
                          .collection('estados_cita')
                          .doc(docID)
                          .update({'activo': newVal});
                      setState(() {});
                    },
                    activeColor: kBrandPurple,
                  ),
                  const Text('Activo'),
                ],
              ),
              // Fila: Botones (Duplicar, Eliminar, Guardar)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: 'Duplicar',
                    onPressed: () => _showDuplicateDialog(doc),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    tooltip: 'Eliminar',
                    onPressed: () => _eliminarEstado(doc),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('estados_cita')
                          .doc(docID)
                          .update({
                        'mensajeWhatsapp': whatsappCtrl.text.trim(),
                        'mensajeCorreo': correoCtrl.text.trim(),
                      });
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Estado actualizado')),
                      );
                    },
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 40),
                      backgroundColor: kBrandPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  // ---------------------------------------------------------------------------
  // 4) Función: Eliminar documento individual
  // ---------------------------------------------------------------------------
  Future<void> _eliminarEstado(QueryDocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Center(child: Text('Eliminar Estado')),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este estado?',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kBrandPurple,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('estados_cita')
          .doc(doc.id)
          .delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Estado eliminado')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 5) Función: Seleccionar/Deseleccionar todos en la columna
  // ---------------------------------------------------------------------------
  void _toggleSelectAll(List<String> docIDs) {
    final allSelected = docIDs.every((id) => _selectedItems[id] == true);
    setState(() {
      if (!allSelected) {
        for (var id in docIDs) {
          _selectedItems[id] = true;
        }
      } else {
        for (var id in docIDs) {
          _selectedItems[id] = false;
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // 6) Función: Borrar todos los documentos seleccionados
  // ---------------------------------------------------------------------------
  Future<void> _borrarSeleccionados() async {
    final selectedDocIDs = _selectedItems.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();

    if (selectedDocIDs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay mensajes seleccionados.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Borrar Seleccionados'),
          content: Text(
              '¿Eliminar ${selectedDocIDs.length} mensajes seleccionados?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kBrandPurple,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final futures = <Future>[];
      for (var docID in selectedDocIDs) {
        futures.add(
          FirebaseFirestore.instance
              .collection('estados_cita')
              .doc(docID)
              .delete(),
        );
      }
      await Future.wait(futures);
      for (var docID in selectedDocIDs) {
        _selectedItems[docID] = false;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('✅ Se han eliminado ${selectedDocIDs.length} mensajes.'),
        ),
      );
      setState(() {});
    }
  }

  // ---------------------------------------------------------------------------
  // 7) Función: Duplicar documento
  // ---------------------------------------------------------------------------
  Future<void> _showDuplicateDialog(QueryDocumentSnapshot originalDoc) async {
    String selectedTipoDestino = 'Clientes';

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Center(child: Text('Duplicar Estado')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Selecciona el nuevo destino:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: selectedTipoDestino,
                items: const [
                  DropdownMenuItem(value: 'Clientes', child: Text('Clientes')),
                  DropdownMenuItem(
                    value: 'Profesionales',
                    child: Text('Profesionales'),
                  ),
                  DropdownMenuItem(
                    value: 'Clientes Corporativos',
                    child: Text('Clientes Corporativos'),
                  ),
                  DropdownMenuItem(
                    value: 'Administradores',
                    child: Text('Administradores'),
                  ),
                ],
                onChanged: (value) {
                  selectedTipoDestino = value ?? 'Clientes';
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kBrandPurple,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrandPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final data = originalDoc.data() as Map<String, dynamic>;
                final newData = Map<String, dynamic>.from(data);
                newData['tipoDestino'] = selectedTipoDestino;
                await FirebaseFirestore.instance
                    .collection('estados_cita')
                    .add(newData);
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Estado duplicado')),
                );
              },
              child: const Text('Duplicar'),
            ),
          ],
        );
      },
    );
  }
}
