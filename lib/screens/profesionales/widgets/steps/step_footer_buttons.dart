import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class StepFooterButtons extends StatelessWidget {
  final int currentTab;
  final bool guardando;
  final VoidCallback onCancelar;
  final VoidCallback onGuardar;
  final VoidCallback onContinuar;
  final VoidCallback? onAtras;
  final String textoGuardar;

  const StepFooterButtons({
    super.key,
    required this.currentTab,
    required this.guardando,
    required this.onCancelar,
    required this.onGuardar,
    required this.onContinuar,
    required this.textoGuardar,
    this.onAtras,
  });

  @override
  Widget build(BuildContext context) {
    final esUltimoPaso = currentTab == 2;
    final mostrarAtras = currentTab > 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón Cancelar
          TextButton(
            onPressed: guardando ? null : onCancelar,
            child: const Text(
              'Cancelar',
              style: TextStyle(color: kBrandPurple),
            ),
          ),

          // Botones centrales (Atrás / Continuar / Guardar)
          Row(
            children: [
              if (mostrarAtras)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: OutlinedButton(
                    onPressed: guardando ? null : onAtras,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kBrandPurple,
                      side: const BorderSide(color: kBrandPurple),
                    ),
                    child: const Text('Atrás'),
                  ),
                ),
              ElevatedButton(
                onPressed:
                    guardando ? null : (esUltimoPaso ? onGuardar : onContinuar),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandPurple,
                  foregroundColor: Colors.white,
                ),
                child: Text(esUltimoPaso ? textoGuardar : 'Continuar'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
