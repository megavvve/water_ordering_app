import 'package:adminkigwater/domain/entities/deliverer.dart';
import 'package:adminkigwater/domain/entities/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DelivererCard extends StatelessWidget {
  final int index; // Add index parameter
  final Deliverer deliverer;
  final UserModel user;
  final VoidCallback onReview;

  const DelivererCard({
    Key? key,
    required this.index,
    required this.deliverer,
    required this.user,
    required this.onReview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(3.sp),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(3.sp),
              child: OutlinedButton(
                onPressed: () {},
                child: Text('$index', // Display index
                    style: TextStyle(fontSize: 18.sp)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(3.sp),
              child: SizedBox(
                width: 230.w,
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text(user.name, style: TextStyle(fontSize: 18.sp)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(3.sp),
              child: SizedBox(
                width: 150.w,
                child: OutlinedButton(
                  onPressed: () {},
                  child:
                      Text(user.phoneNumber, style: TextStyle(fontSize: 18.sp)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(3.sp),
              child: OutlinedButton(
                onPressed: () {},
                child: Text(user.city, style: TextStyle(fontSize: 18.sp)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(3.sp),
              child: ElevatedButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.account_circle_outlined),
                label: Text('Рассмотреть', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
