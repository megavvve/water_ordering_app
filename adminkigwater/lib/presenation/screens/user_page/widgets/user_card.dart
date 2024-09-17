import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEdit;

  const UserCard({
    Key? key,
    required this.user,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Expanded(child: Text(user.city, style: TextStyle(fontSize: 18.sp))),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
