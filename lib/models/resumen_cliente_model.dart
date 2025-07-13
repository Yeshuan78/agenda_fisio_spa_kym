// 📁 models/resumen_cliente_model.dart
class ResumenCliente {
  final int asistidas;
  final int noAsistidas;
  final int pendientes;
  final DateTime? ultimaCita;
  final List<Map<String, dynamic>> detalleUltimasCitas;

  ResumenCliente({
    required this.asistidas,
    required this.noAsistidas,
    required this.pendientes,
    required this.ultimaCita,
    required this.detalleUltimasCitas,
  });
}
