import 'package:flutter/material.dart';

import 'package:ebook_application/size_config.dart';

class DatePickerField extends StatefulWidget {
  const DatePickerField({
    super.key,
    required this.getDateOfBirth,
  });

  final Function(DateTime chosenDateOfBirth) getDateOfBirth;

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? dateOfBirth;

  String getFormattedDate(DateTime date) {
    String day = date.day.toString();
    String month = date.month.toString();
    String year = date.year.toString();
    if (date.day < 10) {
      day = '0$day';
    }
    if (date.month < 10) {
      month = '0$month';
    }
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Container(
          width: double.infinity,
          height: getProportionateScreenHeight(55),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 245, 245, 245),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            dateOfBirth == null
                ? 'No date chosen'
                : getFormattedDate(dateOfBirth!),
            style: TextStyle(
              fontSize: getProportionateScreenWidth(15.5),
              color: const Color.fromARGB(240, 98, 98, 98),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            final chosenDateOfBirth = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.fromMicrosecondsSinceEpoch(1),
              lastDate: DateTime.now(),
            );

            setState(() {
              dateOfBirth = chosenDateOfBirth;
            });

            widget.getDateOfBirth(chosenDateOfBirth!);
          },
          icon: const Icon(
            Icons.date_range,
            color: Colors.black,
          ),
          label: const Text(''),
        ),
      ],
    );
  }
}
