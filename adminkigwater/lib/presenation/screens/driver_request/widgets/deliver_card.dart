import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DelivererCard extends StatelessWidget {
  final int index;
  final Deliverer deliverer;
  final UserModel user;
  final VoidCallback onReview;

  const DelivererCard({
    super.key,
    required this.index,
    required this.deliverer,
    required this.user,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Geolocation?>(
      future: getIt<GeolocationRepository>().getGeolocation(user.userId),
      builder: (context, snapshot) {
        return Card(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(3.sp),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(3.sp),
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text('$index', style: TextStyle(fontSize: 18.sp)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.all(3.sp),
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text(user.name, style: TextStyle(fontSize: 18.sp)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(3.sp),
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text(user.phoneNumber,
                          style: TextStyle(fontSize: 18.sp)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.all(3.sp),
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text(
                        snapshot.data != null
                            ? snapshot.data!.address
                            : 'Адрес не известен',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(3.sp),
                    child: ElevatedButton.icon(
                      onPressed: onReview,
                      icon: const Icon(Icons.account_circle_outlined),
                      label: Text('Рассмотреть',
                          style: TextStyle(fontSize: 18.sp)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
