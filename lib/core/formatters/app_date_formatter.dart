import 'package:flutter/material.dart';

String formatAppDateTime(BuildContext context, DateTime? value) {
  if (value == null) {
    return '-';
  }

  final local = value.toLocal();
  final material = MaterialLocalizations.of(context);
  final date = material.formatShortDate(local);
  final time = TimeOfDay.fromDateTime(local).format(context);
  return '$date, $time';
}
