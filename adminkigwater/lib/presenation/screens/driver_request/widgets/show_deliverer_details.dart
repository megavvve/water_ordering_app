import 'dart:typed_data';
import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/storage_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showDelivererDetails(
    BuildContext context,
    Deliverer deliverer,
    UserModel user,
    List<Geolocation> geolocationList,
    StorageRepository storageRepo,
    void Function()? onPressed) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Заявка водовоза',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Информация о пользователе
              Text('ФИО: ${user.name}',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 10.h),
              Text('Телефон: ${user.phoneNumber}',
                  style: TextStyle(fontSize: 16.sp)),
              SizedBox(height: 20.h),

              // Регион доставки
              Text('Регион доставки:',
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp)),
              Text(
                geolocationList
                    .firstWhere((x) => x.geolocationId == deliverer.userId)
                    .address,
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 20.h),
              // Дополнительная информация
              Text(
                'Свидетельство о регистрации ТС: ${deliverer.regCert}',
                style: TextStyle(
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Водительское удостоверение: ${deliverer.license}',
                style: TextStyle(
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Емкость транспортного средства: ${deliverer.capacity} литров',
                style: TextStyle(
                  fontSize: 16.sp,
                ),
              ),
              // Фото и подписи
              Wrap(
                spacing: 30.w, // Отступ между элементами по горизонтали
                runSpacing: 20.h, // Отступ между элементами по вертикали
                children: [
                  // Фото автомобиля
                  Column(
                    children: [
                      const Text('Фото автомобиля',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      FutureBuilder<Uint8List?>(
                        future: storageRepo.getVodovozPhoto(
                            deliverer.userId, "carPhoto"),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return const Text('Ошибка загрузки фото');
                          } else {
                            return SizedBox(
                              height: 500.h,
                              child: Image.memory(snapshot.data!),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  // Фото свидетельства
                  Column(
                    children: [
                      const Text('Фото свидетельства',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      FutureBuilder<Uint8List?>(
                        future: storageRepo.getVodovozPhoto(
                            deliverer.userId, "sorPhoto"),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return const Text('Ошибка загрузки фото');
                          } else {
                            return SizedBox(
                              height: 500.h,
                              child: Image.memory(snapshot.data!),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  // Фото водительского удостоверения
                  Column(
                    children: [
                      const Text('Фото удостоверения',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      FutureBuilder<Uint8List?>(
                        future: storageRepo.getVodovozPhoto(
                            deliverer.userId, "licensePhoto"),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError || !snapshot.hasData) {
                            return const Text('Ошибка загрузки фото');
                          } else {
                            return SizedBox(
                              height: 500.h,
                              child: Image.memory(snapshot.data!),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Закрыть', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: (deliverer.isAvailable==true)?Colors.red:Colors.green,
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
            ),
            child:  Text((deliverer.isAvailable==true)?'Убрать из водовозов':'Принять', style: const TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
