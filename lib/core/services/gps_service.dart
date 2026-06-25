import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

class GpsPosition {
  final double latitude;
  final double longitude;
  const GpsPosition(this.latitude, this.longitude);
}

class LocationPermissionException implements Exception {
  final String message;
  LocationPermissionException(this.message);
  @override
  String toString() => message;
}

/// Obtiene la ubicacion del dispositivo. Si el permiso esta denegado,
/// lanza [LocationPermissionException] para que la UI no permita continuar.
@lazySingleton
class GpsService {
  Future<GpsPosition> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationPermissionException(
        'El GPS esta desactivado. Activelo para registrar el acta.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationPermissionException(
        'Permiso de ubicacion denegado. No es posible continuar.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationPermissionException(
        'Permiso de ubicacion denegado permanentemente. '
        'Habilitelo en los ajustes del dispositivo.',
      );
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return GpsPosition(pos.latitude, pos.longitude);
  }
}
