import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/usecases/get_user_by_id.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/user_model/rating/rating.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/user/rating_repository.dart';
import 'package:vodovoz/domain/repositories/storage_repository.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/utils/input_decorations.dart';

class DelivererWidgetWithAcceptReject extends StatefulWidget {
  final Deliverer deliverer;
  final Future<void> Function(UserModel) onAccept;
  final Future<void> Function(UserModel) onReject;

  const DelivererWidgetWithAcceptReject({
    super.key,
    required this.deliverer,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<DelivererWidgetWithAcceptReject> createState() =>
      _DelivererWidgetState();
}

class _DelivererWidgetState extends State<DelivererWidgetWithAcceptReject> {
  final StorageRepository storageRepo = getIt<StorageRepository>();
  final UserRepository userRepo = getIt<UserRepository>();
  final RatingRepository ratingRepo = getIt<RatingRepository>();

  UserModel? deliverer;
  File? avatar;
  Rating? rating;
  Geolocation? geolocation;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDelivererData();
  }

  Future<void> _loadDelivererData() async {
    try {
      // Загружаем доставщика
      deliverer = await getIt<GetUserById>().call(widget.deliverer.userId);

      // Загружаем аватар, если доступен
      if (deliverer?.fileId != null && deliverer!.fileId!.isNotEmpty) {
        avatar = await storageRepo.getAvatar(
            deliverer!.fileId ?? '', deliverer!.userId);
      }

      // Загружаем рейтинг доставщика
      if (deliverer?.ratingId != null && deliverer!.ratingId!.isNotEmpty) {
        rating = await ratingRepo.getRating(deliverer!.ratingId ?? '');
      }

      // Загружаем геолокацию доставщика
      if (deliverer?.geolocationId != null &&
          deliverer!.geolocationId!.isNotEmpty) {
        geolocation = await getIt<GeolocationRepository>()
            .getGeolocation(deliverer!.geolocationId ?? '');
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Ошибка загрузки данных: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 250.h,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (deliverer == null || geolocation == null) {
      return const Center(child: Text('Информация о доставщике недоступна.'));
    }

    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              avatar != null
                  ? CircleAvatar(
                      radius: 30.sp,
                      backgroundImage: FileImage(avatar!),
                    )
                  : Padding(
                      padding: EdgeInsets.all(5.sp),
                      child: Icon(
                        Icons.account_circle_rounded,
                        size: 55.sp,
                      ),
                    ),
              SizedBox(width: 10.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deliverer!.name,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Город: ${geolocation!.address}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16.sp,
                      ),
                    ),
                    rating != null
                        ? Text(
                            'Рейтинг: ${rating!.delivererRating}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16.sp,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton(
                onPressed: () {
                  widget.onAccept(deliverer!);
                },
                style: btnStlGreen,
                child: Text(
                  'Принять',
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(
                width: 15.w,
              ),
              FilledButton(
                onPressed: () {
                  widget.onReject(deliverer!);
                },
                style: btnStlGrey,
                child: Text('Отклонить', style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
