/// Espejo en codigo de los recintos/mesas precargados en Supabase
/// (ver supabase/seed.sql). Sirve como referencia y para pruebas.
class RecintoSeed {
  final String id;
  final String provincia;
  final String canton;
  final String parroquia;
  final String nombre;
  final List<int> mesas;

  const RecintoSeed({
    required this.id,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    required this.nombre,
    required this.mesas,
  });
}

const List<RecintoSeed> kRecintosSeed = [
  RecintoSeed(
    id: 'a1111111-1111-1111-1111-111111110001',
    provincia: 'Pichincha',
    canton: 'Quito',
    parroquia: 'Calderon',
    nombre: 'Unidad Educativa Calderon',
    mesas: [1, 2, 3, 4],
  ),
  RecintoSeed(
    id: 'a1111111-1111-1111-1111-111111110002',
    provincia: 'Pichincha',
    canton: 'Quito',
    parroquia: 'Tumbaco',
    nombre: 'Escuela Tumbaco Central',
    mesas: [1, 2, 3, 4],
  ),
  RecintoSeed(
    id: 'a1111111-1111-1111-1111-111111110003',
    provincia: 'Pichincha',
    canton: 'Quito',
    parroquia: 'Quitumbe',
    nombre: 'Colegio Quitumbe',
    mesas: [1, 2, 3, 4],
  ),
  RecintoSeed(
    id: 'a1111111-1111-1111-1111-111111110004',
    provincia: 'Pichincha',
    canton: 'Quito',
    parroquia: 'Carcelen',
    nombre: 'Unidad Educativa Carcelen',
    mesas: [1, 2, 3, 4],
  ),
  RecintoSeed(
    id: 'a1111111-1111-1111-1111-111111110005',
    provincia: 'Pichincha',
    canton: 'Quito',
    parroquia: 'Conocoto',
    nombre: 'Escuela Conocoto',
    mesas: [1, 2, 3, 4],
  ),
];
