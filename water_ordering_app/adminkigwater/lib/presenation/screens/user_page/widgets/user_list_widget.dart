import 'package:adminkigwater/domain/entities/geolocation.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserListWidget extends StatelessWidget {
  final List<UserModel> users;
  final List<Geolocation?> geolocations;
  final void Function(UserModel) onEditUser;

  const UserListWidget({
    super.key,
    required this.users,
    required this.geolocations,
    required this.onEditUser,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('Пользователи не найдены'));
    }

    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          UserModel user = users[index];
          Geolocation? geolocation;
        try {
          geolocation = geolocations.firstWhere(
            (geo) => geo?.geolocationId == user.userId,
          );
        } catch (e) {
          geolocation = null;
        }


          // Default values for empty fields
          String userName = user.name.isNotEmpty ? user.name : "имя не указано";
          String userPhone = user.phoneNumber.isNotEmpty
              ? user.phoneNumber
              : "телефон не указан";
          String userAddress =
              geolocation != null && geolocation.address.isNotEmpty
                  ? geolocation.address
                  : "Город не указан";

          return Card(
            color: Colors.white,
            child: Center(
              child: Row(
                children: [
                  // Using Expanded for even distribution
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(3.sp),
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(fontSize: 18.sp),
                          textAlign: TextAlign.center,
                        ),
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
                          userName,
                          style: TextStyle(fontSize: 18.sp),
                          textAlign: TextAlign.center,
                        ),
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
                          userPhone,
                          style: TextStyle(fontSize: 18.sp),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.all(3.sp),
                      child: OutlinedButton(
                        onPressed: () {},
                        child: Text(
                          userAddress,
                          style: TextStyle(fontSize: 18.sp),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(3.sp),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          onEditUser(user);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('редактировать'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
