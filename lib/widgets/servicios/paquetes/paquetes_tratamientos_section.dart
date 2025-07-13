// [Sección 1.1] – Imports
import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/models/paquete_model.dart';
import 'package:agenda_fisio_spa_kym/models/tratamiento_model.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/paquetes/paquete_card.dart';
import 'package:agenda_fisio_spa_kym/widgets/servicios/paquetes/tratamiento_card.dart';

// [Sección 1.2] – Widget principal

class PaquetesTratamientosSection extends StatefulWidget {
  final List<PaqueteModel> paquetes;
  final List<TratamientoModel> tratamientos;

  const PaquetesTratamientosSection({
    super.key,
    required this.paquetes,
    required this.tratamientos,
  });

  @override
  State<PaquetesTratamientosSection> createState() =>
      _PaquetesTratamientosSectionState();
}

class _PaquetesTratamientosSectionState
    extends State<PaquetesTratamientosSection> with TickerProviderStateMixin {
  bool paquetesExpandido = false;
  bool tratamientosExpandido = false;
  bool hoverPaquetes = false;
  bool hoverTratamientos = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ PAQUETES
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              left: BorderSide(
                color: Color(0xFFFFC107),
                width: 5,
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              MouseRegion(
                onEnter: (_) => setState(() => hoverPaquetes = true),
                onExit: (_) => setState(() => hoverPaquetes = false),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      paquetesExpandido = !paquetesExpandido;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hoverPaquetes
                          ? const Color(0xFFFFC107).withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.folder, color: Color(0xFFFFC107)),
                        SizedBox(width: 8),
                        Text(
                          'Paquetes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.expand_more, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: paquetesExpandido
                    ? Column(
                        children: [
                          const SizedBox(height: 12),
                          for (var p in widget.paquetes)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PaqueteCard(paquete: p),
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        // ✅ TRATAMIENTOS
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              left: BorderSide(
                color: Color(0xFF8BC34A),
                width: 5,
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              MouseRegion(
                onEnter: (_) => setState(() => hoverTratamientos = true),
                onExit: (_) => setState(() => hoverTratamientos = false),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      tratamientosExpandido = !tratamientosExpandido;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hoverTratamientos
                          ? const Color(0xFF8BC34A).withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.folder, color: Color(0xFF8BC34A)),
                        SizedBox(width: 8),
                        Text(
                          'Tratamientos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.expand_more, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: tratamientosExpandido
                    ? Column(
                        children: [
                          const SizedBox(height: 12),
                          for (var t in widget.tratamientos)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TratamientoCard(tratamiento: t),
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
