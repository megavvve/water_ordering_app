import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/domain/usecases/get_user_by_id.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/delivery_order_bloc/deliverer_order_bloc.dart';
import 'package:vodovoz/presentation/screens/driver/order_details/widget/order_details_body.dart';
import 'package:vodovoz/presentation/screens/driver/order_details/widget/show_cancelation_diaolg.dart';
import 'package:vodovoz/presentation/screens/driver/order_details/widget/show_completition_dialog.dart';
import 'package:vodovoz/presentation/screens/driver/order_details/widget/show_confirmation_dialogue.dart';
import 'package:vodovoz/presentation/widgets/enums/order_status.dart';
import 'package:vodovoz/presentation/widgets/navigation/drawer.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

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
      endDrawer: drawer(context),
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
          // if (state is OrderAccepted) {
          //   final order = state.order;
          //   if (order.status == OrderStatus.pending.name) {
          //     Navigator.of(context);
          //     WidgetsBinding.instance.addPostFrameCallback((_) {
          //       SetPageWithoutBack(context, 'delivery');
          //     });
          //   }
   if (state is OrderAlreadyAccepted) {
            final order = state.order;

            if (order.status == OrderStatus.pending.name) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                SetPageWithoutBack(context, 'line');
              });
            }
            if (order.status == OrderStatus.accepted.name) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showConfirmationDialogForOrderDetails(order, context);
              });
            }
            if (order.status == OrderStatus.canceled.name) {
              Navigator.of(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                SetPageWithoutBack(context, 'delivery');
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              SetPageWithoutBack(context, 'delivery');
            });
            return const SizedBox.shrink();
          } else if (state is OrderCanceled) {
            final canceledOrder = state.order;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
              SetPageWithoutBack(context, 'delivery');

              // Показываем всплывающее окно с информацией об отменённом заказе
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Заказ отменён'),
                    content: Text(
                        'Заказ №${canceledOrder.id.hashCode} был отменён пользователем.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          // Обновляем статус завершенности заказа
                          getIt<OrderRepository>().updateOrder(
                            canceledOrder.copyWith(
                              isFinish: true,
                            ),
                          );
                          Navigator.of(context).pop(); // Закрыть диалог
                        },
                        child: Text('Закрыть'),
                      ),
                    ],
                  );
                },
              );
            });
          }else if (state is OrderReject) {
            final canceledOrder = state.order;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
              SetPageWithoutBack(context, 'line');
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Отказ от заказа'),
                    content: Text(
                        'Вы отказались от заказа №${canceledOrder.id.hashCode} '),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                         
                          Navigator.of(context).pop(); 
                        },
                        child: Text('Закрыть'),
                      ),
                    ],
                  );
                },
              );
            });
          }
          return const Center(
            child: CircularProgressIndicator(color: Colors.white,),
          );
        },
      ),
    );
  }
}
