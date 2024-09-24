import 'package:adminkigwater/domain/entities/geolocation.dart';

abstract class GeolocationRepository {
  Future<void> createGeolocation(String geolocationId);
  Future<void> updateGeolocation(Geolocation geolocation);
  Future<Geolocation?> getGeolocation(String geolocationId);
  Future<List<Geolocation>> getGeolocationsByDelivererIds(
      List<String> delivererIds);
  Future<List<Geolocation>> getGeolocationsByIds(List<String> ids);
}
