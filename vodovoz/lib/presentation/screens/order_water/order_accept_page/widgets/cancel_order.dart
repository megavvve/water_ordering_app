import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vodovoz/domain/repositories/order_repository.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_bloc.dart';
import 'package:vodovoz/presentation/providers/order_user_bloc/order_user_state.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';

Future<void> cancelOrder(BuildContext context) async {
  final orderBloc = context.read<OrderUserBloc>();

  // Check if the state is loaded and not null
  if (orderBloc.state is OrderUserLoaded) {
    final order = (orderBloc.state as OrderUserLoaded).order;

    await getIt<OrderRepository>().updateOrder(
      order.copyWith(status: 'canceled'),
    );

    SetPageWithoutBack(context, 'orderingRedirect');
  } else {
    // Handle the case where the state is not loaded
    print('OrderUserBloc state is not loaded');
  }
}
