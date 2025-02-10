import 'package:flutter/material.dart';

enum FeedbackType {
  complaint('Жалоба', Icons.warning_amber),
  suggestion('Предложение', Icons.lightbulb_outline),
  review('Отзыв', Icons.thumb_up_outlined);

  const FeedbackType(this.label, this.icon);
  final String label;
  final IconData icon;
}