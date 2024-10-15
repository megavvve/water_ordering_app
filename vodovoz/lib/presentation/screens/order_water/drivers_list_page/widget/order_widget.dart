import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/presentation/widgets/widgets_for_getting.dart';

class OrderDetailsWidget extends StatelessWidget {
  final Order order;

  const OrderDetailsWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0.sp),
      child: Padding(
        padding: EdgeInsets.all(16.0.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Информация о заказе',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
              'ID Заказа: ${order.id.hashCode}',
            ),
            Text(
              'Тип воды: ${order.waterType}',
            ),
            Text(
              'Количество: ${order.quantity}',
            ),
            Text(
              'Метод оплаты: ${order.paymentMethod}',
            ),
            Text(
              'Статус: ${translateOrderStatus(order.status)}',
            ),
            Text('Создано: ${order.createdAt}'),
            if (order.updatedAt != null)
              Text(
                'Обновлено: ${order.updatedAt}',
              ),
            if (order.comment != null)
              Text(
                'Комментарий: ${order.comment}',
              ),
            if (order.isLitre != null)
              Text('В литрах: ${order.isLitre! ? "Да" : "Нет"}'),
          ],
        ),
      ),
    );
  }
}
