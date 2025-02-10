import 'package:flutter/material.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/utils/enums/order_status.dart';

void showCancelDialog(BuildContext context, Order order,
    Future<void> Function(Order order, String status) updateOrderStatus) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Отмена заказа'),
        content: const Text('Вы уверены, что не хотите брать заказ? Потом взять вы его не сможете'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              updateOrderStatus(order, OrderStatus.canceled.name);
            },
            child: const Text('Да'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Нет'),
          ),
        ],
      );
    },
  );
}
