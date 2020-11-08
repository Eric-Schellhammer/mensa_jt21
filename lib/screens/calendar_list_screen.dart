import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mensa_jt21/calendar/calendar_entry.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_settings_service.dart';
import 'package:mensa_jt21/calendar/favorite_button.dart';
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
  static const MENU_ABOUT = 'Über die App';

  List<CalendarEntry> _allEventsByDate = List();
  List<Widget> _displayedWidgets = List();
  CalendarSorting _sorting = CalendarSorting.EMPTY;
  DateTime _selectedDate;
  bool _onlyFavorites = false;
  CalendarDateFormat _dateFormat;
  OnlineMode _onlineMode;
  bool _updateAvailable = false;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = "de_DE";
    initializeDateFormatting();
    final onlineService = GetIt.instance.get<OnlineService>();
    onlineService.registerModeListener((onlineMode) => _updateOnlineMode(onlineMode));
    onlineService.init();
    final calendarSettingsService = GetIt.instance.get<CalendarSettingsService>();
    calendarSettingsService.registerListener((sorting, dateFormat) => _updateCalendarSettings(sorting, dateFormat));
    calendarSettingsService.initialize();
    final calendarService = GetIt.instance.get<CalendarService>();
    calendarService.registerUpdateAvailableListener((isAvailable) => _updateUpdateAvailable(isAvailable));
    calendarService.registerCalendarListener((calendar) => _updateCalendarEntries(calendar));
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
        //leading: new Container(),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _handleMenuClick,
            itemBuilder: (BuildContext context) {
              return _getMenuEntries();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
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
    if (GetIt.instance.get<DebugSettings>().isDebugModeActive()) {
      entries.add(PopupMenuItem(
        value: MENU_DEBUG,
        child: Text(MENU_DEBUG),
      ));
    }
    entries.add(PopupMenuItem(
      value: MENU_ABOUT,
      child: Text(MENU_ABOUT),
    ));
    return entries;
  }

  void _handleMenuClick(String value) {
    switch (value) {
      case MENU_CHECK:
        _handleMenuCheckForUpdates();
        break;
      case MENU_UPDATE:
        GetIt.instance.get<CalendarService>().checkForUpdateAndLoad();
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
      case MENU_ABOUT:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Über die App"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mensa Jahrestreffen \"21",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Version 0.3, 04.11.2020"),
                    Text(
                      "Entwickler:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      child: Column(
                        children: [
                          Text("Dr. Eric Schellhammer"),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    onLongPress: DebugSettings.debugModeAvailable
                        ? () {
                            setState(() {
                              GetIt.instance.get<DebugSettings>().activateDebugMode = true;
                              _transferEventsToWidgets();
                              Navigator.of(context).pop();
                            });
                          }
                        : null,
                  )
                ],
              );
            });
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
                        GetIt.instance.get<CalendarService>().checkForUpdateAndLoad();
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
          GetIt.instance.get<CalendarService>().checkForUpdateAndLoad();
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

  Drawer _buildDrawer() {
    final List<Widget> drawerEntries = List();
    drawerEntries.add(
      DrawerHeader(
        child: Text(
          'Navigation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        decoration: BoxDecoration(
          color: Colors.amberAccent,
        ),
      ),
    );
    switch (_sorting) {
      case CalendarSorting.EMPTY:
      case CalendarSorting.ALL_BY_DATE:
      case CalendarSorting.GROUP_BY_TYPE:
        drawerEntries.add(
          ListTile(
            title: Text('Veranstaltungskalender'),
            onTap: () {
              _updateStateAndRefreshList(() {
                _onlyFavorites = false;
              });
              Navigator.pop(context);
            },
          ),
        );
        break;
      case CalendarSorting.GROUP_BY_DATE:
        drawerEntries.add(
          ListTile(
            title: Text(
              'Veranstaltungskalender',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: null,
          ),
        );
        final List<DateTime> allDates = _allEventsByDate.map((eventEntry) => _getDate(eventEntry.start)).toSet().toList();
        allDates.sort();
        allDates.forEach((date) {
          drawerEntries.add(
            Padding(
                padding: EdgeInsets.fromLTRB(32, 0, 0, 0),
                child: ListTile(
                    title: Text(DateFormat(_dateFormat.subtitleFormat).format(date)),
                    onTap: () {
                      _updateStateAndRefreshList(() {
                        _selectedDate = date;
                        _onlyFavorites = false;
                      });
                      Navigator.pop(context);
                    })),
          );
        });
        break;
    }
    drawerEntries.add(
      ListTile(
        title: Text('Favoriten'),
        onTap: () {
          _updateStateAndRefreshList(() {
            _onlyFavorites = true;
          });
          Navigator.pop(context);
        },
      ),
    );
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: drawerEntries,
      ),
    );
  }

  void _updateUpdateAvailable(bool isAvailable) {
    _updateStateAndRefreshList(() {
      _updateAvailable = isAvailable;
    });
  }

  void _updateCalendarEntries(List<CalendarEntry> calendar) {
    _updateStateAndRefreshList(() {
      _allEventsByDate = calendar;
      _updateAvailable = false;
    });
  }

  void _updateCalendarSettings(CalendarSorting sorting, CalendarDateFormat dateFormat) {
    _updateStateAndRefreshList(() {
      _sorting = sorting;
      _dateFormat = dateFormat;
    });
  }

  void _updateStateAndRefreshList(Function() runnable) {
    if (mounted)
      setState(() {
        runnable.call();
        _transferEventsToWidgets();
      });
    else {
      runnable.call();
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

  void _toggleFavoriteState(BuildContext context, CalendarEntry event) {
    final isNowFavorite = GetIt.instance.get<FavoritesService>().toggleFavorite(event.eventId);
    if (_onlyFavorites && !isNowFavorite && (_sorting == CalendarSorting.ALL_BY_DATE || _sorting == CalendarSorting.GROUP_BY_DATE)) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text((event.takesPlace ? "Veranstaltung \"" : "Abgesagte Veranstaltung \"") + event.name + "\" entfernt"),
        action: event.takesPlace
            ? SnackBarAction(
                label: "Rückgängig",
                onPressed: () {
                  GetIt.instance.get<FavoritesService>().toggleFavorite(event.eventId);
                })
            : null,
      ));
    }
  }

  void _transferEventsToWidgets() {
    CalendarListEntryWidget.isDebugModeActive = GetIt.instance.get<DebugSettings>().isDebugModeActive();
    final _favoritesService = GetIt.instance.get<FavoritesService>();
    FavoriteButton.initialize(_favoritesService, (context, event) {
      _toggleFavoriteState(context, event);
    });
    _displayedWidgets = List();
    if (_allEventsByDate == null || _allEventsByDate.isEmpty) return;
    final effSorting = _onlyFavorites ? CalendarSorting.ALL_BY_DATE : _sorting;
    final bool Function(CalendarEntry) filterByFavorites = _onlyFavorites ? (entry) => _favoritesService.isFavorite(entry.eventId) : (__) => true;
    switch (effSorting) {
      case CalendarSorting.EMPTY:
        break;
      case CalendarSorting.ALL_BY_DATE:
        DateTime lastDay;
        _allEventsByDate.where(filterByFavorites).forEach((eventEntry) {
          final DateTime currentDay = _getDate(eventEntry.start);
          if (lastDay == null || lastDay != currentDay) {
            _displayedWidgets.add(_createDateHeader(eventEntry.start));
            lastDay = currentDay;
          }
          _displayedWidgets.add(new CalendarListEntryWidget(eventEntry, _dateFormat));
        });
        if (_displayedWidgets.isEmpty && _onlyFavorites) {
          _displayedWidgets.add(Padding(
              padding: EdgeInsets.fromLTRB(0, 32, 0, 32),
              child: Center(
                  child: Text(
                "Keine Favoriten ausgewählt",
                style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 20),
              ))));
          _displayedWidgets.add(TextButton(
            onPressed: () => _updateStateAndRefreshList(() {
              _onlyFavorites = false;
            }),
            child: Center(child: Text("OK")),
          ));
        }
        break;
      case CalendarSorting.GROUP_BY_DATE:
        if (_selectedDate == null) {
          _selectedDate = _getDate(_allEventsByDate[0].start);
        }
        _displayedWidgets.add(_createDateHeader(_selectedDate));
        _allEventsByDate.where((eventEntry) => _getDate(eventEntry.start) == _selectedDate).forEach((eventEntry) {
          _displayedWidgets.add(new CalendarListEntryWidget(eventEntry, _dateFormat));
        });
        break;
      case CalendarSorting.GROUP_BY_TYPE:
        final Map<int, CalendarEntryGroup> entriesByType = Map();
        _allEventsByDate.forEach((eventEntry) {
          entriesByType.putIfAbsent(eventEntry.eventGroupId, () => CalendarEntryGroup()).entries.add(eventEntry);
        });
        final List<CalendarEntryGroup> groups = entriesByType.values.toList();
        groups.sort();
        groups.forEach((group) {
          _displayedWidgets.add(CalendarGroupListWidget(group));
        });
        break;
    }
  }

  Widget _createDateHeader(DateTime date) {
    return Padding(
      padding: EdgeInsets.fromLTRB(32, 32, 16, 16),
      child: Text(
        DateFormat(_dateFormat.subtitleFormat).format(date),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
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

  DateTime _getDate(DateTime dateTime) {
    return DateTime.parse(DateFormat("yyyyMMdd").format(dateTime));
  }
}
