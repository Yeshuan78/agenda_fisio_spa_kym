import 'package:flutter/material.dart';
import '../../../models/evento_model.dart';
import '../../../theme/theme.dart';

class PulseCardHeader extends StatelessWidget {
  final EventoModel evento;
  final int totalRegistros;
  final bool isEventoActivo;
  final Animation<double> liveAnimation;
  final Map<String, Map<String, dynamic>> estadosConfig;
  final VoidCallback onEstadoTap;

  const PulseCardHeader({
    super.key,
    required this.evento,
    required this.totalRegistros,
    required this.isEventoActivo,
    required this.liveAnimation,
    required this.estadosConfig,
    required this.onEstadoTap,
  });

  Color _getStatusColor() =>
      estadosConfig[evento.estado]?['color'] ?? Colors.grey;
  IconData _getStatusIcon() =>
      estadosConfig[evento.estado]?['icon'] ?? Icons.event;
  String _getStatusLabel() =>
      estadosConfig[evento.estado]?['label'] ?? evento.estado;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // ✅ FONDO GLASSMORPHISM ELEGANTE
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStatusColor().withValues(alpha: 0.08),
            _getStatusColor().withValues(alpha: 0.03),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: _getStatusColor().withValues(alpha: 0.2),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          // ✅ AVATAR GLASSMORPHISM
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.3),
                  _getStatusColor().withValues(alpha: 0.2),
                  _getStatusColor().withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.9),
                  blurRadius: 10,
                  spreadRadius: -2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Icon(
              isEventoActivo ? Icons.play_circle_fill : Icons.event_available,
              color: _getStatusColor(),
              size: 32,
            ),
          ),

          const SizedBox(width: 20),

          // ✅ INFORMACIÓN PRINCIPAL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.nombre,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: kFontFamily,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: kBrandPurple,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kBrandPurple.withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        evento.empresa,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildGlassMorphChip(
                      Icons.calendar_today,
                      '${evento.fecha.day.toString().padLeft(2, '0')}/${evento.fecha.month.toString().padLeft(2, '0')}/${evento.fecha.year}',
                      kAccentBlue,
                    ),
                    _buildGlassMorphChip(
                      Icons.location_on,
                      evento.ubicacion,
                      kAccentGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ BADGE DE ESTADO GLASSMORPHISM + SELECTOR
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onEstadoTap,
                child: AnimatedBuilder(
                  animation: liveAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isEventoActivo ? liveAnimation.value : 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getStatusColor().withValues(alpha: 0.9),
                              _getStatusColor().withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor().withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.8),
                              blurRadius: 8,
                              spreadRadius: -2,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isEventoActivo) ...[
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.white.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Icon(_getStatusIcon(),
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _getStatusLabel().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.8),
                      kAccentGreen.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: kAccentGreen.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kAccentGreen.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.analytics, size: 18, color: kAccentGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Total: $totalRegistros',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kAccentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassMorphChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.6),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}