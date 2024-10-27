import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/domain/entities/order.dart';
import 'package:vodovoz/presentation/screens/history_screen/widgets/order_item_widget.dart';

Widget buildOrderList(List<Order> filteredOrders) {
  return filteredOrders.isNotEmpty
      ? SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.sp), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 2), // Shadow offset
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical:5.h,horizontal: 10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...filteredOrders.map((order) => Column(
                        children: [
                          OrderItemWidget(order: order),
                          Divider(color: Colors.grey, thickness: 1.h),
                        ],
                      ))
                ],
              ),
            ),
          ),
        )
      : SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(5.sp),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.sp), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2), // Shadow offset
                  ),
                ],
              ),
              width: 300.w,
              child: Padding(
                padding: EdgeInsets.all(20.0.sp),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 155.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Нет данных для выбранной даты',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
}

Widget buildDriverOrderList(List<Order> filteredOrders, String cuurentDate) {
  final Map<String, List<Order>> groupedOrders = {};
  for (var order in filteredOrders) {
    groupedOrders
        .putIfAbsent(order.updatedAt ?? order.createdAt, () => [])
        .add(order);
  }

  return groupedOrders.isNotEmpty
      ? SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = groupedOrders.entries.elementAt(index);
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.sp), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2), // Shadow offset
                    ),
                  ],
                ),
                child: Padding(
                   padding: EdgeInsets.symmetric(vertical:5.h,horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...entry.value.map((order) => Column(
                            children: [
                              OrderItemWidget(order: order),
                              Divider(color: Colors.grey, thickness: 1.h),
                            ],
                          ))
                    ],
                  ),
                ),
              );
            },
            childCount: groupedOrders.length,
          ),
        )
      : SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(5.sp),
            child: Card(
              color: Colors.white,
              child: SizedBox(
                width: 300.w,
                child: Padding(
                  padding: EdgeInsets.all(25.sp),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 155.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Нет данных для выбранной даты',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
}
