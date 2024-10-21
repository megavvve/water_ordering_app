import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/local/money_repository.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/presentation/screens/order_water/drivers_list_page/widget/deliverer_widget_with_accept_reject.dart';

void showDelivererPopup(BuildContext context, List<Deliverer> delivererPossibleList,Future<void> Function(UserModel) acceptOrder,Future<void> Function(UserModel) rejectOrder,Order order,MoneyRepository moneyRepo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Доступные водители'),
          contentPadding: EdgeInsets.all(1.sp),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: delivererPossibleList.length,
              itemBuilder: (BuildContext context, int index) {
                final deliverer = delivererPossibleList[index];

                return DelivererWidgetWithAcceptReject(
                    deliverer: deliverer,
                    onAccept: acceptOrder,
                    onReject: rejectOrder,price:moneyRepo.getOrderPriceWithPotentialDeliverer(order,deliverer,),);
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }