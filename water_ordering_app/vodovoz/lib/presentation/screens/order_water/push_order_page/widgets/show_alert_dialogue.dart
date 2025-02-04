import 'package:flutter/material.dart';

void showPhoneAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Телефон не указан'),
        content: const Text(
          'Для оформления заказа необходимо указать номер телефона. Пожалуйста, обновите номер телефона в профиле.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
