import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/utils/input_decorations.dart';

class SaveButtonSection extends StatelessWidget {
  final bool isFormFilled;
  final Future<void> Function() onSave;

  const SaveButtonSection({
    super.key,
    required this.isFormFilled,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return isFormFilled
        ? Padding(
            padding: EdgeInsets.all(5.w),
            child: SizedBox(
              height: 60.h,
              width: 300.w,
              child: FilledButton(
                onPressed: onSave,
                style: btnStl,
                child: Text(
                  'Сохранить',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
