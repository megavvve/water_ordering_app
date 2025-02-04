import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:adminkigwater/utils/enums/order_status.dart';
import 'package:adminkigwater/utils/enums/user_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// class OrdersByLocationTab extends StatelessWidget {
//   final List<Order> orders;

//   const OrdersByLocationTab({
//     super.key,
//     required this.orders,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (orders.isEmpty) {
//       return Center(child: Text('Нет заказов для отображения по локациям.'));
//     }

//     return FutureBuilder<List<Geolocation>>(
//       future: getIt<GeolocationRepository>()
//           .getGeolocationsByIds(orders.map((x) => x.id).toList()),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Ошибка: ${snapshot.error}'));
//         }

//         List<Geolocation> ordersgeolocation = snapshot.data ?? [];
//         if (ordersgeolocation.isEmpty) {
//           return Center(child: Text('Геолокации заказов не найдены.'));
//         }

//         final Map<String, int> ordersByLocation = {};
//         for (var order in orders) {
//           ordersByLocation[ordersgeolocation
//               .firstWhere((x) => x.geolocationId == order.id)
//               .address] = (ordersByLocation[ordersgeolocation
//                       .firstWhere((x) => x.geolocationId == order.id)
//                       .address] ??
//                   0) +
//               1;
//         }

//         if (ordersByLocation.isEmpty) {
//           return Center(
//               child: Text('Нет заказов для группировки по локациям.'));
//         }

//         return ListView.builder(
//           itemCount: ordersByLocation.length,
//           itemBuilder: (context, index) {
//             final location = ordersByLocation.keys.elementAt(index);
//             final count = ordersByLocation[location];
//             return ListTile(
//               title: Text('Локация: $location'),
//               subtitle: Text('Количество заказов: $count'),
//             );
//           },
//         );
//       },
//     );
//   }
// }

class AllOrdersTab extends StatelessWidget {
  final List<Order> orders;

  const AllOrdersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(child: Text('Нет заказов.'));
    }

    return FutureBuilder<List<Geolocation>>(
      future: getIt<GeolocationRepository>()
          .getGeolocationsByIds(orders.map((x) => x.id).toList()),
      builder: (context, snapshot) {
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
            return Card(
              margin: EdgeInsets.all(8.0.sp),
              child: Padding(
                padding: EdgeInsets.all(8.0.sp),
                child: ListTile(
                  title: Text('Заказ №${order.id.hashCode}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Геолокация: ${geolocation?.address}'),
                      Text('Тип воды: ${order.waterType}'),
                      Text('Количество: ${order.quantity}'),
                      Text('Метод оплаты: ${order.paymentMethod}'),
                      Text('Дата создания: ${order.createdAt}'),
                      Text('Статус: ${translateOrderStatus(order.status)}'),
                      if (order.comment != null && order.comment!.isNotEmpty)
                        Text('Комментарий: ${order.comment}'),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ActiveOrdersByClientsTab extends StatelessWidget {
  final List<Order> orders;

  const ActiveOrdersByClientsTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    // Фильтрация активных заказов по определённым статусам
    final activeOrders = orders.where((order) {
      return order.status == OrderStatus.accepted.name ||
          order.status == OrderStatus.inProgress.name ||
          order.status == OrderStatus.pending.name ||
          order.status == OrderStatus.awaitingConfirmation.name;
    }).toList();

    if (activeOrders.isEmpty) {
      return const Center(child: Text('Нет активных заказов для отображения.'));
    }

    // Группировка заказов по клиентам
    final Map<String, List<Order>> activeOrdersByClient = {};
    for (var order in activeOrders) {
      activeOrdersByClient[order.customerId] ??= [];
      activeOrdersByClient[order.customerId]!.add(order);
    }

    if (activeOrdersByClient.isEmpty) {
      return const Center(child: Text('Нет активных заказов по клиентам.'));
    }

    return ListView.builder(
      itemCount: activeOrdersByClient.length,
      itemBuilder: (context, index) {
        final clientId = activeOrdersByClient.keys.elementAt(index);
        final clientOrders = activeOrdersByClient[clientId];

        return Card(
          margin: EdgeInsets.all(8.0.sp),
          child: Padding(
            padding: EdgeInsets.all(8.0.sp),
            child: Column(
              children: clientOrders!.map((order) {
                return ListTile(
                  title: Text('Заказ №${order.id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Тип воды: ${order.waterType}'),
                      Text('Количество: ${order.quantity}'),
                      Text('Метод оплаты: ${order.paymentMethod}'),
                      Text('Дата создания: ${order.createdAt}'),
                      Text('Статус: ${translateOrderStatus(order.status)}'),
                      if (order.comment != null && order.comment!.isNotEmpty)
                        Text('Комментарий: ${order.comment}'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class CompletedOrdersBySuppliersTab extends StatelessWidget {
  final List<Order> orders;

  const CompletedOrdersBySuppliersTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    // Фильтрация завершённых заказов по статусу 'completed'
    final completedOrders = orders.where((order) {
      return order.status == OrderStatus.completed.name;
    }).toList();

    if (completedOrders.isEmpty) {
      return const Center(
        child: Text(
          'Нет завершённых заказов для отображения.',
        ),
      );
    }

    // Группировка завершённых заказов по поставщикам
    final Map<String, List<Order>> completedOrdersBySupplier = {};
    for (var order in completedOrders) {
      completedOrdersBySupplier[order.delivererId] ??= [];
      completedOrdersBySupplier[order.delivererId]!.add(order);
    }

    if (completedOrdersBySupplier.isEmpty) {
      return const Center(
        child: Text(
          'Нет завершённых заказов по поставщикам.',
        ),
      );
    }

    return ListView.builder(
        itemCount: completedOrdersBySupplier.length,
        itemBuilder: (context, index) {
          final supplierId = completedOrdersBySupplier.keys.elementAt(index);
          final supplierOrders = completedOrdersBySupplier[supplierId]!;

          return Column(
            children: supplierOrders.map((order) {
              return Card(
                margin: EdgeInsets.all(8.0.sp),
                child: Padding(
                  padding: EdgeInsets.all(8.0.sp),
                  child: ListTile(
                    title: Text('Заказ №${order.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Тип воды: ${order.waterType}'),
                        Text('Количество: ${order.quantity}'),
                        Text('Метод оплаты: ${order.paymentMethod}'),
                        Text('Дата создания: ${order.createdAt}'),
                        Text('Статус: ${translateOrderStatus(order.status)}'),
                        if (order.comment != null && order.comment!.isNotEmpty)
                          Text('Комментарий: ${order.comment}'),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        });
  }
}

// class UsersByLocationTab extends StatelessWidget {
//   final List<UserModel> users;

//   const UsersByLocationTab({super.key, required this.users});

//   @override
//   Widget build(BuildContext context) {
//     // Группировка пользователей по локациям
//     final Map<String, int> usersByLocation = {};

//     return FutureBuilder<List<Geolocation>>(
//         future: getIt<GeolocationRepository>()
//             .getGeolocationsByIds(users.map((x) => x.userId).toList()),
//         builder: (context, snapshot) {
//           List<Geolocation> usersGeolocation = snapshot.data ?? [];
//           for (var user in users) {
//             Geolocation? geolocation;
//             try {
//               geolocation = usersGeolocation.firstWhere(
//                 (x) => x.geolocationId == user.userId,
//               );
//             } catch (e) {
//               geolocation = null;
//             }

//             String key = geolocation?.address ?? '';
//             if (geolocation != null) {
//               usersByLocation[key] = (usersByLocation[key] ?? 0) + 1;
//             }
//           }
//           return ListView.builder(
//             itemCount: usersByLocation.length,
//             itemBuilder: (context, index) {
//               final city = usersByLocation.keys.elementAt(index);
//               final count = usersByLocation[city];
//               return ListTile(
//                 title: Text('Город: $city'),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Количество пользователей: $count'),
//                     const Divider(),
//                   ],
//                 ),
//               );
//             },
//           );
//         });
//   }
// }

// class NewUsersTab extends StatelessWidget {
//   final List<UserModel> users;

//   const NewUsersTab({super.key, required this.users});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Geolocation>>(
//         future: getIt<GeolocationRepository>()
//             .getGeolocationsByIds(users.map((x) => x.userId).toList()),
//         builder: (context, snapshot) {
//           List<Geolocation> usersGeolocation = snapshot.data ?? [];
//           return ListView.builder(
//             itemCount: users.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text('Имя: ${users[index].name}'),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                         'Город регистрации: ${usersGeolocation.firstWhere((x) => x.geolocationId == users[index].userId).address}'),
//                     const Divider(),
//                   ],
//                 ),
//               );
//             },
//           );
//         });
//   }
// }

class AllUsersTab extends StatelessWidget {
  final List<UserModel> users;

  const AllUsersTab({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('Нет пользователей для отображения.'));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        // Проверка, что имя не пустое
        String userName =
            users[index].name.isNotEmpty ? users[index].name : 'Неизвестно';
        String phoneNumber = users[index].phoneNumber.isNotEmpty
            ? users[index].phoneNumber
            : 'Неизвестен';

        return ListTile(
          leading: CircleAvatar(
            child: Text(userName[0]), // Инициал имени
          ),
          title: Text(userName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Телефон: $phoneNumber'),
              Text(
                  'Тип пользователя: ${translateUserType(users[index].userType)}'),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}

// class DriverApplicationsTab extends StatelessWidget {
//   final List<Deliverer> drivers;

//   const DriverApplicationsTab({super.key, required this.drivers});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: drivers.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text('Водитель ID: ${drivers[index].userId}'),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Лицензия: ${drivers[index].license}'),
//               const Divider(),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class ActiveOrdersByRegionsTab extends StatelessWidget {
//   final List<Order> orders;

//   const ActiveOrdersByRegionsTab({super.key, required this.orders});

//   @override
//   Widget build(BuildContext context) {
//     // Группировка активных заказов по регионам

//     return FutureBuilder<List<Geolocation>>(
//         future: getIt<GeolocationRepository>()
//             .getGeolocationsByIds(orders.map((x) => x.id).toList()),
//         builder: (context, snapshot) {
//           List<Geolocation> ordersgeolocation = snapshot.data ?? [];
//           final Map<String, int> activeOrdersByRegion = {};
//           for (var order in orders) {
//             if (order.status == 'active') {
//               String key = ordersgeolocation
//                   .firstWhere((x) => x.geolocationId == order.id)
//                   .address;
//               activeOrdersByRegion[key] = (activeOrdersByRegion[key] ?? 0) + 1;
//             }
//           }
//           return ListView.builder(
//             itemCount: activeOrdersByRegion.length,
//             itemBuilder: (context, index) {
//               final region = activeOrdersByRegion.keys.elementAt(index);
//               final count = activeOrdersByRegion[region];
//               return ListTile(
//                 title: Text('Регион: $region'),
//                 subtitle: Text('Активные заказы: $count'),
//               );
//             },
//           );
//         });
//   }
// }

class OrdersByCanceledTab extends StatelessWidget {
  final List<Order> orders;

  const OrdersByCanceledTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final canceledOrders =
        orders.where((order) => order.status == 'canceled').toList();

    if (canceledOrders.isEmpty) {
      return const Center(child: Text('Нет отмененных заказов.'));
    }

    return ListView.builder(
      itemCount: canceledOrders.length,
      itemBuilder: (context, index) {
        final order = canceledOrders[index];
        return Card(
          margin: EdgeInsets.all(8.0.sp),
          child: Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: ListTile(
                title: Text('Заказ №${order.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Тип воды: ${order.waterType}'),
                    Text('Количество: ${order.quantity}'),
                    Text('Метод оплаты: ${order.paymentMethod}'),
                    Text('Дата создания: ${order.createdAt}'),
                    Text('Статус: ${translateOrderStatus(order.status)}'),
                    if (order.comment != null && order.comment!.isNotEmpty)
                      Text('Комментарий: ${order.comment}'),
                  ],
                ),
              )),
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
    if (drivers.isEmpty) {
      return const Center(
        child: Text(
          'Нет доставщиков для отображения.',
        ),
      );
    }

    return ListView.builder(
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        String license;
        try {
          license = driver.license.isNotEmpty ? driver.license : 'Неизвестна';
        } catch (e) {
          license = 'Неизвестна';
        }

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text('Водитель: ${driver.userId}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Лицензия: $license',
                ),
                Text(
                  'Доступен: ${driver.isAvailable == true ? "Да" : "Нет"}',
                ),
              ],
            ),
            trailing: const Icon(
              Icons.local_shipping,
              color: Colors.blue,
            ),
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
    final filteredList = users
        .where(
          (x) => x.userType == UserType.user.name,
        )
        .toList();
    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          'Нет клиентов для отображения.',
        ),
      );
    }

    // Группировка заказов по клиентам
    final Map<String, int> ordersByClient = {};
    for (var order in orders) {
      ordersByClient[order.customerId] =
          (ordersByClient[order.customerId] ?? 0) + 1;
    }

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final user = filteredList[index];
        final orderCount = ordersByClient[user.userId] ?? 0;
        String phoneNumber;
        try {
          phoneNumber =
              user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Неизвестен';
        } catch (e) {
          phoneNumber = 'Неизвестен';
        }

        return Card(
          margin: EdgeInsets.all(8.0.sp),
          child: ListTile(
            title: Text('Клиент: ${user.name}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID клиента: ${user.userId}',
                ),
                Text(
                  'Количество заказов: $orderCount',
                ),
                Text(
                  'Телефон: $phoneNumber',
                ),
              ],
            ),
            trailing: const Icon(
              Icons.person,
              color: Colors.green,
            ),
          ),
        );
      },
    );
  }
}
