import 'package:flutter/material.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/delivery_order_bloc/deliverer_order_bloc.dart';
import 'package:vodovoz/presentation/widgets/enums/order_status.dart';

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
            onPressed: () async {
              final orderCopy =
                  await getIt<OrderRepository>().getOrder(order.id);
              if (orderCopy?.status != OrderStatus.canceled.name) {
                getIt<DelivererOrderBloc>().add(
                  UpdateOrderStatus(order, 'inProgress'),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor:
                        Colors.grey, // Set the background color to gray
                    content: Text('Заказ был отменен и не может быть обработан.'),
                  ),
                );
              }

              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Нет'),
            onPressed: () async {
              final orderCopy =
                  await getIt<OrderRepository>().getOrder(order.id);
              if (orderCopy?.status != OrderStatus.canceled.name) {
                getIt<DelivererOrderBloc>().add(
                  UpdateOrderStatus(order, 'pending'),
                );
              }else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor:
                        Colors.grey,
                    content: Text('Заказ был отменен и не может быть обработан.'),
                  ),
                );
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
