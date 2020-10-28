import 'dart:convert';

import 'package:mensa_jt21/calendar/calendar_service.dart';

class CalendarConverter {
  DateTime convertDate(String jsonString) {
    return DateTime.parse(JsonDecoder().convert(jsonString)["date"]);
  }

  List<CalendarEntry> convertEntries(String jsonString) {
    final List<CalendarEntry> entries = List();
    final jsonEntries = JsonDecoder().convert(jsonString);
    if (jsonEntries != null) {
      jsonEntries.forEach((element) {
        entries.add(CalendarEntry(element));
      });
    }
    return entries;
  }
}
