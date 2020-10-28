import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';

class CalendarListEntryWidget extends StatelessWidget {
  final CalendarEntry calendarEntry;

  const CalendarListEntryWidget(this.calendarEntry);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(calendarEntry.eventId.toString() + " (" + calendarEntry.eventGroupId.toString() + ")"),
          Text(
            calendarEntry.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(DateFormat("dd.MM.yy, HH:mm").format(calendarEntry.start) + " Uhr"),
        ],
      ),
    );
  }
}
