import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrdersByLocationTab extends StatelessWidget {
  final List<Order> orders;

  const OrdersByLocationTab({
    super.key,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    // Группировка заказов по локациям

    return FutureBuilder<List<Geolocation>>(
        future: getIt<GeolocationRepository>()
            .getGeolocationsByIds(orders.map((x) => x.id).toList()),
        builder: (context, snapshot) {
          List<Geolocation> ordersgeolocation = snapshot.data ?? [];
          final Map<String, int> ordersByLocation = {};
          for (var order in orders) {
            ordersByLocation[ordersgeolocation
                .firstWhere((x) => x.geolocationId == order.id)
                .address] = (ordersByLocation[ordersgeolocation
                        .firstWhere((x) => x.geolocationId == order.id)
                        .address] ??
                    0) +
                1;
          }

          return ListView.builder(
            itemCount: ordersByLocation.length,
            itemBuilder: (context, index) {
              final location = ordersByLocation.keys.elementAt(index);
              final count = ordersByLocation[location];
              return ListTile(
                title: Text('Локация: $location'),
                subtitle: Text('Количество заказов: $count'),
              );
            },
          );
        });
  }
}

class AllOrdersTab extends StatelessWidget {
  final List<Order> orders;

  const AllOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    // Получаем геолокации заказов
    return FutureBuilder<List<Geolocation>>(
        future: getIt<GeolocationRepository>()
            .getGeolocationsByIds(orders.map((x) => x.id).toList()),
        builder: (context, snapshot) {
          // Проверяем наличие данных о геолокациях
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          List<Geolocation> ordersGeolocations = snapshot.data ?? [];

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              Geolocation? geolocation;
              try {
                geolocation = ordersGeolocations.firstWhere(
                  (geo) => geo.geolocationId == order.id,
                );
              } catch (e) {
                geolocation = null;
              }

              return ListTile(
                title: Text('Заказ №${order.id.hashCode}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Клиент: ${order.customerId}'),
                    Text('Статус: ${order.status}'),
                    Text('Создан: ${order.createdAt}'),
                    Text(
                        'Адрес: ${geolocation == null ? 'не указан' : geolocation.address}'),
                    const Divider(),
                  ],
                ),
              );
            },
          );
        });
  }
}

class OrdersByClientsTab extends StatelessWidget {
  final List<Order> orders;

  const OrdersByClientsTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    // Группировка заказов по клиентам
    final Map<String, int> ordersByClient = {};
    for (var order in orders) {
      ordersByClient[order.customerId] =
          (ordersByClient[order.customerId] ?? 0) + 1;
    }

    return ListView.builder(
      itemCount: ordersByClient.length,
      itemBuilder: (context, index) {
        final clientId = ordersByClient.keys.elementAt(index);
        final count = ordersByClient[clientId];
        return ListTile(
          title: Text('Клиент ID: $clientId'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Количество заказов: $count'),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}

class OrdersBySuppliersTab extends StatelessWidget {
  final List<Order> orders;

  const OrdersBySuppliersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    // Группировка заказов по поставщикам
    final Map<String, int> ordersBySupplier = {};
    for (var order in orders) {
      ordersBySupplier[order.delivererId] =
          (ordersBySupplier[order.delivererId] ?? 0) + 1;
    }

    return ListView.builder(
      itemCount: ordersBySupplier.length,
      itemBuilder: (context, index) {
        final supplierId = ordersBySupplier.keys.elementAt(index);
        final count = ordersBySupplier[supplierId];
        return ListTile(
          title: Text('Поставщик ID: $supplierId'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Количество заказов: $count'),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}

class UsersByLocationTab extends StatelessWidget {
  final List<UserModel> users;

  const UsersByLocationTab({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    // Группировка пользователей по локациям
    final Map<String, int> usersByLocation = {};

    return FutureBuilder<List<Geolocation>>(
        future: getIt<GeolocationRepository>()
            .getGeolocationsByIds(users.map((x) => x.userId).toList()),
        builder: (context, snapshot) {
          List<Geolocation> usersGeolocation = snapshot.data ?? [];
          for (var user in users) {
            Geolocation? geolocation;
            try {
              geolocation = usersGeolocation.firstWhere(
                (x) => x.geolocationId == user.userId,
              );
            } catch (e) {
              geolocation = null;
            }

            String key = geolocation?.address ?? '';
            if (geolocation != null) {
              usersByLocation[key] = (usersByLocation[key] ?? 0) + 1;
            }
          }
          return ListView.builder(
            itemCount: usersByLocation.length,
            itemBuilder: (context, index) {
              final city = usersByLocation.keys.elementAt(index);
              final count = usersByLocation[city];
              return ListTile(
                title: Text('Город: $city'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Количество пользователей: $count'),
                    const Divider(),
                  ],
                ),
              );
            },
          );
        });
  }
}

class NewUsersTab extends StatelessWidget {
  final List<UserModel> users;

  const NewUsersTab({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Geolocation>>(
        future: getIt<GeolocationRepository>()
            .getGeolocationsByIds(users.map((x) => x.userId).toList()),
        builder: (context, snapshot) {
          List<Geolocation> usersGeolocation = snapshot.data ?? [];
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Имя: ${users[index].name}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Город регистрации: ${usersGeolocation.firstWhere((x) => x.geolocationId == users[index].userId).address}'),
                    const Divider(),
                  ],
                ),
              );
            },
          );
        });
  }
}

class AllUsersTab extends StatelessWidget {
  final List<UserModel> users;

  const AllUsersTab({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        // Проверка, что имя не пустое
        String userName = users[index].name.isNotEmpty
            ? users[index].name
            : 'Неизвестно';

        return ListTile(
          leading: CircleAvatar(
            child: Text(userName[0]), // Инициал имени или замена на первый символ "Неизвестно"
          ),
          title: Text(userName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Телефон: ${users[index].phoneNumber.isNotEmpty ? users[index].phoneNumber : 'Неизвестен'}'),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}



class DriverApplicationsTab extends StatelessWidget {
  final List<Deliverer> drivers;

  const DriverApplicationsTab({super.key, required this.drivers});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Водитель ID: ${drivers[index].userId}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Лицензия: ${drivers[index].license}'),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}

class ActiveOrdersByRegionsTab extends StatelessWidget {
  final List<Order> orders;

  const ActiveOrdersByRegionsTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    // Группировка активных заказов по регионам

    return FutureBuilder<List<Geolocation>>(
        future: getIt<GeolocationRepository>()
            .getGeolocationsByIds(orders.map((x) => x.id).toList()),
        builder: (context, snapshot) {
          List<Geolocation> ordersgeolocation = snapshot.data ?? [];
          final Map<String, int> activeOrdersByRegion = {};
          for (var order in orders) {
            if (order.status == 'active') {
              String key = ordersgeolocation
                  .firstWhere((x) => x.geolocationId == order.id)
                  .address;
              activeOrdersByRegion[key] = (activeOrdersByRegion[key] ?? 0) + 1;
            }
          }
          return ListView.builder(
            itemCount: activeOrdersByRegion.length,
            itemBuilder: (context, index) {
              final region = activeOrdersByRegion.keys.elementAt(index);
              final count = activeOrdersByRegion[region];
              return ListTile(
                title: Text('Регион: $region'),
                subtitle: Text('Активные заказы: $count'),
              );
            },
          );
        });
  }
}

class OrdersByCanceledTab extends StatelessWidget {
  final List<Order> orders;

  const OrdersByCanceledTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    // Фильтрация отмененных заказов
    final canceledOrders =
        orders.where((order) => order.status == 'canceled').toList();

    return ListView.builder(
      itemCount: canceledOrders.length,
      itemBuilder: (context, index) {
        final order = canceledOrders[index];
        return Card(
          margin: EdgeInsets.all(8.0.sp),
          child: ListTile(
            title: Text('Заказ от клиента: ${order.customerId}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Дата заказа: ${order.createdAt}'),

//Text('Причина отмены: ${order.cancelReason ?? 'Не указана'}'),
                //Text('Стоимость: ${order.totalAmount} руб.'),
              ],
            ),
            trailing: const Icon(Icons.cancel, color: Colors.red),
          ),
        );
      },
    );
  }
}

class DeliverersStatsTab extends StatelessWidget {
  final List<Deliverer> drivers;

  const DeliverersStatsTab({super.key, required this.drivers});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return Card(
          margin: EdgeInsets.all(8.0.sp),
          child: ListTile(
            title: Text('Водитель: ${driver.userId}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Лицензия: ${driver.license}'),
                // Text('Выполненные заказы: ${driver.compleedOrders}'),
                // Text('Рейтинг: ${driver.rating.toStringAsFixed(1)}'),
                Text('Доступен: ${driver.isAvailable == true ? "Да" : "Нет"}'),
              ],
            ),
            trailing: const Icon(Icons.local_shipping, color: Colors.blue),
          ),
        );
      },
    );
  }
}

class ClientsStatsTab extends StatelessWidget {
  final List<UserModel> users;
  final List<Order> orders;

  const ClientsStatsTab({super.key, required this.users, required this.orders});

  @override
  Widget build(BuildContext context) {
    // Группировка заказов по клиентам
    final Map<String, int> ordersByClient = {};
    for (var order in orders) {
      ordersByClient[order.customerId] =
          (ordersByClient[order.customerId] ?? 0) + 1;
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final orderCount = ordersByClient[user.userId] ?? 0;
        return Card(
          margin: EdgeInsets.all(8.0.sp),
          child: ListTile(
            title: Text('Клиент: ${user.name}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID клиента: ${user.userId}'),
                Text('Количество заказов: $orderCount'),
                Text('Телефон: ${user.phoneNumber}'),
              ],
            ),
            trailing: Icon(Icons.person, color: Colors.green),
          ),
        );
      },
    );
  }
}
