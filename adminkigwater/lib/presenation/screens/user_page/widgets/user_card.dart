import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/repositories/geolocation_repository.dart';
import 'package:adminkigwater/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;

  const UserCard({
    super.key,
    required this.user,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Geolocation?>(
      future: getIt<GeolocationRepository>().getGeolocation(user.geolocationId??user.userId),
      builder: (context, snapshot) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(user.name, style: TextStyle(fontSize: 18.sp))),
                Expanded(
                    child:
                        Text(user.phoneNumber, style: TextStyle(fontSize: 18.sp))),
                Expanded(child: Text(snapshot.data!= null?snapshot.data!.address:'Город не известен ', style: TextStyle(fontSize: 18.sp))),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
