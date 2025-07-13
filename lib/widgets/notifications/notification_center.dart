// [notification_center.dart]
// 📁 Ubicación: /lib/widgets/notifications/notification_center.dart
// 🚀 NOTIFICATION CENTER PREMIUM - SIN ÍNDICES COMPLEJOS FIRESTORE

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_fisio_spa_kym/theme/theme.dart';

class NotificationCenter extends StatefulWidget {
  final Function(String)? onNavigate;
  final VoidCallback? onClose;

  const NotificationCenter({
    super.key,
    this.onNavigate,
    this.onClose,
  });

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter>
    with TickerProviderStateMixin {
  // ✅ ANIMATION CONTROLLERS
  late AnimationController _slideController;
  late AnimationController _staggerController;
  late AnimationController _badgeController;

  // ✅ ANIMATIONS
  late Animation<Offset> _slideAnimation;
  late Animation<double> _staggerAnimation;
  late Animation<double> _badgeAnimation;

  // ✅ STATE
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadNotifications();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // ✅ SLIDE IN ANIMATION
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // ✅ STAGGER ANIMATION PARA ITEMS
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _staggerAnimation = CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeOut,
    );

    // ✅ BADGE PULSE ANIMATION
    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _badgeAnimation = CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeInOut,
    );
    _badgeController.repeat(reverse: true);
  }

  void _startAnimationSequence() async {
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _staggerController.forward();
  }

  // ✅ LOAD NOTIFICATIONS SIN ÍNDICES COMPLEJOS
  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    try {
      final notifications = <NotificationItem>[];

      // ✅ 1. EVENTOS PRÓXIMOS (CONSULTA SIMPLE)
      await _getEventosProximos(notifications);

      // ✅ 2. CITAS RECIENTES (CONSULTA SIMPLE)
      await _getCitasRecientes(notifications);

      // ✅ 3. REGISTROS RECIENTES (SIN COLLECTION GROUP)
      await _getRegistrosRecientes(notifications);

      // ✅ 4. NOTIFICACIONES DEL SISTEMA (SIMULADAS)
      _getSistemaNotifications(notifications);

      // ✅ ORDENAR Y LIMITAR
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final limitedNotifications = notifications.take(15).toList();

      // ✅ CONTAR NO LEÍDAS
      final unread = limitedNotifications.where((n) => !n.isRead).length;

      setState(() {
        _notifications = limitedNotifications;
        _unreadCount = unread;
        _isLoading = false;
      });

      debugPrint(
          '✅ Notificaciones cargadas: ${_notifications.length} total, $unread no leídas');
    } catch (e) {
      debugPrint('❌ Error loading notifications: $e');
      setState(() => _isLoading = false);
    }
  }

  // ✅ EVENTOS PRÓXIMOS - CONSULTA SIMPLE
  Future<void> _getEventosProximos(List<NotificationItem> notifications) async {
    try {
      final eventosSnapshot = await FirebaseFirestore.instance
          .collection('eventos')
          .where('estado', isEqualTo: 'activo') // ✅ CONSULTA SIMPLE
          .limit(5)
          .get();

      for (var doc in eventosSnapshot.docs) {
        final data = doc.data();
        final nombre = data['nombre'] ?? 'Evento';
        final empresa = data['empresa'] ?? 'Empresa';
        final fecha = data['fecha'];

        // ✅ VERIFICAR SI ES PRÓXIMO (EN MEMORIA)
        if (fecha is Timestamp) {
          final fechaEvento = fecha.toDate();
          final ahora = DateTime.now();
          final diferencia = fechaEvento.difference(ahora).inDays;

          if (diferencia >= 0 && diferencia <= 7) {
            // Próximos 7 días
            notifications.add(NotificationItem(
              id: doc.id,
              title: 'Evento Próximo',
              message: '$nombre - $empresa',
              type: NotificationType.event,
              timestamp: fechaEvento,
              isRead: false,
              actionRoute: '/eventos',
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error getting eventos próximos: $e');
    }
  }

  // ✅ CITAS RECIENTES - CONSULTA SIMPLE
  Future<void> _getCitasRecientes(List<NotificationItem> notifications) async {
    try {
      // Intentar múltiples nombres de colección
      for (String collectionName in ['citas', 'appointments', 'bookings']) {
        try {
          final citasSnapshot = await FirebaseFirestore.instance
              .collection(collectionName)
              .orderBy('fecha', descending: true) // ✅ ORDEN SIMPLE
              .limit(3)
              .get();

          if (citasSnapshot.docs.isNotEmpty) {
            for (var doc in citasSnapshot.docs) {
              final data = doc.data();
              final clienteNombre =
                  data['clienteNombre'] ?? data['cliente'] ?? 'Cliente';
              final hora = data['hora'] ?? '00:00';

              notifications.add(NotificationItem(
                id: doc.id,
                title: 'Cita Programada',
                message: '$clienteNombre - $hora',
                type: NotificationType.appointment,
                timestamp: (data['fecha'] as Timestamp).toDate(),
                isRead: false,
                actionRoute: '/agenda/semanal',
              ));
            }
            break; // Si encontramos citas, no seguir buscando
          }
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error getting citas: $e');
    }
  }

  // ✅ REGISTROS RECIENTES - SIN COLLECTION GROUP
  Future<void> _getRegistrosRecientes(
      List<NotificationItem> notifications) async {
    try {
      // ✅ OBTENER EVENTOS PRIMERO (CONSULTA SIMPLE)
      final eventosSnapshot = await FirebaseFirestore.instance
          .collection('eventos')
          .orderBy('fecha', descending: true)
          .limit(3)
          .get();

      // ✅ PARA CADA EVENTO, BUSCAR SUS REGISTROS
      for (var eventoDoc in eventosSnapshot.docs) {
        try {
          final registrosSnapshot = await FirebaseFirestore.instance
              .collection('eventos')
              .doc(eventoDoc.id)
              .collection('registros')
              .orderBy('timestamp', descending: true) // ✅ ORDEN SIMPLE
              .limit(2)
              .get();

          for (var doc in registrosSnapshot.docs) {
            final data = doc.data();
            final servicioNombre = data['servicioNombre'] ?? 'Servicio';
            final profesionalNombre =
                data['profesionalNombre'] ?? 'Profesional';
            final encuesta = data['encuesta'];

            if (encuesta != null) {
              notifications.add(NotificationItem(
                id: doc.id,
                title: 'Nueva Encuesta',
                message: '$servicioNombre con $profesionalNombre',
                type: NotificationType.survey,
                timestamp: (data['timestamp'] as Timestamp).toDate(),
                isRead: false,
                actionRoute: '/kympulse',
              ));
            } else {
              notifications.add(NotificationItem(
                id: doc.id,
                title: 'Nuevo Registro',
                message: '$servicioNombre completado',
                type: NotificationType.professional,
                timestamp: (data['timestamp'] as Timestamp).toDate(),
                isRead: false,
                actionRoute: '/eventos',
              ));
            }
          }
        } catch (e) {
          debugPrint(
              '⚠️ Error leyendo registros del evento ${eventoDoc.id}: $e');
          continue;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error getting registros: $e');
    }
  }

  // ✅ NOTIFICACIONES DEL SISTEMA (SIMULADAS)
  void _getSistemaNotifications(List<NotificationItem> notifications) {
    final ahora = DateTime.now();

    notifications.addAll([
      NotificationItem(
        id: 'system_backup',
        title: 'Respaldo Completado',
        message: 'Respaldo automático realizado exitosamente',
        type: NotificationType.system,
        timestamp: ahora.subtract(const Duration(hours: 2)),
        isRead: true,
        actionRoute: '/admin',
      ),
      NotificationItem(
        id: 'system_update',
        title: 'Métricas Actualizadas',
        message: 'Dashboard KYM Pulse actualizado',
        type: NotificationType.system,
        timestamp: ahora.subtract(const Duration(minutes: 30)),
        isRead: false,
        actionRoute: '/kympulse',
      ),
      NotificationItem(
        id: 'system_welcome',
        title: '¡Bienvenido a KYM!',
        message: 'Tu CRM premium está listo para usar',
        type: NotificationType.system,
        timestamp: ahora.subtract(const Duration(days: 1)),
        isRead: false,
        actionRoute: '/kympulse',
      ),
    ]);
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      }
    });
    HapticFeedback.lightImpact();
  }

  void _markAllAsRead() {
    setState(() {
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
    });
    HapticFeedback.mediumImpact();
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notificationId);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    });
    HapticFeedback.lightImpact();
  }

  void _handleNotificationTap(NotificationItem notification) {
    _markAsRead(notification.id);

    if (notification.actionRoute != null) {
      widget.onNavigate?.call(notification.actionRoute!);
    }

    widget.onClose?.call();
  }

  void _close() {
    _slideController.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _staggerController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: _close,
        child: Container(
          color: Colors.black.withValues(alpha: 0.03),
          child: GestureDetector(
            onTap: () {}, // Prevent close on panel tap
            child: Align(
              alignment: Alignment.topRight,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildNotificationPanel(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationPanel() {
    return Container(
      width: 380,
      height: MediaQuery.of(context).size.height,
      margin: const EdgeInsets.only(top: 70), // Below toolbar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child:
                _isLoading ? _buildLoadingState() : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kBrandPurple.withValues(alpha: 0.008),
            kAccentBlue.withValues(alpha: 0.004),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kBrandPurple, kAccentBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: AnimatedBuilder(
                          animation: _badgeAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.9 + (_badgeAnimation.value * 0.2),
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notificaciones',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kBrandPurple,
                      ),
                    ),
                    Text(
                      'Manténte al día con tu CRM',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _close,
                icon: const Icon(
                  Icons.close,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ],
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _markAllAsRead,
                icon: const Icon(
                  Icons.done_all,
                  size: 16,
                ),
                label: const Text('Marcar todas como leídas'),
                style: TextButton.styleFrom(
                  foregroundColor: kBrandPurple,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final delay = index * 0.1;

        return AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            final animationValue = Curves.easeOut.transform(
                ((_staggerAnimation.value - delay).clamp(0.0, 1.0) /
                        (1.0 - delay))
                    .clamp(0.0, 1.0));

            return Transform.translate(
              offset: Offset(50 * (1 - animationValue), 0),
              child: Opacity(
                opacity: animationValue,
                child: _buildNotificationItem(notification, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, int index) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _handleNotificationTap(notification),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: notification.isRead
                    ? Colors.grey.shade50
                    : kBrandPurple.withValues(alpha: 0.005),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: notification.isRead
                      ? Colors.grey.shade200
                      : kBrandPurple.withValues(alpha: 0.02),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // ✅ ICON POR TIPO
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getNotificationColors(notification.type),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ✅ CONTENT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: notification.isRead
                                      ? Colors.grey.shade700
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: kBrandPurple,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ ARROW
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kBrandPurple.withValues(alpha: 0.01),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: kBrandPurple.withValues(alpha: 0.05),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Todas las notificaciones aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Color> _getNotificationColors(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return [kAccentBlue, kAccentBlue.withValues(alpha: 0.08)];
      case NotificationType.survey:
        return [kAccentGreen, kAccentGreen.withValues(alpha: 0.08)];
      case NotificationType.event:
        return [kBrandPurple, kBrandPurple.withValues(alpha: 0.08)];
      case NotificationType.professional:
        return [Colors.orange, Colors.orange.withValues(alpha: 0.08)];
      case NotificationType.system:
        return [Colors.grey.shade600, Colors.grey.shade500];
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.survey:
        return Icons.star;
      case NotificationType.event:
        return Icons.event;
      case NotificationType.professional:
        return Icons.person;
      case NotificationType.system:
        return Icons.settings;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }
}

// ✅ NOTIFICATION MODELS
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.actionRoute,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? actionRoute,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }
}

enum NotificationType {
  appointment,
  survey,
  event,
  professional,
  system,
}
