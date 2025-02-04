import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildNoConnectionOverlay(Widget child,BuildContext context) {
  return Stack(
    children: [
      child,
      Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20.sp),
            margin: EdgeInsets.symmetric(horizontal: 30.sp), 
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.sp), 
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.sp,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.signal_wifi_off, // WiFi off icon
                  color: Colors.red,
                  size: 50.sp, // Adjust size
                ),
                SizedBox(height: 10.sp), // Spacing between icon and text
                Text(
                  'Нет интернет-соединения',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5.sp), // Additional spacing
                Text(
                  'Пожалуйста, переподключитесь.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.sp), // Spacing before button
                
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
