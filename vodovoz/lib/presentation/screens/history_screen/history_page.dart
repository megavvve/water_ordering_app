import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/domain/entities/deliverer.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/domain/usecases/get_deliverer_by_id.dart';
import 'package:vodovoz/domain/usecases/get_user_by_id.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/screens/history_screen/widgets/widgtes_for_lists_orders_differents_types_of_users.dart';
import 'package:vodovoz/utils/enums/user_type.dart';
import 'package:vodovoz/presentation/widgets/navigation/drawer.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';
import 'package:vodovoz/utils/constants.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedDate = dateTimeCorrectForm;
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  final OrderRepository orderRepository = getIt<OrderRepository>();
  bool isDriver = false;
  Deliverer? driver;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _checkUserRole();
  }

  Future<void> _fetchOrders() async {
    final fetchedOrders = await orderRepository.getOrders();
    setState(() {
      orders = fetchedOrders;
      filteredOrders = fetchedOrders;
    });
  }

  Future<void> _checkUserRole() async {
    final user = await getIt<GetUserById>().call(LocalSavedData().getUserId());
    setState(() {
      isDriver = user!.userType == UserType.deliverer.name;
    });
    if (isDriver) {
      driver = await getIt<GetDelivererById>().call(user!.userId);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canPop = Navigator.canPop(context);
    List<Order> filteredOrders =
        orders.where((x) => x.createdAt == selectedDate).toList();
    if (!isDriver) {
      filteredOrders = filteredOrders
          .where((x) => x.customerId == LocalSavedData().getUserId())
          .toList();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blueAccent, Colors.blueGrey],
        ),
      ),
      child: PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (bool didPop, _) async {
          if (!didPop) {
            final bool? confirmExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Выход из приложения'),
                content: const Text('Вы точно хотите выйти?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Отмена'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Выйти'),
                  ),
                ],
              ),
            );

            if (confirmExit ?? false) {
              if (mounted) SystemNavigator.pop();
            }
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              const SliverAppBar(
                backgroundColor: Colors.transparent,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0.sp),
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            (isDriver)
                                ? 'Список заказов на $selectedDate'
                                : 'Список ваших заказов на $selectedDate',
                            style:
                                TextStyle(fontSize: 20.sp, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding:
                    EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 20.0.h),
                sliver: isDriver
                    ? buildDriverOrderList(filteredOrders, selectedDate)
                    : buildOrderList(filteredOrders),
              ),
              SliverPadding(
                padding:
                    EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 10.0.h),
                sliver: SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isDriver) {
                          (driver?.isAvailable == null)
                              ? SetPageWithoutBack(context, 'driver')
                              : SetPageWithoutBack(context, 'line');
                        } else {
                          SetPageWithoutBack(context, 'orderingRedirect');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.orange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: 50.h,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isDriver ? 'Выйти на линию' : 'Сделать заказ',
                            style:
                                TextStyle(fontSize: 18.sp, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 20.h,
                ),
              ),
            ],
          ),
          endDrawer: drawer(context),
        ),
      ),
    );
  }
}
