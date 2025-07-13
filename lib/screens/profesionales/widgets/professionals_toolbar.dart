import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/professional_model.dart';
import 'package:agenda_fisio_spa_kym/screens/profesionales/widgets/professional_crud_dialog.dart';

class ProfessionalsToolbar extends StatelessWidget {
  final Function(String) onSearchChanged;
  final Function(String?) onCategoriaFiltrada;
  final VoidCallback onRecargar;
  final List<Map<String, dynamic>> serviciosDisponibles;

  const ProfessionalsToolbar({
    super.key,
    required this.onSearchChanged,
    required this.onCategoriaFiltrada,
    required this.onRecargar,
    required this.serviciosDisponibles,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: null,
            hint: const Text('Filtrar por categoría'),
            onChanged: onCategoriaFiltrada,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Todas'),
              ),
              ...{for (var s in serviciosDisponibles) s['category']}
                  .toSet()
                  .map(
                    (categoria) => DropdownMenuItem(
                      value: categoria,
                      child: Text(categoria),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          heroTag: 'addProFAB',
          backgroundColor:
              Colors.deepPurple, // usa el color de tu theme si lo defines
          onPressed: () async {
            final creado = await showDialog(
              context: context,
              builder: (_) => ProfessionalCrudDialog(
                serviciosDisponibles: serviciosDisponibles,
              ),
            );
            if (creado == true) onRecargar();
          },
          elevation: 2,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }
}
