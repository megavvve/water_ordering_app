import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/injection_container.dart';

class OrderInfoWidget extends StatefulWidget {
  final Order order;
  final VoidCallback onCancelOrder;

  const OrderInfoWidget({
    Key? key,
    required this.order,
    required this.onCancelOrder,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OrderInfoWidgetState createState() => _OrderInfoWidgetState();
}

class _OrderInfoWidgetState extends State<OrderInfoWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            16.sp,
          ),
        ),
        padding: EdgeInsets.all(15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Заказ №${widget.order.id.hashCode}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_sharp,
                  size: 40.sp,
                )
              ],
            ),
            if (_isExpanded) ...[
              SizedBox(height: 10.h),
              FutureBuilder<Geolocation?>(
                future: getIt<GeolocationRepository>()
                    .getGeolocation(widget.order.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Ошибка загрузки геолокации',
                      style: TextStyle(fontSize: 16.sp, color: Colors.red),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Адрес: ${snapshot.data?.address}',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Тип воды: ${widget.order.waterType}',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Количество: ${widget.order.quantity} шт.',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(height: 10.h),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _showCancelDialog(context),
                          child: const Text('Отменить заказ'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтверждение'),
          content: const Text('Вы точно хотите отменить заказ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Нет'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCancelOrder();
              },
              child: const Text('Да'),
            ),
          ],
        );
      },
    );
  }
}
