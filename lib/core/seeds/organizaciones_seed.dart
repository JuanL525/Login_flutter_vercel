import '../constants/enums.dart';

/// Organizacion politica precargada (dato quemado).
class OrganizacionPolitica {
  final String id;
  final String nombre;
  final String lista;
  final String candidato;
  final Dignidad dignidad;

  const OrganizacionPolitica({
    required this.id,
    required this.nombre,
    required this.lista,
    required this.candidato,
    required this.dignidad,
  });
}

/// 5 organizaciones para la dignidad de ALCALDE.
const List<OrganizacionPolitica> kOrganizacionesAlcaldia = [
  OrganizacionPolitica(
    id: 'alc_1',
    nombre: 'Movimiento Union Ciudadana',
    lista: 'Lista 1',
    candidato: 'Andrea Vaca',
    dignidad: Dignidad.alcalde,
  ),
  OrganizacionPolitica(
    id: 'alc_2',
    nombre: 'Frente Progreso Quiteno',
    lista: 'Lista 7',
    candidato: 'Marco Riofrio',
    dignidad: Dignidad.alcalde,
  ),
  OrganizacionPolitica(
    id: 'alc_3',
    nombre: 'Alianza Capital',
    lista: 'Lista 12',
    candidato: 'Sofia Naranjo',
    dignidad: Dignidad.alcalde,
  ),
  OrganizacionPolitica(
    id: 'alc_4',
    nombre: 'Movimiento Ciudad Viva',
    lista: 'Lista 21',
    candidato: 'Diego Salas',
    dignidad: Dignidad.alcalde,
  ),
  OrganizacionPolitica(
    id: 'alc_5',
    nombre: 'Partido Renovacion',
    lista: 'Lista 35',
    candidato: 'Veronica Cisneros',
    dignidad: Dignidad.alcalde,
  ),
];

/// 5 organizaciones para la dignidad de PREFECTO.
const List<OrganizacionPolitica> kOrganizacionesPrefectura = [
  OrganizacionPolitica(
    id: 'pre_1',
    nombre: 'Pichincha Unida',
    lista: 'Lista 2',
    candidato: 'Ramiro Paez',
    dignidad: Dignidad.prefecto,
  ),
  OrganizacionPolitica(
    id: 'pre_2',
    nombre: 'Movimiento Provincia Activa',
    lista: 'Lista 8',
    candidato: 'Lucia Mena',
    dignidad: Dignidad.prefecto,
  ),
  OrganizacionPolitica(
    id: 'pre_3',
    nombre: 'Frente Rural Pichincha',
    lista: 'Lista 15',
    candidato: 'Jorge Tapia',
    dignidad: Dignidad.prefecto,
  ),
  OrganizacionPolitica(
    id: 'pre_4',
    nombre: 'Alianza Desarrollo',
    lista: 'Lista 23',
    candidato: 'Paola Erazo',
    dignidad: Dignidad.prefecto,
  ),
  OrganizacionPolitica(
    id: 'pre_5',
    nombre: 'Movimiento Futuro',
    lista: 'Lista 40',
    candidato: 'Esteban Lara',
    dignidad: Dignidad.prefecto,
  ),
];

List<OrganizacionPolitica> organizacionesPorDignidad(Dignidad dignidad) {
  return dignidad == Dignidad.alcalde
      ? kOrganizacionesAlcaldia
      : kOrganizacionesPrefectura;
}
