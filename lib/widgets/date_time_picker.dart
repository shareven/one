import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    this.child,
    this.valueStyle,
    required this.labelText,
    required this.valueText,
    required this.onPressed,
  });

  final Widget? child;
  final String labelText;
  final String valueText;
  final TextStyle? valueStyle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(labelText: labelText),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              valueText,
              style: valueStyle,
            ),
            Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.white70)
          ],
        ),
      ),
    );
  }
}

class DateTimePicker extends StatelessWidget {
  const DateTimePicker(
      {super.key,
      required this.labelText,
      required this.selectedDate,
      required this.selectDate});

  final String labelText;
  final DateTime selectedDate;
  final ValueChanged<DateTime> selectDate;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2017, 1),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate) selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return _InputDropdown(
      onPressed: () => _selectDate(context),
      labelText: labelText,
      valueText: DateFormat("yyyy-MM-dd").format(selectedDate),
    );
  }
}
