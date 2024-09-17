import 'package:adminkigwater/data/datasources/local/excel_servise.dart';
import 'package:adminkigwater/data/datasources/remote/appwrite.dart';
import 'package:adminkigwater/data/repositories/admin_repository_impl.dart';
import 'package:adminkigwater/domain/repositories/admin_repository.dart';
import 'package:adminkigwater/domain/usecases/add_order_use_case.dart';
import 'package:adminkigwater/domain/usecases/get_admins_use_case.dart';
import 'package:adminkigwater/domain/usecases/get_deliverer_by_id.dart';
import 'package:adminkigwater/domain/usecases/get_deliverers_use_case.dart';
import 'package:adminkigwater/domain/usecases/get_user_by_id.dart';
import 'package:adminkigwater/domain/usecases/get_users_use_case.dart';
import 'package:adminkigwater/domain/usecases/updateAdmin.dart';
import 'package:adminkigwater/domain/usecases/update_deliverer_use_case.dart';
import 'package:adminkigwater/domain/usecases/update_user_use_case.dart';
import 'package:get_it/get_it.dart';

import 'package:adminkigwater/data/repositories/auth_repositoty_impl.dart';
import 'package:adminkigwater/data/repositories/deliverer_repository_impl.dart';
import 'package:adminkigwater/data/repositories/notification_repository_impl.dart';
import 'package:adminkigwater/data/repositories/order_repository_impl.dart';
import 'package:adminkigwater/data/repositories/rating_repository.dart';
import 'package:adminkigwater/data/repositories/storage_repository_impl.dart';
import 'package:adminkigwater/data/repositories/user_repository_impl.dart';
import 'package:adminkigwater/domain/repositories/auth_repository.dart';
import 'package:adminkigwater/domain/repositories/deliverer_repository.dart';
import 'package:adminkigwater/domain/repositories/notification_repository.dart';
import 'package:adminkigwater/domain/repositories/order_repository.dart';
import 'package:adminkigwater/domain/repositories/rating_repository.dart';
import 'package:adminkigwater/domain/repositories/storage_repository.dart';
import 'package:adminkigwater/domain/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  //Servieces
  getIt.registerLazySingleton<AppWrite>(() => AppWrite());

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerLazySingleton<ExcelService>(() => ExcelService());

  // Register Cubit
  // getIt.registerFactory(() => PhoneNumberSignInCubit());
//Repositoty
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
  getIt.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl());
  getIt.registerLazySingleton<DelivererRepository>(
      () => DelivererRepositoryImpl());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositotyImpl());
  getIt.registerLazySingleton<StorageRepository>(() => StorageRepositoryImpl());
  getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl());
  getIt.registerLazySingleton<RatingRepository>(() => RatingRepositoryImpl());
  getIt.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl());
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
    () => GetAdmins(
      adminRepository: getIt(),
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
    () => UpdateDeliverer(
      delivererRepository: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => UpdateAdmin(
      adminRepository: getIt(),
    ),
  );
}
