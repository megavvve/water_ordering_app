import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';

class OrderDetailsBody extends StatelessWidget {
  final Order order;
  final UserModel? customer;
  final Geolocation geolocation;
  final VoidCallback onCompletionPressed;
  final VoidCallback onCancellationPressed;

  const OrderDetailsBody({
    super.key,
    required this.order,
    required this.customer,
    required this.geolocation,
    required this.onCompletionPressed,
    required this.onCancellationPressed,
  });

  @override
  Widget build(BuildContext context) {
    String customerName = customer?.name ?? 'Неизвестно';
    bool canPop = Navigator.canPop(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent, Colors.blue],
        ),
      ),
      child: PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (bool didPop, _) async {
          if (!didPop) {
            final bool? confirmExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Выход из приложения'),
                content: const Text('Вы точно хотите выйти?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Выйти',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirmExit ?? false) {
              SystemNavigator.pop();
            }
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Информация о заказе',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _buildInfoRow('Заказчик:', customerName),
                    _buildInfoRow(
                        'Телефон:', customer?.phoneNumber ?? 'Неизвестно'),
                    _buildInfoRow('Адрес:', geolocation.address),
                    //_buildInfoRow('Тип воды:', order.waterType),
                    _buildInfoRow('Количество:',
                        '${order.quantity} ${order.isLitre! ? 'л' : 'шт'}'),
                    _buildInfoRow('Метод оплаты:', order.paymentMethod),
                    if (order.comment != null && order.comment!.isNotEmpty)
                      _buildInfoRow('Комментарий:', order.comment!),
                    if (order.price != 0)
                      _buildInfoRow('Цена:', '${order.price} ₽'),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildActionButton(
                    label: 'Завершить заказ',
                    color: Colors.greenAccent,
                    onPressed: onCompletionPressed,
                  ),
                  SizedBox(height: 15.h),
                  _buildActionButton(
                    label: 'Отменить заказ',
                    color: Colors.redAccent,
                    onPressed: onCancellationPressed,
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0.sp),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.sp),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 15.h,
          horizontal: 30.w,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18.sp,
          color: Colors.white,
        ),
      ),
    );
  }
}
