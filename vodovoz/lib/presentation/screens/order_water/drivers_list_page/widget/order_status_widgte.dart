import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderStatusWidget extends StatelessWidget {
  final String status;
  final String delivererId;
  final VoidCallback onRate;

  const OrderStatusWidget({
    Key? key,
    required this.status,
    required this.delivererId,
    required this.onRate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status == 'accepted') {
      return const Center(
        child: Text('Ожидайте, когда заказчик начнет поездку.'),
      );
    } else if (status == 'inProgress') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ваш заказ принят.'),
            SizedBox(height: 10.h),
            Text(
                'Информация о доставщике: $delivererId'), // Replace with actual deliverer info
          ],
        ),
      );
    } else if (status == 'completed') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ваш заказ исполнен.'),
            Text(
                'Доставщик: $delivererId'), // Replace with actual deliverer info
            ElevatedButton(
              onPressed: onRate,
              child: const Text('Оценить'),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
