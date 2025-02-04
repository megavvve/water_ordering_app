 import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/user_model/rating/rating.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

void onDelivererTap(YandexMapController mapController, UserModel? deliverer, Point point, Rating rating,BuildContext context) async {
    await mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 16),
      ),
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
    );

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.0.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Информация о доставщике',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text('Имя: ${deliverer?.name}'),
              Text('Телефон: ${deliverer?.phoneNumber}'),
              Text('Рейтинг: ${rating.delivererRating} звезд'),
              Text(
                  'Статус: ${deliverer?.isOnline == true ? 'Онлайн' : 'Оффлайн'}'),
              SizedBox(height: 8.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        );
      },
    );
  }