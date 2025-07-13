// [slot_options_menu.dart]
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class SlotOptionsMenu extends StatelessWidget {
  final DateTime timeSlot;
  final String resourceId;
  final Function(DateTime, String) onCreateAppointment;
  final Function(DateTime, DateTime, String) onCreateBlock;
  final int intervalMinutes;

  const SlotOptionsMenu({
    super.key,
    required this.timeSlot,
    required this.resourceId,
    required this.onCreateAppointment,
    required this.onCreateBlock,
    this.intervalMinutes = 60,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime timeSlot,
    required String resourceId,
    required Function(DateTime, String) onCreateAppointment,
    required Function(DateTime, DateTime, String) onCreateBlock,
    int intervalMinutes = 60,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SlotOptionsMenu(
        timeSlot: timeSlot,
        resourceId: resourceId,
        onCreateAppointment: onCreateAppointment,
        onCreateBlock: onCreateBlock,
        intervalMinutes: intervalMinutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Opciones del slot',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800)),
                const SizedBox(height: 8),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(timeSlot),
                    style:
                        TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                const SizedBox(height: 24),
                _buildSlotOption(
                  context,
                  icon: Icons.add_box,
                  title: 'Crear cita',
                  subtitle: 'Agendar nueva cita',
                  color: kAccentGreen,
                  onTap: () {
                    Navigator.pop(context);
                    onCreateAppointment(timeSlot, resourceId);
                  },
                ),
                const SizedBox(height: 12),
                _buildSlotOption(
                  context,
                  icon: Icons.block,
                  title: 'Bloquear horario',
                  subtitle: 'Marcar como no disponible',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    final endDateTime =
                        timeSlot.add(Duration(minutes: intervalMinutes));
                    onCreateBlock(timeSlot, endDateTime, resourceId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
