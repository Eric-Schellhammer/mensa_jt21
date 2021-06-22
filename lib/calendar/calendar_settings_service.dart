import 'package:shared_preferences/shared_preferences.dart';

enum CalendarSorting { EMPTY, ALL_BY_DATE, GROUP_BY_DATE, GROUP_BY_TYPE }

enum CalendarDateFormat { DATE, WEEKDAY, WEEKDAY_AND_DATE }

extension CalendarDateFormatStrings on CalendarDateFormat {
  String get subtitleFormat {
    switch (this) {
      case CalendarDateFormat.DATE:
        return "dd.MM.yyyy";
      case CalendarDateFormat.WEEKDAY:
        return "EEEE";
      case CalendarDateFormat.WEEKDAY_AND_DATE:
      default:
        return "EEEE, dd.MM.yyyy";
    }
  }

  String get startTimeFormat {
    switch (this) {
      case CalendarDateFormat.DATE:
        return "dd.MM.yy, HH:mm 'Uhr'";
      case CalendarDateFormat.WEEKDAY:
        return "EEEE, HH:mm 'Uhr'";
      case CalendarDateFormat.WEEKDAY_AND_DATE:
      default:
        return "EEEE, dd.MM.yy, HH:mm 'Uhr'";
    }
  }
}

class CalendarSettingsService {
  static const String _CALENDAR_SORTING = "calendarSorting";
  static const String _CALENDAR_DATE_FORMAT = "calendarDateFormat";
  static const String _CALENDAR_INCLUDE_RESTRICTED = "calendarIncludeRestricted";

  final List<Function(CalendarSorting, CalendarDateFormat, bool)> _listeners = List.empty(growable: true);
  late final Future<SharedPreferences> _prefs;
  CalendarSorting _sorting = CalendarSorting.GROUP_BY_DATE;
  CalendarDateFormat _dateFormat = CalendarDateFormat.WEEKDAY_AND_DATE;
  bool _includeRestricted = true;

  void initialize() {
    _prefs = SharedPreferences.getInstance();
    _prefs.then((prefs) {
      final String? sortingString = prefs.getString(_CALENDAR_SORTING);
      _sorting = CalendarSorting.values.firstWhere((sorting) => sorting.toString() == sortingString, orElse: () => CalendarSorting.GROUP_BY_DATE);
      final String? dateFormatString = prefs.getString(_CALENDAR_DATE_FORMAT);
      _dateFormat = CalendarDateFormat.values.firstWhere((format) => format.toString() == dateFormatString, orElse: () => CalendarDateFormat.WEEKDAY_AND_DATE);
      _includeRestricted = prefs.containsKey(_CALENDAR_INCLUDE_RESTRICTED) ? (prefs.getBool(_CALENDAR_INCLUDE_RESTRICTED) ?? false) : true;
      _callListeners();
    });
  }

  void resetToInitial() {
    _prefs.then((prefs) {
      prefs.remove(_CALENDAR_SORTING);
      prefs.remove(_CALENDAR_DATE_FORMAT);
      prefs.remove(_CALENDAR_INCLUDE_RESTRICTED);
    });
    _sorting = CalendarSorting.GROUP_BY_DATE;
    _dateFormat = CalendarDateFormat.WEEKDAY_AND_DATE;
    _includeRestricted = true;
    _callListeners();
  }

  void registerListener(Function(CalendarSorting, CalendarDateFormat, bool) listener) {
    _listeners.add(listener);
    listener.call(_sorting, _dateFormat, _includeRestricted);
  }

  void setSorting(CalendarSorting sorting) {
    _sorting = sorting;
    _prefs.then((prefs) => prefs.setString(_CALENDAR_SORTING, sorting.toString()));
    _callListeners();
  }

  void setCalendarDateFormat(CalendarDateFormat format) {
    _dateFormat = format;
    _prefs.then((prefs) => prefs.setString(_CALENDAR_DATE_FORMAT, format.toString()));
    _callListeners();
  }

  void setIncludeRestricted(bool include) {
    _includeRestricted = include;
    _prefs.then((prefs) => prefs.setBool(_CALENDAR_INCLUDE_RESTRICTED, _includeRestricted));
    _callListeners();
  }

  /// return the date format, but do not listen to changes of it
  CalendarDateFormat getDateFormatOnce() {
    return _dateFormat;
  }

  void _callListeners() {
    _listeners.forEach((listener) => listener.call(_sorting, _dateFormat, _includeRestricted));
  }
}
