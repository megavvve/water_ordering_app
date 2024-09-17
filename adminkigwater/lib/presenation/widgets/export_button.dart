import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExportButton extends StatelessWidget {
  final String buttonText;
  final Function onExport;

  const ExportButton({
    Key? key,
    required this.buttonText,
    required this.onExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480.w,
      child: MaterialButton(
        color: const Color.fromARGB(255, 3, 102, 97),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp), // Закругление кнопки
        ),
        onPressed: () => onExport(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                buttonText,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.download, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
