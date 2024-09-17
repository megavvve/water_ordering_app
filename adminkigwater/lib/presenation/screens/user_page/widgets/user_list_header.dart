import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserListHeader extends StatelessWidget {
  const UserListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Padding(
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
          Padding(
            padding: EdgeInsets.all(3.sp),
            child: SizedBox(
              width: 150.w,
              child: OutlinedButton(
                onPressed: () {},
                child: Text('ФИО', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.sp),
            child: SizedBox(
              width: 150.w,
              child: OutlinedButton(
                onPressed: () {},
                child: Text('Телефон', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.sp),
            child: OutlinedButton(
              onPressed: () {},
              child: Text('Регион', style: TextStyle(fontSize: 18.sp)),
            ),
          ),
        ],
      ),
    );
  }
}
