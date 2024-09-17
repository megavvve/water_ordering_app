import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/presentation/providers/delivery_order_bloc/deliverer_order_bloc.dart';

void showConfirmationDialogForOrderDetails(Order order, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Приступить к заказу?'),
        content: Text(
            'Вы готовы приступить к выполнению  заказа №${order.id.hashCode} ?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Да'),
            onPressed: () {
              BlocProvider.of<DelivererOrderBloc>(context).add(
                UpdateOrderStatus(order, 'inProgress'),
              );
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Нет'),
            onPressed: () {
              BlocProvider.of<DelivererOrderBloc>(context).add(
                UpdateOrderStatus(order, 'pending'),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
