import 'package:flutter/material.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/usecases/get_deliverer_by_id.dart';
import 'package:vodovoz/injection_container.dart';

class ActiveDeliveryProvider extends ChangeNotifier {
  List<Deliverer> _deliverers = [];
  List<Geolocation> _geolocations = [];

  List<Deliverer> get deliverers => _deliverers;
  List<Geolocation> get geolocations => _geolocations;

  /// Инициализация доставщиков с проверкой геолокаций
  void initDeliverers(List<Deliverer> updatedDeliverers) {
    _deliverers = updatedDeliverers;
    syncGeolocationsWithDeliverers();
    notifyListeners();
  }

  /// Инициализация геолокаций с проверкой доставщиков
  void initGeolocations(List<Geolocation> updatedGeolocations) {
    _geolocations = updatedGeolocations;
    syncDeliverersWithGeolocations();
    notifyListeners();
  }

  /// Обновление геолокации доставщика по ID с проверкой
  void updateGeolocation(Geolocation updatedGeolocation) {
    final index = _geolocations.indexWhere(
        (geo) => geo.geolocationId == updatedGeolocation.geolocationId);

    if (index != -1) {
      _geolocations[index] = updatedGeolocation;
    } else {
      _geolocations.add(updatedGeolocation);
      checkDelivererPresence(updatedGeolocation.geolocationId);
    }
    notifyListeners();
  }

  /// Обновление конкретного доставщика с проверкой
  void updateDeliverer(Deliverer updatedDeliverer) {
    final index = _deliverers.indexWhere(
        (deliverer) => deliverer.userId == updatedDeliverer.userId);

    if (index != -1) {
      _deliverers[index] = updatedDeliverer;
    } else {
      _deliverers.add(updatedDeliverer);
      checkGeolocationPresence(updatedDeliverer.userId);
    }
    notifyListeners();
  }

  /// Удаление доставщика и соответствующей геолокации
  void removeDeliverer(String delivererId) {
    try {
      _deliverers.removeWhere((deliverer) => deliverer.userId == delivererId);
      _geolocations.removeWhere((geo) => geo.geolocationId == delivererId);
    } catch (e) {
      print('Exception when removing deliverer: $e');
    }
    notifyListeners();
  }

  /// Очистка всех данных
  void clear() {
    _deliverers.clear();
    _geolocations.clear();
    notifyListeners();
  }

  /// Проверка и добавление геолокации, если отсутствует
  Future<void> checkGeolocationPresence(String delivererId) async {
    if (!_geolocations.any((geo) => geo.geolocationId == delivererId)) {
      // Попытка получить недостающую геолокацию (псевдокод)
      final newGeo = await _fetchGeolocationById(delivererId);
      if (newGeo != null) {
        _geolocations.add(newGeo);
      }
    }
  }

  /// Проверка и добавление доставщика, если отсутствует
  void checkDelivererPresence(String geolocationId) async {
    if (!_deliverers.any((deliverer) => deliverer.userId == geolocationId)) {
      // Попытка получить недостающего доставщика (псевдокод)
      final newDeliverer = await _fetchDelivererById(geolocationId);
      if (newDeliverer != null) {
        _deliverers.add(newDeliverer);
      }
    }
  }

  /// Синхронизация: удаление лишних геолокаций
  void syncGeolocationsWithDeliverers() {
    _geolocations.removeWhere((geo) =>
        !_deliverers.any((deliverer) => deliverer.userId == geo.geolocationId));
  }

  /// Синхронизация: удаление лишних доставщиков
  void syncDeliverersWithGeolocations() {
    _deliverers.removeWhere((deliverer) =>
        !_geolocations.any((geo) => geo.geolocationId == deliverer.userId));
  }

  /// Псевдокод для получения геолокации по ID
  Future<Geolocation?> _fetchGeolocationById(String id) async {
    // Логика для получения геолокации из источника данных
    return await getIt<GeolocationRepository>().getGeolocation(id); // Реализовать получение геолокации
  }

  /// Псевдокод для получения доставщика по ID
  Future<Deliverer?> _fetchDelivererById(String id) async {
    // Логика для получения доставщика из источника данных
    return await getIt<GetDelivererById>().call(id); // Реализовать получение доставщика
  }
}
