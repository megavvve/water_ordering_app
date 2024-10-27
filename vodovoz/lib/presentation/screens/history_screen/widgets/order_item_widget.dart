import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/injection_container.dart';

class OrderItemWidget extends StatelessWidget {
  final Order order;

  const OrderItemWidget({required this.order, super.key});

  String translateStatus(String status) {
    switch (status) {
      case 'completed':
        return 'Исполнен';
      case 'awaitingConfirmation':
        return 'Ожидает подтверждения пользователя';
      case 'accepted':
        return 'Ожидает подтверждения доставщика';
      case 'inProgress':
        return 'В исполнении';
      case 'pending':
        return 'В ожидании';
      case 'canceled':
        return 'Отменен';
      default:
        return 'Неизвестен';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Исполнен':
        return Colors.green;
      case 'В исполнении':
        return Colors.blue;
      case 'В ожидании':
        return Colors.orange;
      case 'Отменен':
        return Colors.red;
      case 'Ожидает подтверждения пользователя':
      case 'Ожидает подтверждения доставщика':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final translatedStatus = translateStatus(order.status);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Детали заказа № ${order.id.hashCode}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Статус: $translatedStatus'),
                  SizedBox(height: 10.h),
                  Text('Количество: ${order.quantity}'),
                  SizedBox(height: 10.h),
                  Text('Тип воды: ${order.waterType}'),
                  SizedBox(height: 10.h),
                  Text('Способ оплаты: ${order.paymentMethod}'),
                  SizedBox(height: 10.h),
                  Text('Комментарий: ${order.comment}'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Закрыть'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: FutureBuilder<Geolocation?>(
          future: getIt<GeolocationRepository>().getGeolocation(order.id),
          builder: (context, snapshot) {
            Geolocation? geo = snapshot.data;
            return Padding(
              padding: EdgeInsets.all(15.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Заказ № ${order.id.hashCode}',
                    style:
                        TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.h),
                  if (geo != null)
                    Text(
                      geo.address,
                      style: TextStyle(
                        fontSize: 16.sp,
                      ),
                    ),
                  if (geo != null) SizedBox(height: 10.h),
                  Text(
                    'Статус: $translatedStatus',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: getStatusColor(translatedStatus),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}
