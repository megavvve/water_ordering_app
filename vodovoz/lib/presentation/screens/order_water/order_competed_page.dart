import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/entities/user_model/rating/review.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/domain/repositories/user/rating_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';
import 'package:vodovoz/utils/constants.dart';

class OrderCompletedPage extends StatefulWidget {
  final Order? order;

  const OrderCompletedPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  _OrderCompletedPageState createState() => _OrderCompletedPageState();
}

class _OrderCompletedPageState extends State<OrderCompletedPage> {
  final TextEditingController _commentController = TextEditingController();
  final RatingRepository ratingRepo = getIt<RatingRepository>();
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent, Colors.blueGrey],
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            const SliverAppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              pinned: true,
            ),
            SliverPadding(
              padding: EdgeInsets.all(16.0.w),
              sliver: SliverToBoxAdapter(
                child: FutureBuilder<Geolocation?>(
                  future: getIt<GeolocationRepository>().getGeolocation(
                      widget.order?.id ?? LocalSavedData().getCurrentOrderId()),
                  builder: (context, snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ваш заказ выполнен!',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Информация о заказе:',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Номер заказа: ${widget.order?.id.hashCode}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Адрес доставки: ${snapshot.data?.address}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Количество воды: ${widget.order?.quantity} ${widget.order!.isLitre! ? 'л' : 'шт'}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          'Тип воды: ${widget.order?.waterType}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 10.h),
                        Divider(
                          color: Colors.white,
                          height: 1.h,
                        ),
                        SizedBox(height: 30.h),
                        Center(
                          child: Text(
                            'Оцените доставку',
                            style:
                                TextStyle(fontSize: 30.sp, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Center(
                          child: RatingBar.builder(
                            initialRating: 0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding:
                                EdgeInsets.symmetric(horizontal: 4.0.h),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              rating = rating;
                            },
                          ),
                        ),
                        SizedBox(height: 20.h),
                        TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            focusColor: Colors.white,
                            hoverColor: Colors.white,
                            iconColor: Colors.white,
                            labelText: 'Оставьте комментарий',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 20.h),
                        ElevatedButton(
                          onPressed: () async {
                            await _submitRating();
                            SetPageWithoutBack(context, 'profile');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text(
                            'Отправить',
                            style:
                                TextStyle(fontSize: 18.sp, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRating() async {
    String comment = _commentController.text;
    final review = Review(
      id: ID.unique(),
      toWhomUserId: widget.order?.delivererId ?? '',
      fromWhomUserId: widget.order?.customerId ?? '',
      orderId: widget.order?.id ?? '',
      rating: _rating,
      isDeliverer: true,
      comment: comment,
      date: dateTimeCorrectForm,
    );
    await ratingRepo.addReviewForRating(review: review);
    await getIt<OrderRepository>()
        .updateOrder(widget.order!.copyWith(isFinish: true));
    LocalSavedData().saveCurrentOrderId('');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
