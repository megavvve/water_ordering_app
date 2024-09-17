import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/active_delivery_provider.dart';

Future<void> loadDeliverers(String waterType,ActiveDeliveryProvider activeDeliveryProvider,AppWrite appWriteService) async {
    final delivererRepository = getIt<DelivererRepository>();
    List<Deliverer> deliverers = await delivererRepository
        .getDeliverersByWaterTypeAndIsOnline(waterType);

    activeDeliveryProvider.initDeliverers(deliverers);

    for (var deliverer in deliverers) {
      final getGeolocation =
          await getIt<GeolocationRepository>().getGeolocation(deliverer.userId);
      if (getGeolocation != null) {
        activeDeliveryProvider.updateGeolocation(getGeolocation);
      }
    }

    appWriteService.subscribeToRealtimeForDeliverersUpdates(
      waterType: waterType,
      onUpdate: (Deliverer updatedDelivererData) {
        activeDeliveryProvider.updateDeliverer(updatedDelivererData);
      },
    );
  }
