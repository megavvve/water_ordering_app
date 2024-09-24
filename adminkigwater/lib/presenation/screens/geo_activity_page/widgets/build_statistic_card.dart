// Виджет для карточек статистики
  import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildStatisticsCard(String title, String count) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.sp),
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6.sp,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Text(
              count,
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }