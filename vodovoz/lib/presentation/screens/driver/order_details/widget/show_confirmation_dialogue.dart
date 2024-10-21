import 'package:flutter/material.dart';
import 'package:vodovoz/data/datasources/local/money_repository.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/domain/usecases/get_deliverer_by_id.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/delivery_order_bloc/deliverer_order_bloc.dart';
import 'package:vodovoz/presentation/widgets/enums/order_status.dart';

void showConfirmationDialogForOrderDetails(
  Order order,
  BuildContext context,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<Deliverer?>(
          future: getIt<GetDelivererById>().call(order.delivererId.isNotEmpty
              ? order.delivererId
              : order.idsOfPossibleDeliverers.first),
          builder: (context, snapshot) {
            Deliverer? deliverer = snapshot.data;
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
                      final moneyRepo = getIt<MoneyRepository>();
                      moneyRepo.updateOrderPrice(order, deliverer!);

                      // Списать комиссию
                      moneyRepo.deductCommissionFromOrder(order, deliverer);

                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.greenAccent,
                        content: Text(
                          "Комиссия списана. Текущий баланс: ${moneyRepo.getBalance(deliverer)}₽",
                          style: const TextStyle(color: Colors.black),
                        ),
                      );

                      getIt<DelivererOrderBloc>().add(
                        UpdateOrderStatus(order, 'inProgress'),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor:
                              Colors.grey, // Set the background color to gray
                          content: Text(
                              'Заказ был отменен и не может быть обработан.'),
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
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.grey,
                          content: Text(
                              'Заказ был отменен и не может быть обработан.'),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    },
  );
}
