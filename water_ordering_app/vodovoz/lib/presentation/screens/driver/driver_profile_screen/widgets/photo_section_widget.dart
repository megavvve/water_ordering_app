import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/presentation/screens/driver/driver_profile_screen/widgets/build_photo_preview.dart';

class PhotoSectionWidget extends StatelessWidget {
  final String title;
  final File? photo;
  final VoidCallback onPickImage;

  const PhotoSectionWidget({
    super.key,
    required this.title,
    this.photo,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.w),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 19.sp, color: Colors.white),
          ),
          Padding(
            padding: EdgeInsets.all(5.w),
            child: buildPhotoPreview(photo),
          ),
          TextButton(
            onPressed: onPickImage,
            child: const Text(
              'выбрать фото',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
