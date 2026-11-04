import 'package:flutter/material.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';

class AppDateText extends StatelessWidget {
  const AppDateText({super.key, required this.date, this.style});

  final DateTime? date;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(DateFormatter.formatGarageDate(date), style: style);
  }
}
