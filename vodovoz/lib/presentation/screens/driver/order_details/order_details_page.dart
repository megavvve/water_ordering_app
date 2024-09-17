import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/usecases/get_user_by_id.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/delivery_order_bloc/deliverer_order_bloc.dart';
import 'package:vodovoz/presentation/screens/driver/order_details/widget/order_details_body.dart';
import 'package:vodovoz/presentation/screens/driver/order_details/widget/show_cancelation_diaolg.dart';
import 'package:vodovoz/presentation/screens/driver/order_details/widget/show_completition_dialog.dart';
import 'package:vodovoz/presentation/screens/driver/order_details/widget/show_confirmation_dialogue.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({Key? key}) : super(key: key);

  Future<UserModel?> _fetchUser(String userId) async {
    return getIt<GetUserById>().call(userId);
  }

  Future<Geolocation?> _fetchGeolocation(String orderId) async {
    return getIt<GeolocationRepository>().getGeolocation(orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 30.h,
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text(
          'Детали заказа',
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
        ),
      ),
      body: BlocBuilder<DelivererOrderBloc, DelivererOrderState>(
        builder: (context, state) {
          if (state is OrderAlreadyAccepted) {
            final order = state.order;

            if (order.status == 'accepted') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showConfirmationDialogForOrderDetails(order, context);
              });
            }

            return FutureBuilder<UserModel?>(
              future: _fetchUser(order.customerId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (userSnapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Ошибка загрузки данных пользователя',
                    ),
                  );
                } else if (userSnapshot.hasData) {
                  final customer = userSnapshot.data;
                  return FutureBuilder<Geolocation?>(
                    future: _fetchGeolocation(order.id),
                    builder: (context, geoSnapshot) {
                      if (geoSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      } else if (geoSnapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Ошибка загрузки геолокации',
                          ),
                        );
                      } else if (geoSnapshot.hasData) {
                        final geolocation = geoSnapshot.data!;
                        return OrderDetailsBody(
                          order: order,
                          customer: customer,
                          geolocation: geolocation,
                          onCompletionPressed: () {
                            showCompletionDialog(context, order);
                          },
                          onCancellationPressed: () {
                            showCancellationDialogForOrderDetails(
                                order, context);
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'Геолокация не найдена',
                          ),
                        );
                      }
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      'Пользователь не найден',
                    ),
                  );
                }
              },
            );
          } else if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          } else if (state is OrderCompleted) {
            //TODO update isAvalible of deliver
            WidgetsBinding.instance.addPostFrameCallback((_) {
              SetPageWithoutBack(context, 'delivery');
            });
            return const SizedBox.shrink();
          } else {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: const Center(
                child: Text(
                  'Нет активного заказа',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
