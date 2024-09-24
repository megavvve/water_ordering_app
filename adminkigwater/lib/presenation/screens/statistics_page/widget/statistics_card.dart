import 'package:adminkigwater/presenation/screens/statistics_page/widget/build_statistic_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final Map<String, int> stats;
  final VoidCallback onTap;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450.h,
      width: 600.w,
      child: buildStatisticsCard(
        title: title,
        stats: stats,
        onTap: onTap,
      ),
    );
  }
}
