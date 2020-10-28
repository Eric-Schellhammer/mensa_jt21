import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mensa_jt21/online/online_calendar.dart';
import 'package:mensa_jt21/tools/compare.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'converter.dart';

class CalendarService {
  static const String _CALENDAR_ENTRIES = "calendarEntries";
  static const String _CALENDAR_DATE = "calendarDate";

  SharedPreferences _prefs;
  List<CalendarEntry> _calendarEntries;
  DateTime _calendarDate;
  Function(List<CalendarEntry>) _listener;

  void initializeWithLocalFile() {
    loadDefaultCalendarFile();
    SharedPreferences.getInstance().then((prefs) => this._prefs = prefs).then((__) {
      final String dateString = _prefs.get(_CALENDAR_DATE);
      if (dateString != null) _setCalendarJson(dateString, _prefs.get(_CALENDAR_ENTRIES));
    });
  }

  void registerUpdateListener(Function(List<CalendarEntry>) listener) {
    this._listener = listener;
    if (_calendarEntries != null) _listener.call(_calendarEntries);
  }

  /// Check online if an update of the calendar is available, and return the result into the receiver
  void isUpdateAvailable(Function(bool) receiver) {
    GetIt.instance
        .get<OnlineCalendar>()
        .getCalendarDateJson()
        .then((remoteCalendarDateJson) => CalendarConverter().convertDate(remoteCalendarDateJson))
        .then((remoteCalendarDate) => _calendarDate.isBefore(remoteCalendarDate))
        .then((isAvailable) => receiver.call(isAvailable));
  }

  /// Check online if an update of the calendar is available and if so, load it
  void checkForUpdate() {
    final onlineCalendar = GetIt.instance.get<OnlineCalendar>();
    onlineCalendar.getCalendarDateJson().then((remoteCalendarDateJson) {
      final DateTime remoteCalendarDate = CalendarConverter().convertDate(remoteCalendarDateJson);
      if (_calendarDate.isBefore(remoteCalendarDate)) {
        onlineCalendar.getCalendarJson().then((calendarJson) => _setCalendarJson(remoteCalendarDateJson, calendarJson));
      }
    });
  }

  void loadDefaultCalendarFile() {
    final calendarDateJson = "{\"date\":\"2020-02-23 17:30:41\"}";
    rootBundle.loadString("resources/jt20.json").then((calendarJson) => _setCalendarJson(calendarDateJson, calendarJson));
  }

  void _setCalendarJson(String calendarDateJson, String calendarJson) {
    _prefs.setString(_CALENDAR_DATE, calendarDateJson);
    _prefs.setString(_CALENDAR_ENTRIES, calendarJson);
    final calendarConverter = CalendarConverter();
    _calendarDate = calendarConverter.convertDate(calendarDateJson);
    _calendarEntries = calendarConverter.convertEntries(calendarJson);
    _calendarEntries.sort();
    if (_listener != null) _listener.call(_calendarEntries);
  }
}

class CalendarEntry implements Comparable<CalendarEntry> {
  int eventGroupId;
  int eventId;
  String name;
  String kategorie;
  String dauer;
  DateTime start;
  String anbieter;
  String location;
  String strasse;
  String plz;
  String ortsname;
  String gebaeude;
  String raum;
  String lat;
  String lon;
  String abmarsch;
  String abgesagt;
  String wordpress;
  String eventtext;
  String bild;
  String bildtitel;
  String barrierefreiheit;
  String haltestelle;

  Map<String, dynamic> _values;

  CalendarEntry(Map<String, dynamic> json) {
    _values = json;
    eventGroupId = int.parse(_values["ID"]);
    eventId = int.parse(_values["t_ID"]);
    name = _values["name"];
    start = DateTime.parse(_values["start"]);
  }

  @override
  int compareTo(CalendarEntry other) {
    return CascadedComparator(this, other)
        .then((ce) => ce.start)
        .then((ce) => ce.name)
        .calculate();
  }
}
