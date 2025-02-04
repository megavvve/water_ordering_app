import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/presentation/providers/delivery_order_bloc/deliverer_order_bloc.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';

void showCancellationDialogForOrderDetails(Order order, BuildContext context) {
  TextEditingController reasonController = TextEditingController();
  bool isReasonEmpty = false; // Флаг для ошибки

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Отменить заказ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Укажите причину отмены заказа:'),
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    hintText: 'Причина',
                    errorText: isReasonEmpty
                        ? 'Причина не может быть пустой'
                        : null, // Вывод ошибки
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
                    // Если причина указана, отправляем событие отмены заказа
                    BlocProvider.of<DelivererOrderBloc>(context).add(
                      CancelOrder(
                        order,
                        reason,
                      ),
                    );
                    Navigator.of(context).pop();
                    SetPageWithoutBack(context, 'delivery');
                  } else {
                    // Если причина пустая, выводим ошибку
                    setState(() {
                      isReasonEmpty = true;
                    });
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}
