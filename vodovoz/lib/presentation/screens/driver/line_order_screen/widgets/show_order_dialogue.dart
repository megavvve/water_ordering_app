// import 'package:flutter/material.dart';
// import 'package:vodovoz/domain/entities/order.dart';
// import 'package:vodovoz/presentation/screens/driver_profile/line_order_screen/widgets/order_card.dart';
// import 'package:vodovoz/presentation/screens/driver_profile/line_order_screen/widgets/show_cancel_dialogue.dart';

// void showOrderDialog(BuildContext context, Order order, OrderStatus status,
//     Function(String, OrderStatus) updateOrderStatus) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Выберите действие'),
//         content: status == OrderStatus.pending
//             ? Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   FilledButton(
//                     onPressed: () async {},
//                     child: const Text('Выезжаю'),
//                   ),
//                   FilledButton(
//                     onPressed: () {
//                       showCancelDialog(context, order, updateOrderStatus);
//                     },
//                     child: const Text('Отменить'),
//                   ),
//                 ],
//               )
//             : Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   FilledButton(
//                     onPressed: () {
//                       updateOrderStatus(order.id, OrderStatus.completed);
//                       Navigator.pop(context);
//                     },
//                     child: const Text('Выполнено'),
//                   ),
//                   FilledButton(
//                     onPressed: () {
//                       showCancelDialog(context, order, updateOrderStatus);
//                     },
//                     child: const Text('Отменить'),
//                   ),
//                 ],
//               ),
//       );
//     },
//   );
// }
