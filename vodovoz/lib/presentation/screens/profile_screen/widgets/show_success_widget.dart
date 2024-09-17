import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.sp),
        ),
        title: const Text(
          'Успех!',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: const Text('Профиль успешно обновлен!',
            textAlign: TextAlign.center),
        actions: <Widget>[
          TextButton(
            child: const Text('ОК'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
