import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/presentation/screens/order_water/order_accept_page/widgets/cancel_order.dart';

Widget buildInProgressState(BuildContext context, Order order,
    Geolocation? geoOrder, UserModel? deliverer) {
  return Container(
    padding: EdgeInsets.all(16.sp),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.sp),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 10.sp,
          offset: Offset(0, 5.h),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Информация о заказе',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 20.sp),
        _buildOrderDetailRow('Адрес доставки:', geoOrder?.address ?? ''),
        _buildOrderDetailRow('Тип воды:', order.waterType),
        _buildOrderDetailRow('Количество:', '${order.quantity} ${order.isLitre! ? 'л' : 'шт'}'),
        _buildOrderDetailRow('Метод оплаты:', order.paymentMethod),
        _buildOrderDetailRow('Комментарий:', order.comment ?? 'Отсутствует'),
        SizedBox(height: 20.sp),
        Divider(color: Colors.grey[300]),
        SizedBox(height: 20.sp),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deliverer?.name ?? 'Неизвестно',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Телефон: ${deliverer?.phoneNumber ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20.sp),
        SizedBox(
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              cancelOrder(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.sp),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.sp),
              child: Text(
                'Отменить заказ',
                style: TextStyle(fontSize: 18.sp, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildOrderDetailRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.sp),
    child: Row(
      children: [
        Text(
          '$label ',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black54,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}
