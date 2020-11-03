import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mensa_jt21/calendar/calendar_entry.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_settings_service.dart';
import 'package:mensa_jt21/calendar/favorites_service.dart';
import 'package:mensa_jt21/initialize/debug_settings.dart';
import 'package:mensa_jt21/online/online_service.dart';
import 'package:mensa_jt21/screens/debug_screen.dart';
import 'package:mensa_jt21/screens/settings_screen.dart';

class CalendarListScreen extends StatefulWidget {
  static const routeName = "/main_screen";

  @override
  createState() => CalendarListScreenState();
}

class CalendarListScreenState extends State<CalendarListScreen> {
  static const MENU_CHECK = 'Prüfen';
  static const MENU_UPDATE = 'Aktualisieren';
  static const MENU_SETTINGS = 'Einstellungen';
  static const MENU_DEBUG = 'Debug';

  List<CalendarEntry> _allEventsByDate = List();
  List<Widget> _displayedWidgets = List();
  CalendarSorting _sorting;
  CalendarDateFormat _dateFormat;
  OnlineMode _onlineMode;
  bool _updateAvailable = false;

  @override
  void initState() {
    super.initState();
    final onlineService = GetIt.instance.get<OnlineService>();
    onlineService.registerModeListener((onlineMode) => _updateOnlineMode(onlineMode));
    onlineService.init();
    final calendarSettingsService = GetIt.instance.get<CalendarSettingsService>();
    calendarSettingsService.registerListener((sorting, dateFormat) => _updateCalendarSettings(sorting, dateFormat));
    calendarSettingsService.initialize();
    final calendarService = GetIt.instance.get<CalendarService>();
    calendarService.registerUpdateListener((calendar) => _updateCalendarEntries(calendar));
    calendarService.initializeWithLocalFile();
    final favoritesService = GetIt.instance.get<FavoritesService>();
    favoritesService.registerUpdateListener(() => _refreshList());
    favoritesService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensa JT21"),
        leading: new Container(),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleMenuClick,
            itemBuilder: (BuildContext context) {
              return _getMenuEntries();
            },
          ),
        ],
      ),
      body: _buildList(),
    );
  }

  List<PopupMenuItem<String>> _getMenuEntries() {
    List<PopupMenuItem<String>> entries = List();
    if (_onlineMode == OnlineMode.MANUAL || _onlineMode == OnlineMode.ON_DEMAND) {
      entries.add(PopupMenuItem(
        value: MENU_CHECK,
        enabled: !_updateAvailable,
        child: Text(MENU_CHECK),
      ));
    }
    if (_onlineMode == OnlineMode.MANUAL || _onlineMode == OnlineMode.AUTOMATIC) {
      entries.add(PopupMenuItem(
        value: MENU_UPDATE,
        enabled: _updateAvailable,
        child: Text(
          MENU_UPDATE,
          style: _updateAvailable ? TextStyle(color: Colors.red) : null,
        ),
      ));
    }
    entries.add(PopupMenuItem(
      value: MENU_SETTINGS,
      child: Text(MENU_SETTINGS),
    ));
    if (GetIt.instance.get<DebugSettings>().activateDebugMode) {
      entries.add(PopupMenuItem(
        value: MENU_DEBUG,
        child: Text(MENU_DEBUG),
      ));
    }
    return entries;
  }

  void _handleMenuClick(String value) {
    switch (value) {
      case MENU_CHECK:
        _handleMenuCheckForUpdates();
        break;
      case MENU_UPDATE:
        GetIt.instance.get<CalendarService>().checkForUpdate();
        setState(() {
          _updateAvailable = false;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Die Aktualisierung wird heruntergeladen"),
                actions: [
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
        break;
      case MENU_SETTINGS:
        Navigator.pushNamed(context, SettingsScreen.routeName);
        break;
      case MENU_DEBUG:
        Navigator.pushNamed(context, DebugScreen.routeName);
        break;
    }
  }

  void _handleMenuCheckForUpdates() {
    GetIt.instance.get<CalendarService>().isUpdateAvailable((isAvailable) {
      if (isAvailable != _updateAvailable) {
        if (_onlineMode == OnlineMode.MANUAL) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text("Eine Aktualisierung ist verfügbar."),
                  actions: [
                    TextButton(
                      child: Text("Jetzt aktualisieren"),
                      onPressed: () {
                        GetIt.instance.get<CalendarService>().checkForUpdate();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text("Später manuell aktualisieren"),
                      onPressed: () {
                        setState(() {
                          _updateAvailable = true;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        } else {
          GetIt.instance.get<CalendarService>().checkForUpdate();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text("Eine Aktualisierung wird heruntergeladen"),
                  actions: [
                    TextButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("Keine Aktualisierung verfügbar"),
                actions: [
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      }
    });
  }

  Widget _buildList() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) => _displayedWidgets[index],
      itemCount: _displayedWidgets.length,
    );
  }

  void _updateCalendarEntries(List<CalendarEntry> calendar) {
    if (mounted)
      setState(() {
        _allEventsByDate = calendar;
        _updateAvailable = false;
        _transferEventsToWidgets();
      });
    else {
      _allEventsByDate = calendar;
      _updateAvailable = false;
      _transferEventsToWidgets();
    }
  }

  void _updateCalendarSettings(CalendarSorting sorting, CalendarDateFormat dateFormat) {
    if (mounted)
      setState(() {
        _sorting = sorting;
        _dateFormat = dateFormat;
        _transferEventsToWidgets();
      });
    else {
      _sorting = sorting;
      _dateFormat = dateFormat;
      _transferEventsToWidgets();
    }
  }

  void _refreshList() {
    if (mounted)
      setState(() {
        _transferEventsToWidgets();
      });
    else
      _transferEventsToWidgets();
  }

  void _transferEventsToWidgets() {
    final favoritesService = GetIt.instance.get<FavoritesService>();
    _displayedWidgets = List();
    switch (_sorting) {
      case CalendarSorting.ALL_BY_DATE:
        int lastDay;
        _allEventsByDate.forEach((element) {
          // TODO how to restrict DateTime to Date?
          final int currentDay = element.start.year * 10000 + element.start.month * 100 + element.start.day;
          if (lastDay == null || lastDay != currentDay) {
            _displayedWidgets.add(Padding(
              padding: EdgeInsets.fromLTRB(32, 32, 16, 16),
              child: Text(
                DateFormat(_dateFormat.subtitleFormat).format(element.start),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ));
            lastDay = currentDay;
          }
          _displayedWidgets.add(new CalendarListEntryWidget(element, _dateFormat, favoritesService.isFavorite(element.eventId)));
        });
        break;
      case CalendarSorting.GROUP_BY_DATE:
      case CalendarSorting.GROUP_BY_TYPE:
        _displayedWidgets.add(Text("NO VALID SORTING"));
        break;
    }
  }

  void _updateOnlineMode(OnlineMode onlineMode) {
    if (mounted)
      setState(() {
        _onlineMode = onlineMode;
      });
    else {
      _onlineMode = onlineMode;
    }
  }
}
