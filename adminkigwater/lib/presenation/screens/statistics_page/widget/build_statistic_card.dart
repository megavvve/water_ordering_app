import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildStatisticsCard({
  required String title,
  required Map<String, int> stats,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.sp),
    child: Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.sp),
              ...stats.entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.sp),
                  child: Row(
                    children: [
                      Icon(_getIconForStat(entry.key), size: 20.sp),
                      SizedBox(width: 10.sp),
                      Text('${entry.key}: ${entry.value}',
                          style: TextStyle(fontSize: 16.sp,),),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

IconData _getIconForStat(String statName) {
  switch (statName) {
    case 'Принято заказов':
    case 'Активных заказов':
      return Icons.water_drop_outlined;
    case 'Исполнено заказов':
      return Icons.security_update_good;
    case 'Отменено заказов':
      return Icons.block;
    case 'Всего пользователей':
      return Icons.supervisor_account_outlined;
    case 'Водовозов':
      return Icons.delivery_dining;
    case 'Новых пользователей':
      return Icons.person_add;
    case 'Активных регионов':
      return Icons.location_on_outlined;
    default:
      return Icons.info_outline;
  }
}
