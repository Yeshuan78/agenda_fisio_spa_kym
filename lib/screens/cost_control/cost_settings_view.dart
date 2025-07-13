// [cost_settings_view.dart] - VISTA DE CONFIGURACIÓN DEL SISTEMA DE CONTROL DE COSTOS
// 📁 Ubicación: /lib/screens/cost_control/cost_settings_view.dart
// 🎯 OBJETIVO: Configuración completa del sistema con todas las opciones avanzadas

import 'package:flutter/material.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';
import '../../services/cost_control/background_cost_monitor.dart';
import '../../services/cost_control/cost_data_models.dart';
import '../../widgets/cost_control/cost_alert_overlay.dart';

class CostSettingsView extends StatefulWidget {
  final BackgroundCostMonitor costMonitor;

  const CostSettingsView({
    super.key,
    required this.costMonitor,
  });

  @override
  State<CostSettingsView> createState() => _CostSettingsViewState();
}

class _CostSettingsViewState extends State<CostSettingsView> {
  late CostSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.costMonitor.settings;
  }

  void _updateSetting(CostSettings newSettings) {
    setState(() => _settings = newSettings);
    widget.costMonitor.updateSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModeControlSection(),
          const SizedBox(height: 24),
          _buildLimitsSection(),
          const SizedBox(height: 24),
          _buildSmartHoursSection(),
          const SizedBox(height: 24),
          _buildFeaturesSection(),
          const SizedBox(height: 24),
          _buildNotificationsSection(),
          const SizedBox(height: 24),
          _buildDangerZone(),
        ],
      ),
    );
  }

  Widget _buildModeControlSection() {
    return AnimatedBuilder(
      animation: widget.costMonitor,
      builder: (context, child) {
        final currentMode = widget.costMonitor.currentStats.currentMode;

        return _buildSection(
          'Control de Modo',
          'Cambiar entre Manual, Live y Burst según necesidades',
          Icons.toggle_on,
          kBrandPurple,
          [
            _buildModeSelector(currentMode),
            const SizedBox(height: 12),
            _buildModeDescription(currentMode),
            const SizedBox(height: 16),
            _buildModeActionButtons(currentMode),
          ],
        );
      },
    );
  }

  Widget _buildModeSelector(String currentMode) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
                'manual', 'Manual', Icons.pan_tool, currentMode),
          ),
          const SizedBox(width: 4),
          Expanded(
            child:
                _buildModeButton('live', 'Live', Icons.flash_on, currentMode),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildModeButton('burst', 'Burst', Icons.speed, currentMode),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
      String mode, String label, IconData icon, String currentMode) {
    final isActive = currentMode == mode;
    final color = _getModeColor(mode);

    return GestureDetector(
      onTap: () => _changeModeWithConfirmation(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeDescription(String currentMode) {
    String description;
    Color color;
    IconData icon;

    switch (currentMode) {
      case 'live':
        description =
            '⚡ Modo Live activo - Datos en tiempo real. Mayor costo pero información siempre actualizada.';
        color = Colors.blue.shade600;
        icon = Icons.flash_on;
        break;
      case 'burst':
        description =
            '🚀 Modo Burst activo - Live temporal por 5 minutos. Balance entre tiempo real y costo.';
        color = Colors.orange.shade600;
        icon = Icons.speed;
        break;
      default:
        description =
            '🖐️ Modo Manual activo - Cargas bajo demanda. Máximo ahorro, control total del usuario.';
        color = kAccentGreen;
        icon = Icons.pan_tool;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: color,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeActionButtons(String currentMode) {
    return Row(
      children: [
        if (currentMode != 'manual')
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _changeModeWithConfirmation('manual'),
              icon: const Icon(Icons.pan_tool, size: 16),
              label: const Text('Cambiar a Manual'),
              style: OutlinedButton.styleFrom(
                foregroundColor: kAccentGreen,
                side: const BorderSide(color: kAccentGreen),
              ),
            ),
          ),
        if (currentMode != 'manual') const SizedBox(width: 12),
        if (currentMode == 'manual')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _changeModeWithConfirmation('live'),
              icon: const Icon(Icons.flash_on, size: 16),
              label: const Text('Activar Live'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        if (currentMode == 'manual') const SizedBox(width: 12),
        if (_settings.enableBurstMode)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _changeModeWithConfirmation('burst'),
              icon: const Icon(Icons.speed, size: 16),
              label: const Text('Modo Burst'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  void _changeModeWithConfirmation(String newMode) {
    if (newMode == 'live') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('⚡ Activar Modo Live'),
          content: const Text(
              'El Modo Live aumentará los costos significativamente. '
              '¿Estás seguro de activarlo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.costMonitor.setMode('live');
                CostAlertOverlay.showInfoSnackbar(
                  context,
                  message: '⚡ Modo Live activado',
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600),
              child:
                  const Text('Activar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      widget.costMonitor.setMode(newMode);
      final modeNames = {'manual': 'Manual', 'burst': 'Burst'};
      CostAlertOverlay.showInfoSnackbar(
        context,
        message: '🔄 Modo ${modeNames[newMode]} activado',
      );
    }
  }

  Color _getModeColor(String mode) {
    switch (mode) {
      case 'live':
        return Colors.blue.shade600;
      case 'burst':
        return Colors.orange.shade600;
      case 'manual':
      default:
        return kAccentGreen;
    }
  }

  Widget _buildLimitsSection() {
    return _buildSection(
      'Límites de Uso',
      'Configurar límites diarios y semanales',
      Icons.speed,
      kAccentBlue,
      [
        _buildSliderSetting(
          'Límite Diario de Lecturas',
          _settings.customDailyLimit.toDouble(),
          50.0,
          200.0,
          (value) => _updateSetting(
              _settings.copyWith(customDailyLimit: value.round())),
          suffix: ' lecturas',
        ),
        _buildSliderSetting(
          'Límite Semanal de Lecturas',
          _settings.customWeeklyLimit.toDouble(),
          200.0,
          1000.0,
          (value) => _updateSetting(
              _settings.copyWith(customWeeklyLimit: value.round())),
          suffix: ' lecturas',
        ),
        _buildInfoCard(
          '💡 Los límites ayudan a controlar automáticamente el gasto en Firestore. '
          'Cuando se alcanzan, el sistema sugiere cambiar a modo Manual.',
        ),
      ],
    );
  }

  Widget _buildSmartHoursSection() {
    return _buildSection(
      'Horarios Inteligentes',
      'Auto-desactivar Live Mode fuera de horario laboral',
      Icons.schedule,
      Colors.orange.shade600,
      [
        _buildSwitchSetting(
          'Activar Horarios Inteligentes',
          'Desactiva automáticamente el Live Mode fuera del horario configurado',
          _settings.enableSmartHours,
          (value) =>
              _updateSetting(_settings.copyWith(enableSmartHours: value)),
        ),
        if (_settings.enableSmartHours) ...[
          const SizedBox(height: 16),
          _buildTimePickerSetting(
            'Hora de Inicio',
            _settings.workStartHour,
            (hour) => _updateSetting(_settings.copyWith(workStartHour: hour)),
          ),
          _buildTimePickerSetting(
            'Hora de Fin',
            _settings.workEndHour,
            (hour) => _updateSetting(_settings.copyWith(workEndHour: hour)),
          ),
          _buildInfoCard(
            '⏰ Fuera de este horario, el Live Mode se desactivará automáticamente '
            'para evitar costos innecesarios.',
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return _buildSection(
      'Funcionalidades Avanzadas',
      'Activar o desactivar características especiales',
      Icons.tune,
      kBrandPurple,
      [
        _buildSwitchSetting(
          'Modo Burst',
          'Permite activar Live Mode temporal con auto-desactivación',
          _settings.enableBurstMode,
          (value) => _updateSetting(_settings.copyWith(enableBurstMode: value)),
        ),
        _buildSwitchSetting(
          'Detección de Shake',
          'Refresh rápido moviendo el dispositivo',
          _settings.enableShakeGesture,
          (value) =>
              _updateSetting(_settings.copyWith(enableShakeGesture: value)),
        ),
        _buildSwitchSetting(
          'Mostrar Badge de Costos',
          'Indicador flotante en la esquina de la agenda',
          _settings.showCostBadge,
          (value) => _updateSetting(_settings.copyWith(showCostBadge: value)),
        ),
        _buildInfoCard(
          '🚀 El Modo Burst permite sesiones de trabajo intensivo con Live Mode '
          'que se desactiva automáticamente después de 5 minutos.',
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _buildSection(
      'Notificaciones',
      'Alertas y avisos del sistema',
      Icons.notifications,
      kAccentGreen,
      [
        _buildSwitchSetting(
          'Notificaciones Activas',
          'Recibir alertas cuando se alcancen límites',
          _settings.enableNotifications,
          (value) =>
              _updateSetting(_settings.copyWith(enableNotifications: value)),
        ),
        _buildInfoCard(
          '🔔 Las notificaciones te alertarán cuando te acerques a los límites '
          'configurados o cuando ocurran eventos importantes.',
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text(
                'Zona de Peligro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Acciones irreversibles que afectarán tus estadísticas y configuración.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showResetDialog,
              icon: const Icon(Icons.refresh),
              label: const Text('Resetear Estadísticas'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                side: BorderSide(color: Colors.red.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    String description,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: kAccentGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    String suffix = '',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${value.round()}$suffix',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 10).round(),
            onChanged: onChanged,
            activeColor: kBrandPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerSetting(
    String title,
    int hour,
    Function(int) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: hour, minute: 0),
              );
              if (time != null) {
                onChanged(time.hour);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kBrandPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kBrandPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Resetear Estadísticas'),
        content: const Text(
          'Esta acción eliminará todas las estadísticas de uso y costos acumulados. '
          'No podrás deshacer esta acción. ¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.costMonitor.resetStats();
              CostAlertOverlay.showInfoSnackbar(
                context,
                message: '📊 Estadísticas reseteadas correctamente',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Resetear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
