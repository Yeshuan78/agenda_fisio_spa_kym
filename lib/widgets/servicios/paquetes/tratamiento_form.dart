import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/servicio_model.dart';
import 'package:agenda_fisio_spa_kym/models/tratamiento_model.dart';
import 'package:agenda_fisio_spa_kym/models/categoria_model.dart';
import 'package:agenda_fisio_spa_kym/services/categoria_service.dart';

class TratamientoForm extends StatefulWidget {
  final List<ServicioModel> serviciosDisponibles;
  final void Function(TratamientoModel) onGuardar;

  const TratamientoForm({
    super.key,
    required this.serviciosDisponibles,
    required this.onGuardar,
  });

  @override
  State<TratamientoForm> createState() => _TratamientoFormState();
}

class ServicioTratamientoSeleccionado {
  final String servicioId;
  int cantidadSesiones;
  ServicioTratamientoSeleccionado(
      {required this.servicioId, this.cantidadSesiones = 1});
}

class _TratamientoFormState extends State<TratamientoForm> {
  final _formKey = GlobalKey<FormState>();
  String nombre = '';
  double precio = 0;
  List<CategoriaModel> categorias = [];
  List<ServicioTratamientoSeleccionado> seleccionados = [];

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
      List<TratamientoSesion> sesionesTotales = [];
      for (var s in seleccionados) {
        for (int i = 0; i < s.cantidadSesiones; i++) {
          sesionesTotales.add(
            TratamientoSesion(
              numero: sesionesTotales.length + 1,
              servicioId: s.servicioId,
              profesionalId: null,
              fecha: null,
              estado: 'pendiente',
            ),
          );
        }
      }

      final tratamiento = TratamientoModel(
        tratamientoId: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: nombre,
        sesiones: sesionesTotales,
        precioTotal: precio,
      );

      widget.onGuardar(tratamiento);
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
      title: const Text('Nuevo Tratamiento'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          height: 600,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Nombre del tratamiento'),
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
                const Text('Selecciona servicios y sesiones:',
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
                        final isSelected = seleccionados
                            .any((e) => e.servicioId == s.servicioId);
                        final seleccion = seleccionados
                            .where((e) => e.servicioId == s.servicioId)
                            .firstOrNull;
                        return CheckboxListTile(
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                seleccionados.add(
                                    ServicioTratamientoSeleccionado(
                                        servicioId: s.servicioId));
                              } else {
                                seleccionados.removeWhere(
                                    (e) => e.servicioId == s.servicioId);
                              }
                            });
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.name),
                              if (isSelected)
                                DropdownButton<int>(
                                  value: seleccion?.cantidadSesiones ?? 1,
                                  onChanged: (val) {
                                    setState(() {
                                      seleccion?.cantidadSesiones = val ?? 1;
                                    });
                                  },
                                  items: List.generate(10, (i) => i + 1)
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text('$e')))
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
