import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/geolocation.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/entities/user_model/rating/rating.dart';
import 'package:vodovoz/domain/entities/user_model/user_model.dart';
import 'package:vodovoz/domain/repositories/geolocation_repository.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/domain/repositories/user/rating_repository.dart';
import 'package:vodovoz/domain/repositories/storage_repository.dart';
import 'package:vodovoz/domain/repositories/user/user_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_bloc.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_event.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_state.dart';
import 'package:vodovoz/presentation/screens/order_water/order_accept_page/widgets/build_in_progress_widget.dart';
import 'package:vodovoz/presentation/screens/order_water/order_competed_page.dart';
import 'package:vodovoz/presentation/widgets/enums/order_status.dart';
import 'package:vodovoz/presentation/widgets/navigation/drawer.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';

class OrderAcceptedPage extends StatefulWidget {
  const OrderAcceptedPage({
    super.key,
  });

  @override
  OrderAcceptedPageState createState() => OrderAcceptedPageState();
}

class OrderAcceptedPageState extends State<OrderAcceptedPage> {
  UserModel? deliverer;
  Geolocation? geolocationDeliverer;
  File? avatar;
  bool hasError = false;
  double _rating = 0;

  final OrderRepository orderRepo = getIt<OrderRepository>();
  final UserRepository userRepo = getIt<UserRepository>();
  final StorageRepository storageRepo = getIt<StorageRepository>();
  final RatingRepository ratingRepo = getIt<RatingRepository>();
  final GeolocationRepository geoRepo = getIt<GeolocationRepository>();
  final AppWrite appWriteService = getIt<AppWrite>();

  @override
  void initState() {
    super.initState();
    appWriteService.subscribeToRealtimeForClientUpdateOrder(
      onUpdate: _handleRealtimeUpdate,
    );
    context.read<OrderUserBloc>().add(LoadOrderUserEvent());
  }

  void _handleRealtimeUpdate() {
    getIt<OrderUserBloc>().add(LoadOrderUserEvent());
  }

  @override
  void dispose() {
    appWriteService.unsubscribeFromRealtimeUpdates();
    super.dispose();
  }

  Future<void> _fetchDeliverer(Order order) async {
    try {
      deliverer = await userRepo.getUserById(order.delivererId);
      avatar = await storageRepo.getAvatar(
          deliverer?.fileId ?? '', deliverer?.userId ?? '');
      Rating? rating = await ratingRepo.getRating(deliverer?.ratingId ?? '');
      geolocationDeliverer = await geoRepo.getGeolocation(order.id);

      setState(() {
        _rating = rating.delivererRating;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
        });
      }
    }
  }

  Widget buildAcceptedState(BuildContext context, Order order) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ожидаем подтверждение доставщика',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.sp),
              CircleAvatar(
                radius: 70.sp,
                backgroundImage: avatar != null ? FileImage(avatar!) : null,
                backgroundColor: Colors.white,
                child: avatar == null
                    ? Icon(
                        Icons.account_circle_rounded,
                        size: 135.sp,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
              SizedBox(height: 20.sp),
              Text(
                deliverer?.name ?? 'Доставщик неизвестен',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.sp),
              Text(
                geolocationDeliverer?.address ?? 'Город неизвестен',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.grey.shade300,
                ),
              ),
              SizedBox(height: 10.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 24.sp),
                  SizedBox(width: 5.sp),
                  Text(
                    _rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.sp),
              ElevatedButton.icon(
                onPressed: () {
                  getIt<OrderUserBloc>().add(CancelOrderUserEvent());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      EdgeInsets.symmetric(vertical: 12.sp, horizontal: 24.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.sp),
                  ),
                ),
                icon: Icon(Icons.cancel, color: Colors.white),
                label: Text(
                  'Отменить заказ',
                  style: TextStyle(fontSize: 18.sp, color: Colors.white),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
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
      child: BlocBuilder<OrderUserBloc, OrderUserState>(
        builder: (context, state) {
          if (state is OrderUserLoading) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            ));
          } else if (state is OrderUserCanceled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              SetPageWithoutBack(context, 'orderingRedirect');
            });
            return SizedBox.shrink();
          } else if (state is OrderUserError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (state is OrderUserLoaded) {
            Order order = state.order;
            if (deliverer == null) {
              _fetchDeliverer(order);
            }
            if (order.status == OrderStatus.completed.name) {
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => OrderCompletedPage(order: order),
                    ),
                  );
                });
              }
              return const SizedBox.shrink();
            }
            if (order.status == OrderStatus.pending.name) {
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  SetPageWithoutBack(context, 'driversList');
                });
              }
           
              return const SizedBox.shrink();
            }

            return FutureBuilder<Geolocation?>(
              future: geoRepo.getGeolocation(order.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error loading geolocation',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'No geolocation data available',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return Scaffold(
                  endDrawer: drawer(context),
                  backgroundColor: Colors.transparent,
                  body: Padding(
                    padding: EdgeInsets.all(20.0.sp),
                    child: CustomScrollView(
                      slivers: [
                        const SliverAppBar(
                          automaticallyImplyLeading: false,
                          backgroundColor: Colors.transparent,
                          expandedHeight: kToolbarHeight,
                          centerTitle: true,
                          title: Text(
                            'Информация о заказе',
                            style: TextStyle(color: Colors.white),
                          ),
                          pinned: true,
                        ),
                        order.status == OrderStatus.accepted.name
                            ? buildAcceptedState(context, order)
                            : SliverToBoxAdapter(
                                child: buildInProgressState(
                                    context, order, snapshot.data, deliverer),
                              ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            ));
          }
        },
      ),
    );
  }
}
