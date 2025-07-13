import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> cargarEstadosDeCita() async {
  final estados = [
    {
      'orden': 1,
      'titulo': 'Te estamos asignando terapeuta',
      'categoria': 'terapia',
    },
    {
      'orden': 1,
      'titulo': 'Te estamos asignando fisioterapeuta',
      'categoria': 'fisioterapia',
    },
    {
      'orden': 1,
      'titulo': 'Te estamos asignando cosmetóloga',
      'categoria': 'cosmetologia',
    },
    {
      'orden': 1,
      'titulo': 'Te estamos asignando podóloga',
      'categoria': 'podologia',
    },
    {'orden': 2, 'titulo': 'Pendiente de pago', 'categoria': null},
    {'orden': 3, 'titulo': 'Cita confirmada', 'categoria': null},
    {'orden': 4, 'titulo': 'Tu terapeuta va en camino', 'categoria': 'terapia'},
    {
      'orden': 4,
      'titulo': 'Tu fisioterapeuta va en camino',
      'categoria': 'fisioterapia',
    },
    {
      'orden': 4,
      'titulo': 'Tu cosmetóloga va en camino',
      'categoria': 'cosmetologia',
    },
    {
      'orden': 4,
      'titulo': 'Tu podóloga va en camino',
      'categoria': 'podologia',
    },
    {
      'orden': 5,
      'titulo': 'Tu terapeuta ha llegado a tu domicilio',
      'categoria': 'terapia',
    },
    {
      'orden': 5,
      'titulo': 'Tu fisioterapeuta ha llegado a tu domicilio',
      'categoria': 'fisioterapia',
    },
    {
      'orden': 5,
      'titulo': 'Tu cosmetóloga ha llegado a tu domicilio',
      'categoria': 'cosmetologia',
    },
    {
      'orden': 5,
      'titulo': 'Tu podóloga ha llegado a tu domicilio',
      'categoria': 'podologia',
    },
    {'orden': 6, 'titulo': 'Cancelado', 'categoria': null},
  ];

  final firestore = FirebaseFirestore.instance;
  final estadosRef = firestore.collection('estados_cita');

  for (final estado in estados) {
    await estadosRef.add({
      'orden': estado['orden'],
      'titulo': estado['titulo'],
      'categoria': estado['categoria'],
      'activo': true,
      'mensajeWhatsapp': '',
      'mensajeCorreo': '',
    });
  }

  print('✅ Estados de cita cargados correctamente en Firestore.');
}
