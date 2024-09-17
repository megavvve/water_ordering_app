import 'package:flutter/material.dart';
import 'package:vodovoz/domain/entities/order.dart';

void showCancellationDialogForOrderDetails(Order order, BuildContext context) {
  TextEditingController reasonController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Отменить заказ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Укажите причину отмены заказа:'),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Причина',
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Отмена'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('ОК'),
            onPressed: () {
              String reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                // BlocProvider.of<DelivererOrderBloc>(context).add(
                //   UpdateOrderStatus(order, 'canceled', reason: reason),
                // );
                Navigator.of(context).pop();
              } else {
                // Вы можете добавить здесь сообщение об ошибке, если причина не указана
              }
            },
          ),
        ],
      );
    },
  );
}
