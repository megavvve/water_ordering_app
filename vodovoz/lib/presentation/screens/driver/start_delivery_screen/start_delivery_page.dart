import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/push_notifications.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/storage_repository.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/form_change_notifier.dart';
import 'package:vodovoz/presentation/widgets/enums/user_type.dart';
import 'package:vodovoz/presentation/widgets/widgets_for_getting.dart';
import 'package:vodovoz/presentation/widgets/navigation/drawer.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';
import 'package:vodovoz/utils/constants.dart';

import 'package:vodovoz/utils/input_decorations.dart';

class StartDeliveryPage extends StatefulWidget {
  const StartDeliveryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StartDeliveryPageState();
}

class _StartDeliveryPageState extends State<StartDeliveryPage> {
  UserModel? user;
  File? avatar;
  String? selectedWaterType;
  String? fileId;
  final userid = LocalSavedData().getUserId();
  final UserRepository userRepository = getIt<UserRepository>();
  final DelivererRepository delivererRepository = getIt<DelivererRepository>();
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      user = await userRepository.getUserById(userid);
      setState(() {
        fileId = user?.fileId ?? '';
      });
    } catch (e) {
      print('Failed to load user data: $e');
    }
  }

  Future<void> updateDeliverer() async {
    final token = await PushNotifications.getDeviceToken();
    if (user != null && selectedWaterType != null) {
      userRepository.updateUser(user!.copyWith(token: token,userType: UserType.deliverer.name));
      Deliverer? deliverer = await delivererRepository.getDeliverer(userid);
      if (deliverer != null) {
        
        deliverer.waterType = selectedWaterType!;
        deliverer.isAvailable = true;
        await delivererRepository.saveDeliverer(deliverer);
      }
    }
  }

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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        endDrawer: drawer(context),
        body: FutureBuilder<File?>(
          future: fileId != null && fileId!.isNotEmpty
              ? getIt<StorageRepository>().getAvatar(fileId!, userid)
              : Future.value(null),
          builder: (context, snapshot) {
            avatar = snapshot.data;
            return FutureBuilder<Geolocation?>(
                future: getIt<GeolocationRepository>().getGeolocation(userid),
                builder: (context2, snapshot2) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(5.sp),
                              child: Text(
                                'Профиль водовоза',
                                style: TextStyle(
                                    fontSize: 34.sp, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.sp),
                              child: SizedBox(
                                child: Card(
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20.w, vertical: 10.h),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              avatar != null
                                                  ? CircleAvatar(
                                                      radius: 30.sp,
                                                      backgroundImage:
                                                          FileImage(
                                                        avatar!,
                                                      ),
                                                    )
                                                  : Padding(
                                                      padding:
                                                          EdgeInsets.all(5.sp),
                                                      child: Icon(
                                                        Icons
                                                            .account_circle_rounded,
                                                        size: 55.sp,
                                                      ),
                                                    ),
                                              SizedBox(
                                                  width:
                                                      10.sp), // Added spacing
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.all(5.sp),
                                                  child: Text(
                                                    user?.name ?? 'Водовоз 1',
                                                    style: TextStyle(
                                                        fontSize: 20.sp,
                                                        color: Colors.black),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    softWrap:
                                                        true, // Allow text to wrap
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(5.sp),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Город: ${snapshot2.data?.address ?? 'Не указан'}',
                                                style: TextStyle(
                                                    fontSize: 18.sp,
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                'Телефон: ${user?.phoneNumber ?? 'Не указан'}',
                                                style: TextStyle(
                                                    fontSize: 18.sp,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.sp),
                              child: SizedBox(
                                height: 60.h,
                                width: 300.w,
                                child: DropdownMenu<dynamic>(
                                  onSelected: (value) {
                                    setState(() {
                                      selectedWaterType =
                                          getWaterTypeLabel(value);
                                      getIt<FormChangeNotifier>().watertype =
                                          getWaterTypeLabel(value);
                                      LocalSavedData().saveDelivererWaterType(
                                        selectedWaterType ??
                                            LocalSavedData()
                                                .getDelivererWaterType(),
                                      );
                                    });
                                  },
                                  inputDecorationTheme: inpDecStl,
                                  dropdownMenuEntries: waterTypes,
                                  label: const Text('Тип воды'),
                                  width: 300.w,
                                  textStyle: TextStyle(
                                      fontSize: 15.sp, color: Colors.black),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.sp),
                              child: SizedBox(
                                height: 60.h,
                                width: 300.w,
                                child: FilledButton(
                                  onPressed: selectedWaterType != null
                                      ? () async {
                                          await updateDeliverer();
                                          SetPageWithBack(context, 'line');
                                        }
                                      : null,
                                  style: btnStl,
                                  child: const Text('Выйти на линию'),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.sp),
                              child: SizedBox(
                                height: 60.h,
                                width: 300.w,
                                child: FilledButton(
                                  onPressed: () {
                                    SetPageWithBack(context, 'driver');
                                  },
                                  style: btnStl,
                                  child: const Text('Изменить'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
