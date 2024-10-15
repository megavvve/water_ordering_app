import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/utils/constants.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class GeoService {
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    final url =
        'https://geocode-maps.yandex.ru/1.x/?apikey=$apiKeyForYandexMaps&geocode=$lng,$lat&format=json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['response']['GeoObjectCollection']['featureMember'][0]
          ['GeoObject']['metaDataProperty']['GeocoderMetaData']['text'];
    } else {
      throw Exception('Failed to load address');
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Проверка, включена ли служба геолокации.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Проверка разрешений на использование геолокации.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Получение текущей позиции.
    return await Geolocator.getCurrentPosition();
  }

  Future<Point?> getLatLngFromAddress(String address) async {
    final url =
        'https://geocode-maps.yandex.ru/1.x/?apikey=$apiKeyForYandexMaps&geocode=$address&format=json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geoObject = data['response']['GeoObjectCollection']['featureMember']
          [0]['GeoObject'];
      final coordinates = geoObject['Point']['pos'].split(' ');
      final lng = double.parse(coordinates[0]);
      final lat = double.parse(coordinates[1]);
      return Point(latitude: lat, longitude: lng);
    } else {
      throw Exception('Failed to load coordinates');
    }
  }

  Future<List<Order>> searchOrdersNearby({
    required List<Order> orders,
    required double searchRadiusInKm,
    required Position userPosition,
  }) async {
    try {
      List<Order> nearbyOrders = [];
      for (final Order order in orders) {
        final Geolocation? orderGeolocation =
            await getIt<GeolocationRepository>().getGeolocation(order.id);
        final double distance = (Geolocator.distanceBetween(
                userPosition.latitude,
                userPosition.longitude,
                double.parse(orderGeolocation?.latitude ?? '0.0'),
                double.parse(orderGeolocation?.longitude ?? '0.0',),)) /
            1000.0;
            print('distance: $distance');
        if (distance <= searchRadiusInKm) {
          nearbyOrders.add(order);
        }
      }

      return nearbyOrders;
    } catch (e) {
      print('Ошибка поиска заказов которые рядом: $e');
      rethrow;
    }
  }

  Future<List<String>?> searchCities(String query) async {
    try {
      final url = Uri.parse(
        'https://suggest-maps.yandex.ru/v1/suggest?apikey=$yandexGeosuggestAPIKey&text=$query&types=locality&print_address=1&results=3',
      );
      List<String> cities = [];
      print('Request URL (Cities): $url'); // Log URL for debugging
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        final List<dynamic> results = data['results'];

        for (var result in results) {
          final counrty = result['address']['component'][0]['name'];
          final addressFromJson = result['address']['formatted_address'];
          final neededAddress = '$counrty, $addressFromJson';
          cities.add(neededAddress);
        }
      } else {
        print(
            'Failed to fetch cities: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch cities: ${response.statusCode}');
      }
      return cities;
    } catch (e) {
      print('Error fetching cities: $e');
      return null;
    }
  }

  Future<List<String>?> searchAddresses(
      String query, Geolocation? currentGeolocation) async {
    try {
      Position position;
      Uri url;
      if (currentGeolocation == null ||
          currentGeolocation.latitude.isEmpty ||
          currentGeolocation.longitude.isEmpty) {
        position = await getCurrentPosition();
        url = Uri.parse(
          'https://suggest-maps.yandex.ru/v1/suggest?apikey=$yandexGeosuggestAPIKey&text=$query&types=house&print_address=1&results=3&ll=${position.longitude},${position.latitude}',
        );
      } else {
        url = Uri.parse(
          'https://suggest-maps.yandex.ru/v1/suggest?apikey=$yandexGeosuggestAPIKey&text=$query&types=house&print_address=1&results=3&ll=${currentGeolocation.longitude},${currentGeolocation.latitude}',
        );
      }

      List<String> cities = [];
      print('Request URL (Houses): $url'); // Log URL for debugging
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        final List<dynamic> results = data['results'];

        for (var result in results) {
          final counrty = result['address']['component'][0]['name'];
          final addressFromJson = result['address']['formatted_address'];
          final neededAddress = '$counrty, $addressFromJson';
          cities.add(neededAddress);
        }
      } else {
        print(
            'Failed to fetch cities: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch cities: ${response.statusCode}');
      }
      return cities;
    } catch (e) {
      print('Error fetching cities: $e');
      return null;
    }
  }

  Future<void> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
