import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/entities/user_model/rating/review.dart';
import 'package:vodovoz/domain/usecases/get_deliverer_by_id.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/delivery_order_bloc/deliverer_order_bloc.dart';
import 'package:vodovoz/utils/constants.dart';

void showCompletionDialog(
  BuildContext context,
  Order order,
) {
  TextEditingController commentController = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      double _rating = 0.0;

      return AlertDialog(
        title: const Text('Оцените заказ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              'Пожалуйста, оцените заказ:',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16.0.h),
            RatingBar.builder(
              initialRating: 0.0,
              minRating: 1.0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding:  EdgeInsets.symmetric(horizontal: 4.0.w),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                _rating = rating;
              },
            ),
            SizedBox(height: 16.0.h),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Оставьте комментарий',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:  Text(
              'Отмена',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<DelivererOrderBloc>(context).add(
                CompleteOrder(
                  order,
                  Review(
                    id: ID.unique(),
                    toWhomUserId: order.customerId,
                    fromWhomUserId: order.delivererId,
                    orderId: order.id,
                    rating: _rating,
                    isDeliverer: false,
                    comment: commentController.text,
                    date: dateTimeCorrectForm,
                    isReviewForCanceledOrder: false
                  ),
                ),
              );
              _updateDelivererAvailability(order.delivererId);
              Navigator.of(context).pop();
            },
            child:  Text(
              'Отправить',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _updateDelivererAvailability(String delivererId) async {
  final deliverer = await getIt<GetDelivererById>().call(delivererId);
  if (deliverer != null) {
    deliverer.isAvailable = false;
    deliverer.waterType = '';
  }
}
