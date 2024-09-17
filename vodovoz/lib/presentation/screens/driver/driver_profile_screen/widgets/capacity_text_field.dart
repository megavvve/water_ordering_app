import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/utils/input_decorations.dart';

class CapacityTextField extends StatelessWidget {
  final TextEditingController capacityController;
  final void Function(String value) onChanged;

  const CapacityTextField({
    super.key,
    required this.capacityController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(5.w),
          child: SizedBox(
            //height: 20.h,
            width: 300.w,
            child: Text(
              'Емкость',
              style: TextStyle(fontSize: 19.sp, color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(5.w),
          child: SizedBox(
            height: 60.h,
            width: 300.w,
            child: TextField(
              controller: capacityController,
              style: TextStyle(fontSize: 24.sp, color: Colors.grey),
              decoration: inptDec1NoLabel(true),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
