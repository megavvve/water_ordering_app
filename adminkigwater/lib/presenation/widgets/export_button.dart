import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExportButton extends StatelessWidget {
  final String buttonText;
  final Function onExport;

  const ExportButton({
    super.key,
    required this.buttonText,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth( // Минимальная ширина по контенту
      child: IntrinsicHeight( // Минимальная высота по контенту
        child: MaterialButton(
          color: const Color.fromARGB(255, 3, 102, 97),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.sp), // Закругление кнопки
          ),
          onPressed: () => onExport(),
          child: Padding(
            padding:  EdgeInsets.all(8.0.sp),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Минимальная ширина по содержимому
              children: [
                Text(
                  buttonText,
                  style: const TextStyle(color: Colors.white),
                ),
                 SizedBox(width: 5.w),
                const Icon(Icons.download, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
