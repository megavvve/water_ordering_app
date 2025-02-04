import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserListHeader extends StatelessWidget {
  const UserListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(3.sp),
              child: OutlinedButton(
                onPressed: () {},
                child: Text(
                  '№',
                  style: TextStyle(
                    fontSize: 18.sp,
                  ),
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
                  'ФИО',
                  style: TextStyle(fontSize: 18.sp),
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
                  'Телефон',
                  style: TextStyle(fontSize: 18.sp),
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
                  'Регион',
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
