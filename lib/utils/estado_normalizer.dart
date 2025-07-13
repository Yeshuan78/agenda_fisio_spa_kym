String normalizarEstadoPlantilla(String estado) {
  final e = estado.toLowerCase().trim();

  const equivalencias = {
    'reservando': 'reservado',
    'reserva': 'reservado',
    'reservado': 'reservado',
    'confirmando': 'confirmado',
    'confirmacion': 'confirmado',
    'confirmada': 'confirmado',
    'confirmado': 'confirmado',
    'cancelada': 'cancelado',
    'cancelando': 'cancelado',
    'cancelado': 'cancelado',
    'en camino': 'en camino',
    'llegamos': 'llegamos',
    'finalizada': 'finalizado',
    'finalizado': 'finalizado',
    'realizada': 'cita_realizada',
    'hecha': 'cita_realizada',
    'recordatorio': 'recordatorio',
    'asignada': 'asignado',
    'asignado': 'asignado',
  };

  return equivalencias[e] ?? e;
}
