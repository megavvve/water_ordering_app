import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/push_notifications.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/repositories/deliverer_repository.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';
import 'package:vodovoz/domain/usecases/add_order_use_case.dart';
import 'package:vodovoz/domain/usecases/get_user_by_id.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/screens/order_water/push_order_page/widgets/show_alert_dialogue.dart';
import 'package:vodovoz/presentation/widgets/enums/order_status.dart';
import 'package:vodovoz/presentation/widgets/location_selection_widget/location_selection_widget.dart';
import 'package:vodovoz/presentation/widgets/widgets_for_getting.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/presentation/widgets/navigation/drawer.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';
import 'package:vodovoz/utils/constants.dart';
import 'package:vodovoz/utils/input_decorations.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class PushOrderPage extends StatefulWidget {
  const PushOrderPage({super.key});

  @override
  State<StatefulWidget> createState() => _PushOrderPageState();
}

class _PushOrderPageState extends State<PushOrderPage> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController adressController = TextEditingController();
  List<bool> isSelected = [true, false];
  Point? selectedLocation;
  String? selectedAddress;
  String? _quantityError;
  int? _selectedWaterType;
  int? _selectedPaymentMethod;
  bool isLitre = true;
  bool _isButtonEnabled = false;
  final UserRepository userRepo = getIt<UserRepository>();
  final delivererRepo = getIt<DelivererRepository>();
  @override
  void initState() {
    super.initState();

    quantityController.addListener(() {
      final quantity = int.tryParse(quantityController.text) ?? 0;
      if (quantity > 999999999999999999) {
        setState(() {
          _quantityError = 'Количество не может быть слишком большим';
        });
      } else {
        setState(() {
          _quantityError = null;
        });
      }
      _checkButtonEnabled();
    });
  }

  void _checkButtonEnabled() {
    setState(() {
      _isButtonEnabled = quantityController.text.isNotEmpty &&
          selectedLocation != null &&
          adressController.text.isNotEmpty &&
          _selectedWaterType != null &&
          _selectedPaymentMethod != null &&
          _quantityError == null;
    });
  }

  @override
  void dispose() {
    quantityController.dispose();
    commentController.dispose();
    adressController.dispose();
    super.dispose();
  }

  Future<void> pushOrder() async {
    try {
      final token = await PushNotifications.getDeviceToken();
      final id = ID.unique();
      final userById =
          await getIt<GetUserById>().call(LocalSavedData().getUserId());

      // Проверка, есть ли у пользователя номер телефона
      if (userById?.phoneNumber == null || userById!.phoneNumber.isEmpty) {
        // Показываем диалоговое окно с предупреждением
        showPhoneAlert(context);
        return;
      }
      Order order = Order(
          id: id,
          customerId: LocalSavedData().getUserId(),
          delivererId: "",
          geolocationId: id,
          waterType: getWaterTypeLabel(_selectedWaterType ?? 1),
          quantity: int.parse(quantityController.text),
          paymentMethod: getPayTypeLabel(_selectedPaymentMethod ?? 1),
          status: OrderStatus.pending.name,
          createdAt: dateTimeCorrectForm,
          comment: commentController.text,
          idsOfPossibleDeliverers: [],
          idsOfNotPossibleDeliverers: [],
          isLitre: isLitre,
          price: 0);
      await getIt<GeolocationRepository>().createGeolocation(
        id,
      );
      await getIt<GeolocationRepository>().updateGeolocation(
        Geolocation(
          geolocationId: id,
          address: adressController.text,
          latitude: selectedLocation!.latitude.toString(),
          longitude: selectedLocation!.longitude.toString(),
        ),
      );

      await getIt<AddOrder>().call(order);

      await userRepo.updateUser(
        userById.copyWith(isOnline: true, userType: 'user', token: token),
      );
      try {
        final deliverer =
            await delivererRepo.getDeliverer(LocalSavedData().getUserId());

        if (deliverer?.isAvailable == true) {
          delivererRepo
              .updateDeliverer(deliverer!.copyWith(isAvailable: false));
        }
      } catch (e) {
        print(e);
      }

      LocalSavedData().saveCurrentOrderId(id);
      if (mounted) {
        SetPageWithoutBack(context, 'orderingRedirect');
      }
    } catch (e) {
      print('Ошибка при добавлении заказа: $e');
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(
                        5.sp,
                      ),
                      child: Text(
                        'Оформление заказа',
                        style: TextStyle(
                          fontSize: 34.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(
                        10.sp,
                      ),
                      child: SizedBox(
                        width: 300.w,
                        child: DropdownMenu(
                          onSelected: (value) {
                            setState(() {
                              _selectedWaterType = value;
                              _checkButtonEnabled();
                            });
                          },
                          inputDecorationTheme: inpDecStl,
                          dropdownMenuEntries: waterTypes,
                          label: const Text('Тип воды'),
                          width: 300.w,
                          textStyle:
                              TextStyle(fontSize: 15.sp, color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(
                        10.sp,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 135.w,
                            child: TextField(
                              maxLines: null,
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  fontSize: 24.sp, color: Colors.black),
                              decoration: inptDec1('Количество', true).copyWith(
                                errorText: _quantityError,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          ToggleButtons(
                            isSelected: isSelected,
                            onPressed: (int index) {
                              setState(() {
                                for (int buttonIndex = 0;
                                    buttonIndex < isSelected.length;
                                    buttonIndex++) {
                                  if (buttonIndex == index) {
                                    isSelected[buttonIndex] = true;
                                  } else {
                                    isSelected[buttonIndex] = false;
                                  }
                                }
                                isLitre = isSelected[0];
                              });
                            },
                            borderRadius: BorderRadius.circular(16.sp),
                            selectedBorderColor: Colors.blue,
                            selectedColor: Colors.white,
                            fillColor: Colors.green,
                            borderColor: Colors.white,
                            splashColor: Colors.green[300],
                            children: [
                              SizedBox(
                                width: 70.w,
                                height: 60.h,
                                child: Center(
                                    child: Text(
                                  'Литры',
                                  style: TextStyle(fontSize: 16.sp),
                                )),
                              ),
                              SizedBox(
                                width: 70.w,
                                height: 60.h,
                                child: Center(
                                    child: Text(
                                  'Штуки',
                                  style: TextStyle(fontSize: 16.sp),
                                )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    LocationSelectionWidget(
                      initialAddress: adressController.text,
                      onLocationSelected: (point, address) {
                        setState(() {
                          selectedLocation = point;
                          selectedAddress = address;
                          adressController.text = address;
                          _checkButtonEnabled();
                        });
                        Navigator.of(context).pop();
                      },
                      labelText: 'Адрес доставки',
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.sp),
                      child: SizedBox(
                        width: 300.w,
                        child: DropdownMenu(
                          onSelected: (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                              _checkButtonEnabled();
                            });
                          },
                          inputDecorationTheme: inpDecStl,
                          dropdownMenuEntries: payType,
                          label: const Text('Способ оплаты'),
                          width: 300.w,
                          textStyle:
                              TextStyle(fontSize: 15.sp, color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.sp),
                      child: SizedBox(
                        width: 300.w,
                        child: TextField(
                          controller: commentController,
                          style:
                              TextStyle(fontSize: 24.sp, color: Colors.black),
                          decoration: inptDec1('Комментарий', true),
                        ),
                      ),
                    ),
                    _isButtonEnabled
                        ? Padding(
                            padding: EdgeInsets.all(10.sp),
                            child: SizedBox(
                              height: 60.h,
                              width: 300.w,
                              child: FilledButton(
                                onPressed: pushOrder,
                                style: btnStl,
                                child: const Text('Заказать'),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ],
            ),
          ],
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        endDrawer: drawer(context),
      ),
    );
  }
}
