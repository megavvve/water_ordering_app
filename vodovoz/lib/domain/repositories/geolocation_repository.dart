import 'package:vodovoz/domain/entities/geolocation.dart';

abstract class GeolocationRepository {
  Future<void> createGeolocation(String geolocationId);
  Future<void> updateGeolocation(Geolocation geolocation);
  Future<Geolocation?> getGeolocation(String geolocationId);
  Future<List<Geolocation>> getGeolocationsByDelivererIds(
      List<String> delivererIds);
}
