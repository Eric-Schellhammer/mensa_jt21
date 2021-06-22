import 'dart:convert';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:mensa_jt21/online/online_calendar.dart';
import 'package:mensa_jt21/tools/compare.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarService {
  static const String _CALENDAR_ENTRIES = "calendarEntries";
  static const String _CALENDAR_DATE = "calendarDate";

  late final Future<SharedPreferences> _prefs;
  List<CalendarEntry>? _calendarEntries;
  late DateTime _calendarDate;
  Function(bool)? _updateAvailableListener;
  Function(List<CalendarEntry>)? _calendarListener;

  void initializeWithLocalFile() {
    loadDefaultCalendarFile();
    _prefs = SharedPreferences.getInstance();
    _prefs.then((prefs) {
      final String? dateString = prefs.containsKey(_CALENDAR_DATE) ? prefs.getString(_CALENDAR_DATE) : null;
      if (dateString != null) _setCalendarJson(dateString, prefs.getString(_CALENDAR_ENTRIES)!);
    });
  }

  void registerUpdateAvailableListener(Function(bool) listener) {
    _updateAvailableListener = listener;
    // do not call listener immediately
  }

  void registerCalendarListener(Function(List<CalendarEntry>) listener) {
    _calendarListener = listener;
    if (_calendarEntries != null) _calendarListener!.call(_calendarEntries!);
  }

  /// Check online if an update of the calendar is available, and return the result into the receiver
  void isUpdateAvailable(Function(bool) receiver) {
    GetIt.instance
        .get<OnlineCalendar>()
        .getCalendarDateJson()
        .then((remoteCalendarDateJson) => _convertDate(remoteCalendarDateJson))
        .then((remoteCalendarDate) => _calendarDate.isBefore(remoteCalendarDate))
        .then((isAvailable) => receiver.call(isAvailable));
  }

  void checkIfUpdateAvailable() {
    if (_updateAvailableListener != null) isUpdateAvailable(_updateAvailableListener!);
  }

  /// Check online if an update of the calendar is available and if so, load it
  void checkForUpdateAndLoad() {
    final onlineCalendar = GetIt.instance.get<OnlineCalendar>();
    onlineCalendar.getCalendarDateJson().then((remoteCalendarDateJson) {
      final DateTime remoteCalendarDate = _convertDate(remoteCalendarDateJson);
      if (_calendarDate.isBefore(remoteCalendarDate)) {
        onlineCalendar.getCalendarJson().then((calendarJson) => _setCalendarJson(remoteCalendarDateJson, calendarJson));
      }
    });
  }

  void loadDefaultCalendarFile() {
    final calendarDateJson = "{\"date\":\"2020-02-23 17:30:41\"}";
    rootBundle.loadString("resources/jt20.json").then((calendarJson) => _setCalendarJson(calendarDateJson, calendarJson));
  }

  Set<String> getBarrierefreiEntries() {
    return _calendarEntries!.map((entry) => entry.barrierefreiheit).toSet();
  }

  void _setCalendarJson(String calendarDateJson, String calendarJson) {
    _prefs.then((prefs) {
      prefs.setString(_CALENDAR_DATE, calendarDateJson);
      prefs.setString(_CALENDAR_ENTRIES, calendarJson);
    });
    _calendarDate = _convertDate(calendarDateJson);
    _calendarEntries = _convertEntries(calendarJson);
    _calendarEntries!.sort();
    _callListener();
  }

  void _callListener() {
    if (_calendarListener != null) _calendarListener!.call(_calendarEntries!);
  }

  DateTime _convertDate(String jsonString) {
    return DateTime.parse(JsonDecoder().convert(jsonString)["date"]);
  }

  List<CalendarEntry> _convertEntries(String jsonString) {
    final List<CalendarEntry> entries = List.empty(growable: true);
    final jsonEntries = JsonDecoder().convert(jsonString);
    if (jsonEntries != null) {
      jsonEntries.forEach((jsonElement) {
        entries.add(CalendarEntry.fromJson(jsonElement));
      });
    }
    return entries;
  }

  Future<String?> getRawCalendarJson() {
    return _prefs.then((prefs) => prefs.getString(_CALENDAR_ENTRIES));
  }
}

class CalendarEntry implements Comparable<CalendarEntry> {
  final int eventGroupId;
  final int eventId;
  final String name;
  final String kategorie;
  final int dauer;
  final DateTime start;
  final String anbieter;
  final String location;
  final String strasse;
  final String plz;
  final String ortsname;
  final String? gebaeude;
  final String? raum;
  final String? lat;
  final String? lon;
  final DateTime? abmarsch;
  final bool abgesagt;
  final String? wordpress;
  final String eventtext;
  final String? bild;
  final String? bildtitel;
  final String barrierefreiheit;
  String? haltestelle;

  CalendarEntry(
      {required this.eventGroupId,
      required this.eventId,
      required this.name,
      required this.kategorie,
      required this.dauer,
      required this.start,
      required this.anbieter,
      required this.location,
      required this.strasse,
      required this.plz,
      required this.ortsname,
      this.gebaeude,
      this.raum,
      this.lat,
      this.lon,
      this.abmarsch,
      required this.abgesagt,
      this.wordpress,
      required this.eventtext,
      this.bild,
      this.bildtitel,
      required this.barrierefreiheit,
      this.haltestelle});

  factory CalendarEntry.fromJson(Map<String, dynamic> json) {
    return CalendarEntry(
        eventGroupId: int.parse(json["ID"]),
        eventId: int.parse(json["t_ID"]),
        name: json["name"],
        kategorie: json["kategorie"],
        dauer: int.parse(json["dauer"]),
        start: DateTime.parse(json["start"]),
        anbieter: json["anbieter"],
        location: json["location"],
        strasse: json["strasse"],
        plz: json["plz"],
        ortsname: json["ortsname"],
        gebaeude: json["gebaeude"],
        raum: json["raum"],
        lat: json["lat"],
        lon: json["lon"],
        abmarsch: parseAbmarsch(json["abmarsch"]),
        abgesagt: json["abgesagt"] != "0",
        wordpress: json["wordpress"],
        eventtext: json["eventtext"],
        bild: json["bild"],
        bildtitel: json["bildtitel"],
        barrierefreiheit: json["barrierefreiheit"],
        haltestelle: json["haltestelle"]);
  }

  bool get takesPlace {
    return !abgesagt;
  }

  @override
  int compareTo(CalendarEntry other) {
    return CascadedComparator(this, other).then((ce) => ce.start).then((ce) => ce.name).calculate();
  }

  static DateTime? parseAbmarsch(String? abmarsch) {
    if (abmarsch == null || abmarsch.isEmpty || abmarsch == "00:00:00")
      return null;
    else
      return DateTime.parse("2020-01-01 " + abmarsch);
  }
}
