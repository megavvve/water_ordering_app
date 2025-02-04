import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/local/money_repository.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/data/datasources/remote/geo_service.dart';
import 'package:vodovoz/data/datasources/remote/push_notifications.dart';
import 'package:vodovoz/data/repositories/user/auth_repositoty_impl.dart';
import 'package:vodovoz/data/repositories/deliverer_repository_impl.dart';
import 'package:vodovoz/data/repositories/geolocation_repository_impl.dart';
import 'package:vodovoz/data/repositories/user/notification_repository_impl.dart';
import 'package:vodovoz/data/repositories/order_repository_impl.dart';
import 'package:vodovoz/data/repositories/user/rating_repository_impl.dart';
import 'package:vodovoz/data/repositories/storage_repository_impl.dart';
import 'package:vodovoz/data/repositories/user/user_repository_impl.dart';
import 'package:vodovoz/domain/repositories/user/auth_repository.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/user/notification_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/domain/repositories/user/rating_repository.dart';
import 'package:vodovoz/domain/repositories/storage_repository.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';
import 'package:vodovoz/domain/usecases/add_order_use_case.dart';
import 'package:vodovoz/domain/usecases/get_deliverer_by_id.dart';
import 'package:vodovoz/domain/usecases/get_deliverers_use_case.dart';
import 'package:vodovoz/domain/usecases/get_order_by_user_id_use_case.dart';
import 'package:vodovoz/domain/usecases/get_order_use_case.dart';
import 'package:vodovoz/domain/usecases/get_user_by_id.dart';
import 'package:vodovoz/domain/usecases/get_users_use_case.dart';
import 'package:vodovoz/domain/usecases/update_user_use_case.dart';
import 'package:vodovoz/presentation/providers/delivery_order_bloc/deliverer_order_bloc.dart';
import 'package:vodovoz/presentation/providers/form_change_notifier.dart';
import 'package:vodovoz/presentation/providers/active_delivery_provider.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupLocator() async {
  //Services
  getIt.registerLazySingleton<AppWrite>(() => AppWrite());
  //providers
  getIt.registerLazySingleton<ActiveDeliveryProvider>(
      () => ActiveDeliveryProvider());
  getIt.registerLazySingleton<FormChangeNotifier>(() => FormChangeNotifier());

  getIt.registerLazySingleton<DelivererOrderBloc>(() => DelivererOrderBloc());
  getIt.registerLazySingleton<OrderUserBloc>(() => OrderUserBloc());

  

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  //getIt<SharedPreferences>().clear();
  getIt.registerLazySingleton<GeoService>(() => GeoService());
  getIt.registerLazySingleton<LocalSavedData>(() => LocalSavedData());
     getIt.registerLazySingleton<MoneyRepository>(
      () => MoneyRepository());
  await PushNotifications.init();

  await PushNotifications.localNotiInit();

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

//Repositories
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
  getIt.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl());
  getIt.registerLazySingleton<DelivererRepository>(
      () => DelivererRepositoryImpl());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositotyImpl());
  getIt.registerLazySingleton<StorageRepository>(() => StorageRepositoryImpl());
  getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl());
  getIt.registerLazySingleton<RatingRepository>(() => RatingRepositoryImpl());
  getIt.registerLazySingleton<GeolocationRepository>(
      () => GeolocationRepositoryImpl());
   
  //use cases
  getIt.registerLazySingleton(
    () => GetUserById(
      userRepository: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetDelivererById(
      delivererRepository: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => AddOrder(
      orderRepository: getIt(),
    ),
  );

  getIt.registerLazySingleton(
    () => GetUsers(
      userRepository: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => UpdateUser(
      userRepository: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetDeliverers(
      delivererRepository: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetOrder(
      orderRepository: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => GetOrderByUserId(
      orderRepository: getIt(),
    ),
  );
}

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received in background...");
  }
}
