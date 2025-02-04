import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/data/datasources/local/local_saved_data.dart';
import 'package:vodovoz/domain/usecases/get_deliverer_by_id.dart';
import 'package:vodovoz/injection_container.dart';
import 'package:vodovoz/presentation/widgets/navigation/set_page.dart';

Drawer drawer(BuildContext context) {
  final isUserIsDeliverer = getIt<LocalSavedData>().getIsUserIsDeliverer();
  return Drawer(
    width: 250,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 40.h),
          decoration: const BoxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  'Профиль',
                  style: TextStyle(fontSize: 24.sp, color: Colors.black),
                ),
                onTap: () {
                  SetPageWithoutBack(context, 'profile');
                },
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'История заказов',
                  style: TextStyle(fontSize: 24.sp, color: Colors.black),
                ),
                onTap: () {
                  SetPageWithoutBack(context, 'history');
                },
              ),
              const Divider(),
              // ListTile(
              //   title:  Text(
              //     'Активные заказы',
              //     style: TextStyle(fontSize: 24.sp, color: Colors.black),
              //   ),
              //   onTap: () {
              //     SetPageWithoutBack(context, 'activeOrders');
              //   },
              // ),
              //  const Divider(),
              ListTile(
                title: Text(
                  'Сделать заказ',
                  style: TextStyle(fontSize: 24.sp, color: Colors.black),
                ),
                onTap: () {
                  SetPageWithoutBack(context, 'orderingRedirect');
                },
              ),
              const Divider(),
              ListTile(
                title: Text(
                  (isUserIsDeliverer == false || isUserIsDeliverer == null)
                      ? 'Стать водовозом'
                      : 'Режим водовоза',
                  style: TextStyle(fontSize: 24.sp, color: Colors.black),
                ),
                onTap: () async {
                  String driverRoute = 'driver';
                  final deliverer = await getIt<GetDelivererById>()
                      .call(LocalSavedData().getUserId());
                  if (deliverer != null) {
                    if (deliverer.isAvailable != null) {
                      if (deliverer.isAvailable == true) {
                        driverRoute = "line";
                      } else {
                        driverRoute = "delivery";
                      }
                    }
                  }
                  SetPageWithoutBack(context, driverRoute);
                },
              ),
              const Divider(),
              isUserIsDeliverer == true
                  ? ListTile(
                      title: Text(
                        'Баланс водовоза',
                        style: TextStyle(fontSize: 24.sp, color: Colors.black),
                      ),
                      onTap: () {
                        SetPageWithoutBack(context, 'delivererBalance');
                      },
                    )
                  : SizedBox.shrink(),
              // const Divider(),
              // ListTile(
              //   title: Text(
              //     'Приобрести премиум',
              //     style: TextStyle(fontSize: 24.sp, color: Colors.black),
              //   ),
              //   onTap: () {
              //     showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return AlertDialog(
              //           content: SizedBox(
              //             width: 300,
              //             height: 250,
              //             child: Center(
              //               child: Text(
              //                 'Предложение о премиум подписке',
              //                 style: TextStyle(fontSize: 24.sp),
              //               ),
              //             ),
              //           ),
              //         );
              //       },
              //     );
              //   },
              // ),
              // const Divider(),
              // ListTile(
              //   title: Text(
              //     'Интегрировать рекламу',
              //     style: TextStyle(fontSize: 24.sp, color: Colors.black),
              //   ),
              //   onTap: () {
              //     SetPageWithoutBack(context, 'adIntegration');
              //   },
              // ),
              // const Divider(),
              // ListTile(
              //   title: Text(
              //     'Приобрести премиум',
              //     style: TextStyle(fontSize: 24.sp, color: Colors.black),
              //   ),
              //   onTap: () {
              //     showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return AlertDialog(
              //           content: SizedBox(
              //             width: 300,
              //             height: 250,
              //             child: Center(
              //               child: Text(
              //                 'Предложение о премиум подписке',
              //                 style: TextStyle(fontSize: 24.sp),
              //               ),
              //             ),
              //           ),
              //         );
              //       },
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ],
    ),
  );
}
