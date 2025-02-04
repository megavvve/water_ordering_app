import 'package:geolocator/geolocator.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/active_delivery_provider.dart';
import 'package:vodovoz/utils/constants.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

Future<void> loadDeliverers(
  String waterType,
  ActiveDeliveryProvider activeDeliveryProvider,
  AppWrite appWriteService,
  Point orderPoint
) async {
  final delivererRepository = getIt<DelivererRepository>();
  List<Deliverer> deliverers =
      await delivererRepository.getDeliverersByWaterTypeAndIsOnline(waterType);

  activeDeliveryProvider.initDeliverers(deliverers);


  

  // Копируем список доставщиков, чтобы избежать изменений во время итерации
  List<Deliverer> deliverersCopy = List.from(deliverers);

  for (var deliverer in deliverersCopy) {
    final delivererGeolocation =
        await getIt<GeolocationRepository>().getGeolocation(deliverer.userId);
    if (delivererGeolocation != null) {
      // Преобразуем геолокацию доставщика в Point
      final delivererPoint = Point(
        latitude: double.parse(delivererGeolocation.latitude),
        longitude: double.parse(delivererGeolocation.longitude),
      );

      // Рассчитываем расстояние между заказом и доставщиком
      double distance = Geolocator.distanceBetween(
        orderPoint.latitude,
        orderPoint.longitude,
        delivererPoint.latitude,
        delivererPoint.longitude,
      )/1000.0;

      
      if (distance <= constantForFindDeliverersInKM) {
        activeDeliveryProvider.updateGeolocation(delivererGeolocation);
      }
    }
  }

  // Подписываемся на обновления в реальном времени
  appWriteService.subscribeToRealtimeForDeliverersUpdates(
    waterType: waterType,
    onUpdate: (Deliverer updatedDelivererData) {
      
      activeDeliveryProvider.updateDeliverer(updatedDelivererData);
    },
  );
}

