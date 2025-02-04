import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adminkigwater/domain/entities/admin.dart';

class AdminCard extends StatelessWidget {
  final Admin admin;
  final VoidCallback onEdit;

  const AdminCard({super.key, required this.admin, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoColumn('ФИО', admin.name),
            _buildInfoColumn('Логин', admin.login),
            _buildInfoColumn('Пароль', admin.password),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        SelectableText(
          value,
          style: TextStyle(
            fontSize: 18.sp,
          ),
        ),
      ],
    );
  }
}
