// [Sección 4.1] - Imports y función principal
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

Future<void> showScheduleBlockDialog({
  required BuildContext context,
  required DateTime slotStart,
  required String profesionalId,
  required Function({
    required String profesionalId,
    required DateTime day,
    required int startHour,
    required int startMin,
    required int endHour,
    required int endMin,
    required String blockName,
  }) onSaveBlock,
  Function()? onAfterSave, // para actualizar calendario después de guardar
}) async {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nombreCtrl = TextEditingController();
  final horaInicio = TimeOfDay(hour: slotStart.hour, minute: slotStart.minute);

  await showDialog(
    context: context,
    builder: (ctx) {
      TimeOfDay? horaFin;

      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Bloquear horario"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('EEEE d MMMM yyyy', 'es_MX').format(slotStart),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nombreCtrl,
                    decoration:
                        const InputDecoration(labelText: "Motivo del bloqueo"),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? "Campo obligatorio"
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: "Hora inicio",
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                              "${horaInicio.format(context)} (${horaInicio.hour}:${horaInicio.minute.toString().padLeft(2, '0')})"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: horaInicio,
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                horaFin = picked;
                              });
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Hora fin",
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              horaFin != null
                                  ? "${horaFin!.format(context)}"
                                  : "Seleccionar",
                            ),
                          ),
                        ),
                      ),
                    ],
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
                style: ElevatedButton.styleFrom(backgroundColor: kBrandPurple),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  if (horaFin == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Selecciona hora de fin")),
                    );
                    return;
                  }

                  final startHour = horaInicio.hour;
                  final startMin = horaInicio.minute;
                  final endHour = horaFin!.hour;
                  final endMin = horaFin!.minute;

                  // [Sección 4.2] - Guardar el bloqueo y refrescar el calendario
                  await onSaveBlock(
                    profesionalId: profesionalId,
                    day: slotStart,
                    startHour: startHour,
                    startMin: startMin,
                    endHour: endHour,
                    endMin: endMin,
                    blockName: nombreCtrl.text.trim(),
                  );

                  if (onAfterSave != null) {
                    onAfterSave();
                  }

                  Navigator.pop(ctx);
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      );
    },
  );
}
