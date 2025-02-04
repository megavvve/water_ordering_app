import 'package:adminkigwater/domain/entities/order.dart';
import 'package:adminkigwater/utils/enums/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
       title: Text('Подробности заказа № ${order.id.hashCode}'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text('Номер заказа: ${order.id.hashCode}',
                style: TextStyle(fontSize: 20.sp)),
            SizedBox(height: 10.h),
            Text('Клиент ID: ${order.customerId}'),
            SizedBox(height: 10.h),
            Text('Доставщик ID: ${order.delivererId}'),
            SizedBox(height: 10.h),
            Text('Тип воды: ${order.waterType}'),
            SizedBox(height: 10.h),
            Text('Количество: ${order.quantity}'),
            SizedBox(height: 10.h),
            Text('Метод оплаты: ${order.paymentMethod}'),
            SizedBox(height: 10.h),
            Text('Статус: ${translateOrderStatus(order.status)}'),
            SizedBox(height: 10.h),
            Text('Дата создания: ${order.createdAt}'),
            SizedBox(height: 10.h),
            if (order.comment != null) Text('Комментарий: ${order.comment}'),
          ],
        ),
      ),
    );
  }
}
