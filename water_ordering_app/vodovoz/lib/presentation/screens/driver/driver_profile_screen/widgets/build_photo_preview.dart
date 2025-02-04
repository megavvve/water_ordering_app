import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildPhotoPreview(File? photo) {
  return photo != null
      ? Container(
          height: 200.h,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: FileImage(photo),
              fit: BoxFit.contain,
            ),
          ),
        )
      : SizedBox(
          height: 50.h,
          child: Icon(Icons.photo, size: 50.sp),
        );
}
