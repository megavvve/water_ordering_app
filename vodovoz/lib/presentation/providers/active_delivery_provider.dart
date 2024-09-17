import 'package:flutter/material.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';

class ActiveDeliveryProvider extends ChangeNotifier {
  // Список текущих доставщиков
  List<Deliverer> _deliverers = [];

  // Список геолокаций доставщиков
  // ignore: prefer_final_fields
  List<Geolocation> _geolocations = [];

  // Получаем список доставщиков
  List<Deliverer> get deliverers => _deliverers;

  // Получаем список геолокаций
  List<Geolocation> get geolocations => _geolocations;

  // Обновление списка доставщиков
  void initDeliverers(List<Deliverer> updatedDeliverers) {
    _deliverers = updatedDeliverers;
    notifyListeners(); // Уведомляем об изменениях
  }

  void initGeolocations(List<Geolocation> updatedGeolocations) {
    _geolocations = updatedGeolocations;
    notifyListeners(); // Уведомляем об изменениях
  }

  // Обновление геолокации доставщика по ID
  void updateGeolocation(Geolocation updatedGeolocation) {
    // Находим индекс геолокации по ID
    final index = _geolocations.indexWhere(
        (geo) => geo.geolocationId == updatedGeolocation.geolocationId);

    // Если геолокация уже существует, обновляем её
    if (index != -1) {
      _geolocations[index] = updatedGeolocation;
    }
    // Если геолокации нет, добавляем новую
    else {
      _geolocations.add(updatedGeolocation);
    }

    notifyListeners(); // Уведомляем об изменениях
  }

  // Удаление доставщика
  void removeDeliverer(String delivererId) {
    _deliverers.removeWhere((deliverer) => deliverer.userId == delivererId);
    _geolocations.removeWhere((geo) => geo.geolocationId == delivererId);
    notifyListeners();
  }

// Обновление конкретного доставщика
  void updateDeliverer(Deliverer updatedDeliverer) {
    // Ищем доставщика по userId в списке
    final index = _deliverers
        .indexWhere((deliverer) => deliverer.userId == updatedDeliverer.userId);

    // Если доставщик найден, обновляем его данные
    if (index != -1) {
      _deliverers[index] = updatedDeliverer;
    } else {
      // Если доставщика нет, добавляем его в список
      _deliverers.add(updatedDeliverer);
    }

    // Уведомляем слушателей об изменениях
    notifyListeners();
  }

  // Очистка всех данных
  void clear() {
    _deliverers.clear();
    _geolocations.clear();
    notifyListeners();
  }
}
