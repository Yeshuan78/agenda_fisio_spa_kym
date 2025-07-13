import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/paquete_model.dart';
import 'package:agenda_fisio_spa_kym/models/servicio_model.dart';
import 'package:agenda_fisio_spa_kym/models/categoria_model.dart';
import 'package:agenda_fisio_spa_kym/services/categoria_service.dart';

class PaqueteForm extends StatefulWidget {
  final List<ServicioModel> serviciosDisponibles;
  final void Function(PaqueteModel) onGuardar;

  const PaqueteForm({
    super.key,
    required this.serviciosDisponibles,
    required this.onGuardar,
  });

  @override
  State<PaqueteForm> createState() => _PaqueteFormState();
}

class _PaqueteFormState extends State<PaqueteForm> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  double precio = 0;
  List<CategoriaModel> categorias = [];

  List<ServicioPaquete> seleccionados = [];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final data = await CategoriaService().getCategorias();
    setState(() {
      categorias = data;
    });
  }

  void _guardar() {
    if (_formKey.currentState!.validate() && seleccionados.isNotEmpty) {
      final duracionTotal =
          seleccionados.fold<int>(0, (acc, s) => acc + s.duracion);
      final paquete = PaqueteModel(
        paqueteId: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        servicios: seleccionados,
        precioTotal: precio,
        duracionTotal: duracionTotal,
      );
      widget.onGuardar(paquete);
      Navigator.pop(context);
    }
  }

  Color _parseColor(String hex) {
    try {
      hex = hex.replaceAll("#", "").toUpperCase();
      if (hex.length == 6) hex = "FF$hex";
      return Color(int.parse("0x$hex"));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo Paquete'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          height: 600,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Nombre del paquete'),
                  onChanged: (v) => nombre = v,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Precio total'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => precio = double.tryParse(v) ?? 0,
                ),
                const SizedBox(height: 16),
                const Text('Selecciona servicios incluidos:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...categorias.map((categoria) {
                  final serviciosDeCategoria = widget.serviciosDisponibles
                      .where((s) => s.category == categoria.nombre)
                      .toList();
                  if (serviciosDeCategoria.isEmpty)
                    return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(
                              color: _parseColor(categoria.colorHex),
                              width: 4)),
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          const Icon(Icons.folder_open, size: 20),
                          const SizedBox(width: 6),
                          Text(categoria.nombre),
                        ],
                      ),
                      initiallyExpanded: false,
                      children: serviciosDeCategoria.map((s) {
                        final exists = seleccionados
                            .any((e) => e.servicioId == s.servicioId);
                        final selected = seleccionados.firstWhere(
                          (e) => e.servicioId == s.servicioId,
                          orElse: () => ServicioPaquete(
                            servicioId: s.servicioId,
                            nombre: s.name,
                            duracion: s.duration,
                            cantidadProfesionales: 1,
                          ),
                        );

                        return CheckboxListTile(
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: exists,
                          onChanged: (val) {
                            setState(() {
                              if (val == true && !exists) {
                                seleccionados.add(selected);
                              } else if (val == false) {
                                seleccionados.removeWhere(
                                    (e) => e.servicioId == s.servicioId);
                              }
                            });
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.name),
                              if (exists)
                                DropdownButton<int>(
                                  value: selected.cantidadProfesionales,
                                  onChanged: (val) {
                                    setState(() {
                                      selected.cantidadProfesionales = val!;
                                    });
                                  },
                                  items: List.generate(5, (i) => i + 1)
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text('x$e')))
                                      .toList(),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
