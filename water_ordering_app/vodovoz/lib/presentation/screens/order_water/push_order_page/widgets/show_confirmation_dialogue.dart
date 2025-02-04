import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(BuildContext context, String address) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Подтверждение адреса'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Вы выбрали адрес:'),
            Text(
              address,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Отмена
            },
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Подтвердить
            },
            child: const Text('Подтвердить'),
          ),
        ],
      );
    },
  );
}
