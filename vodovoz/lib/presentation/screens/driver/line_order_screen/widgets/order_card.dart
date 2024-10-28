import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/widgets/enums/order_status.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const OrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final OrderStatus status = OrderStatus.values.firstWhere(
        (e) => e.name == order.status,
        orElse: () => OrderStatus.pending);

    return SizedBox(
      width: 330.w,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0.sp),
        ),
        elevation: 8.0,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16.0.sp),
          child: FutureBuilder<Geolocation?>(
              future: getIt<GeolocationRepository>().getGeolocation(order.id),
              builder: (context, snapshot) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.water_drop,
                              color: Colors.blueAccent, size: 24.0.sp),
                          SizedBox(width: 10.w),
                          Text(
                            '${order.quantity} шт',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Colors.blueAccent, size: 24.0.sp),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              snapshot.data?.address ?? '',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet,
                              color: Colors.blueAccent, size: 24.0),
                          SizedBox(width: 10.w),
                          Text(
                            order.paymentMethod,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      if (status == OrderStatus.awaitingConfirmation) ...[
                        Text(
                          'Заказ ждет подтверждения пользователя',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 10.h),
                      ],
                      if (status == OrderStatus.pending) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.0.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: onAccept,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                ),
                                child: Text(
                                  'Принять',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: onReject,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                                child: Text(
                                  'Отклонить',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ]);
              }),
        ),
      ),
    );
  }
}
