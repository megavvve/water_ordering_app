import 'package:appwrite/appwrite.dart';

import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/active_delivery_provider.dart';

import 'package:vodovoz/utils/constants.dart';

class AppWrite {
  Client appWriteClient = Client()
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('6696b90100392dbab5c0')
      .setSelfSigned(status: true);

  Databases getDataBase() {
    Databases databases = Databases(appWriteClient);
    return databases;
  }

  Messaging getMessaging() {
    Messaging messaging = Messaging(appWriteClient);
    return messaging;
  }

  Realtime getRealtime() {
    Realtime realtime = Realtime(appWriteClient);
    return realtime;
  }

  Storage getStorage() {
    Storage storage = Storage(appWriteClient);
    return storage;
  }

  Account getAccount() {
    Account account = Account(appWriteClient);
    return account;
  }

  RealtimeSubscription? subscription;
  final activeDeliveryProvider = getIt<ActiveDeliveryProvider>();
  // to subscribe to realtime changes
  void subscribeToRealtimeForClientUpdateOrder({
    required Function onUpdate,
  }) {
    try {
      subscription = getRealtime().subscribe([
        "databases.$dbId.collections.$ordersCollectionId.documents",
      ]);
      print("subscribing to realtime $subscription");

      if (subscription != null) {
        subscription!.stream.listen((data) async {
          final firstItem = data.events[0].split(".");
          final eventType = firstItem[firstItem.length - 1];

          if (eventType == "update" || eventType == "create") {
            onUpdate();
          }
        });
      } else {
        print("Error: Subscription is null.");
      }
    } catch (e) {
      print("Error subscribing to realtime: $e");
    }
  }

  void subscribeToRealtimeForDelivererLoadOrders({
    required Function onUpdate,
  }) {
    try {
      subscription = getRealtime().subscribe([
        'databases.$dbId.collections.$ordersCollectionId.documents',
      ]);

      if (subscription != null) {
        subscription!.stream.listen((data) {
          final firstItem = data.events[0].split(".");
          final eventType = firstItem[firstItem.length - 1];
          if (eventType == "update" || eventType == "create") {
            onUpdate();
          }
        });
      } else {
        print("Error: Subscription is null.");
      }
    } catch (e) {
      print("Error subscribing to real-time updates: $e");
    }
  }

  bool ckeckIfSubscribeOnGeolocation = false;
  void subscribeToRealtimeForDeliverersUpdates({
    required String waterType,
    required Function(Deliverer updatedDelivererData) onUpdate,
  }) {
    // Подписываемся на изменения в коллекции доставщиков
    deliverySubscription = getRealtime().subscribe([
      'databases.$dbId.collections.$deliverersCollectionId.documents',
    ]);
    if (!ckeckIfSubscribeOnGeolocation) {
      subscribeToGeolocationUpdates(
          onUpdate: (Geolocation updatedGeolocationData) {
        activeDeliveryProvider.updateGeolocation(updatedGeolocationData);
      });
      ckeckIfSubscribeOnGeolocation = true;
    }

    try {
      if (deliverySubscription != null) {
        deliverySubscription!.stream.listen((data) async {
          final firstItem = data.events[0].split(".");
          final eventType = firstItem[firstItem.length - 1];

          if (eventType == "update" || eventType == "create") {
            final delivererData = data.payload;

            // Извлекаем ID доставщика из данных
            if (delivererData['waterType'] == waterType &&
                (delivererData['isAvailable'] == false ||
                    delivererData['isAvailable'] == null) &&
                activeDeliveryProvider.deliverers
                    .map(
                      (e) => e.userId,
                    )
                    .contains(
                      delivererData['\$id'],
                    )) {
              activeDeliveryProvider.removeDeliverer(delivererData['\$id']);
            }
            // Проверяем, есть ли этот доставщик в списке интересующих нас ID
            if (delivererData['waterType'] == waterType &&
                delivererData['isAvailable'] == true) {
              final updatedDeliverer = Deliverer.fromJson(delivererData);
              onUpdate(updatedDeliverer);

              if (!activeDeliveryProvider.deliverers.contains(
                delivererData['\$id'],
              )) {
                final geolocation = await getIt<GeolocationRepository>()
                    .getGeolocation(delivererData['\$id']);
                if (geolocation != null) {
                  activeDeliveryProvider.updateGeolocation(geolocation);
                }
              }
            }
          }
        });
      } else {
        print("Error: Subscription is null.");
      }
    } catch (e) {
      print("Error subscribing to real-time updates for deliverers: $e");
    }
  }

  void unsubscribeFromRealtimeUpdates() {
    subscription?.close();
    subscription = null;
    deliverySubscription?.close();
    deliverySubscription = null;
    geolocationSubscription?.close();
    geolocationSubscription = null;
  }

  RealtimeSubscription? deliverySubscription;
  RealtimeSubscription? geolocationSubscription;

  void subscribeToGeolocationUpdates({
    required Function(Geolocation updatedGeolocationData) onUpdate,
  }) {
    // Подписываемся на изменения всех геолокаций в коллекции
    geolocationSubscription = getRealtime().subscribe([
      'databases.$dbId.collections.$geolocationsCollectionId.documents',
    ]);

    try {
      if (geolocationSubscription != null) {
        geolocationSubscription!.stream.listen((data) {
          final firstItem = data.events[0].split(".");
          final eventType = firstItem[firstItem.length - 1];

          // Проверяем, произошло ли обновление или создание
          if (eventType == "update" || eventType == "create") {
            final geolocationData = data.payload;

            // Извлекаем ID геолокации из данных
            final String geolocationId = geolocationData['\$id'];

            // Проверяем, есть ли этот ID в списке интересующих нас геолокаций
            final listIds =
                activeDeliveryProvider.deliverers.map((x) => x.userId).toList();
            if (listIds.contains(geolocationId)) {
              // Преобразуем данные в объект Geolocation и вызываем callback
              final updatedGeolocation = Geolocation.fromMap(geolocationData);
              onUpdate(updatedGeolocation);
            }
          }
        });
      } else {
        print("Error: Geolocation subscription is null.");
      }
    } catch (e) {
      print("Error subscribing to geolocation updates: $e");
    }
  }
}
