import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatTimeOfDay(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String formatClock(DateTime? dt) {
  if (dt == null) return '--:--';
  return DateFormat('HH:mm').format(dt);
}

String formatDate(DateTime dt) => DateFormat('EEE, d MMM yyyy').format(dt);

String formatDateTime(DateTime dt) => DateFormat('d MMM, HH:mm').format(dt);

String formatShortDate(DateTime dt) => DateFormat('d MMM yyyy').format(dt);

/// Whole days from now until [target].
String daysUntil(DateTime target) {
  final now = DateTime.now();
  final diff = target.difference(now);
  final days = diff.inHours / 24;
  if (days < 1) return 'today';
  final rounded = days.round();
  return rounded == 1 ? 'in 1 day' : 'in $rounded days';
}

String signedPercent(double value) {
  final sign = value >= 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(0)}%';
}
