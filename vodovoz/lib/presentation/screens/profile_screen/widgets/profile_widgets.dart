import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vodovoz/utils/input_decorations.dart';

class ProfileAvatar extends StatelessWidget {
  final File? image;
  final VoidCallback onPressed;
  final bool isLoadingAvatar;

  const ProfileAvatar(
      {Key? key,
      required this.image,
      required this.onPressed,
      required this.isLoadingAvatar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return image == null
        ? Icon(
            Icons.account_circle_rounded,
            size: 135.sp,
          )
        : CircleAvatar(
            radius: 70.sp,
            backgroundImage: FileImage(image!),
          );
  }
}

class SelectPhotoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SelectPhotoButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: TextButton(
        onPressed: onPressed,
        child: const Text(
          'выбрать фото',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final ValueChanged<String>? onChanged; // Add this line

  const ProfileTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.enabled = true,
    this.onChanged, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: SizedBox(
        height: 60.h,
        width: 300.w,
        child: TextField(
          controller: controller,
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.deepOrangeAccent : Colors.grey[300],
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(20.sp),
            ),
            labelText: labelText,
            labelStyle: const TextStyle(color: Colors.white),
            enabled: enabled,
          ),
          onChanged: onChanged, // Use the onChanged callback
        ),
      ),
    );
  }
}

class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final ValueChanged<String>? onChanged; // Add this line

  const PhoneTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.enabled = true,
    this.onChanged, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: SizedBox(
        height: 60.h,
        width: 300.w,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.deepOrangeAccent : Colors.grey[300],
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(20.sp),
            ),
            labelText: labelText,
            labelStyle: const TextStyle(color: Colors.white),
            enabled: enabled,
          ),
          onChanged: onChanged, // Use the onChanged callback
        ),
      ),
    );
  }
}

class CitySelectionField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final VoidCallback onTap;

  const CitySelectionField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.enabled = true,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: SizedBox(
        width: 300.w,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.none,
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.deepOrangeAccent : Colors.grey[300],
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(20.sp),
            ),
            labelText: labelText,
            labelStyle: const TextStyle(color: Colors.white),
            enabled: enabled,
          ),
          onTap: onTap,
          maxLines: null,
          showCursor: false,
        ),
      ),
    );
  }
}

class EditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String phone;

  const EditButton({Key? key, required this.onPressed, required this.phone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: SizedBox(
        height: 60.h,
        width: 300.w,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.edit),
          label: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 5.h,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Номер телефона",
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
              SizedBox(
                height: 5.h,
              ),
              Text(
                phone,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          style: btnStl,
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: SizedBox(
        height: 60.h,
        width: 300.w,
        child: FilledButton(
          onPressed: onPressed,
          style: btnStl,
          child: const Text('Сохранить'),
        ),
      ),
    );
  }
}
