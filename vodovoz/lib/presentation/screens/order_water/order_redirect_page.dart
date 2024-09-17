import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/data/datasources/remote/appwrite.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_bloc.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_event.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_state.dart';
import 'package:vodovoz/presentation/screens/order_water/order_accept_page/order_accept_page.dart';
import 'package:vodovoz/presentation/widgets/enums/order_status.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';
import 'package:vodovoz/injection_container.dart';

class OrderStatusRedirectPage extends StatefulWidget {
  const OrderStatusRedirectPage({Key? key}) : super(key: key);

  @override
  State<OrderStatusRedirectPage> createState() =>
      _OrderStatusRedirectPageState();
}

class _OrderStatusRedirectPageState extends State<OrderStatusRedirectPage> {
  late final OrderUserBloc _orderUserBloc;
  final appWriteService = getIt<AppWrite>();

  @override
  void initState() {
    super.initState();
    _orderUserBloc = getIt<OrderUserBloc>();
    _orderUserBloc.add(LoadOrderUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderUserBloc,
      child: BlocListener<OrderUserBloc, OrderUserState>(
        listener: (context, state) {
          if (state is OrderUserLoaded) {
            final Order order = state.order;
            LocalSavedData().saveCurrentOrderId(order.id);

            if (order.status == 'accepted' ||
                order.status == 'inProgress' ||
                order.status == OrderStatus.completed.name) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderAcceptedPage(),
                ),
              );
            } else {
              if (mounted) {
                SetPageWithoutBack(context, 'driversList');
              }
            }
          } else if (state is OrderUserInitial) {
            SetPageWithoutBack(context, 'pushOrder');
          } else if (state is OrderUserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                ),
              ),
            );
          }
        },
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueAccent, Colors.blueGrey],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
