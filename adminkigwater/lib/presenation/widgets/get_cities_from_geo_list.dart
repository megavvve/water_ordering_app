import 'package:adminkigwater/domain/entities/geolocation.dart';

List<String> getCitiesFromGeoList(List<Geolocation> geolocationList) {
  List<String> result = [];
  for (final Geolocation geolocation in geolocationList) {
    if (geolocation.address.isNotEmpty) {
      final addressParts = geolocation.address.split(',');
      if (addressParts.length >= 3) {
        if (addressParts[1].toLowerCase().contains('область') ||
            addressParts[1].toLowerCase().contains('регион') ||
            addressParts[1].toLowerCase().contains('республика')||
            addressParts[1].toLowerCase().contains('край') ||
            addressParts[1].toLowerCase().contains('автономный округ') ||
            addressParts[1].toLowerCase().contains('ао') 
            ) {
          result.add(
              '${addressParts[0].trim()}, ${addressParts[1].trim()}, ${addressParts[2].trim()}');
        } else {
          result.add('${addressParts[0].trim()}, ${addressParts[1].trim()}');
        }
      } else if (addressParts.length == 2) {
        result.add('${addressParts[0].trim()}, ${addressParts[1].trim()}');
      }
    }
    result.add("Город не указан");
  }

  result.insert(0, 'Все города');
  return result.toSet().toList();
}
