import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchWidget extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const SearchWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 200.w, vertical: 15.h),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded),
          hintText: 'Поиск...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.sp),
          ),
        ),
        onChanged: onSearch,
      ),
    );
  }
}
