import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:flutter/material.dart';

class OrdersByLocationTab extends StatelessWidget {
  final List<Order> orders;

  const OrdersByLocationTab({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    // Группировка заказов по локациям
    final Map<String, int> ordersByLocation = {};
    for (var order in orders) {
      ordersByLocation[order.address] =
          (ordersByLocation[order.address] ?? 0) + 1;
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
          subtitle: Text('Количество заказов: $count'),
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
          subtitle: Text('Количество заказов: $count'),
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
    for (var user in users) {
      usersByLocation[user.city] = (usersByLocation[user.city] ?? 0) + 1;
    }

    return ListView.builder(
      itemCount: usersByLocation.length,
      itemBuilder: (context, index) {
        final city = usersByLocation.keys.elementAt(index);
        final count = usersByLocation[city];
        return ListTile(
          title: Text('Город: $city'),
          subtitle: Text('Количество пользователей: $count'),
        );
      },
    );
  }
}

class NewUsersTab extends StatelessWidget {
  final List<UserModel> users;

  const NewUsersTab({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Имя: ${users[index].name}'),
          subtitle: Text('Город регистрации: ${users[index].city}'),
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
          subtitle: Text('Лицензия: ${drivers[index].license}'),
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
    final Map<String, int> activeOrdersByRegion = {};
    for (var order in orders) {
      if (order.status == 'active') {
        activeOrdersByRegion[order.address] =
            (activeOrdersByRegion[order.address] ?? 0) + 1;
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
  }
}
