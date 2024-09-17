import 'package:flutter/material.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserListWidget extends StatelessWidget {
  final Future<List<UserModel>>? usersFuture;
  final void Function(UserModel) onEditUser;

  const UserListWidget({
    Key? key,
    required this.usersFuture,
    required this.onEditUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (usersFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<UserModel>>(
      future: usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Пользователи не найдены'));
        } else {
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              final user = users[index];
              //Color oneColor = Colors.white60;
              Color twoColor = Colors.white;
              // if (index % 2 == 0) {
              //   oneColor = Colors.white;
              //   twoColor = Colors.white60;
              // }
              return Card(
                color: twoColor,
                child: Center(
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(3.sp),
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.sp),
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Text(
                            user.name,
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.sp),
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Text(
                            user.phoneNumber,
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.sp),
                        child: OutlinedButton(
                          onPressed: () {},
                          child: Text(
                            user.city,
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.sp),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            onEditUser(user);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('редактировать'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
