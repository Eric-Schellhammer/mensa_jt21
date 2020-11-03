import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mensa_jt21/calendar/calendar_settings_service.dart';
import 'package:mensa_jt21/online/online_service.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = "/settings";

  @override
  createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  OnlineMode _selectedOnlineMode;
  CalendarSorting _selectedCalendarSorting;
  CalendarDateFormat _selectedDateFormat;

  @override
  void initState() {
    super.initState();
    GetIt.instance.get<OnlineService>().registerModeListener((mode) {
      if (mounted)
        setState(() {
          _selectedOnlineMode = mode;
        });
      else
        _selectedOnlineMode = mode;
    });
    GetIt.instance.get<CalendarSettingsService>().registerListener((sorting, dateFormat) {
      if (mounted)
        setState(() {
          _selectedCalendarSorting = sorting;
          _selectedDateFormat = dateFormat;
        });
      else {
        _selectedCalendarSorting = sorting;
        _selectedDateFormat = dateFormat;
      }
    });
    // TODO remove listeners
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Einstellungen"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              "Haupteinstellungen:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Row(children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text("Online Modus:"),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 16, 0),
              child: DropdownButton<OnlineMode>(
                value: _selectedOnlineMode,
                items: [
                  DropdownMenuItem<OnlineMode>(
                    value: OnlineMode.OFFLINE,
                    child: Text("Offline"),
                  ),
                  DropdownMenuItem<OnlineMode>(
                    value: OnlineMode.MANUAL,
                    child: Text("Manuell"),
                  ),
                  DropdownMenuItem<OnlineMode>(
                    value: OnlineMode.ON_DEMAND,
                    child: Text("Manuell / Automatisch"),
                  ),
                  DropdownMenuItem<OnlineMode>(
                    value: OnlineMode.AUTOMATIC,
                    child: Text("Automatisch / Manuell"),
                  ),
                  DropdownMenuItem<OnlineMode>(
                    value: OnlineMode.ONLINE,
                    child: Text("Automatisch"),
                  ),
                ],
                onChanged: (mode) {
                  GetIt.instance.get<OnlineService>().setOnlineMode(mode);
                },
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              GetIt.instance.get<OnlineService>().getDescription(_selectedOnlineMode),
              softWrap: true,
              maxLines: 10,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Text(
              "Veranstaltungskalender:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text("Gruppierung:"),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 8, 16, 0),
                  child: DropdownButton<CalendarSorting>(
                    value: _selectedCalendarSorting,
                    items: [
                      DropdownMenuItem<CalendarSorting>(
                        value: CalendarSorting.ALL_BY_DATE,
                        child: Text("alles, nach Datum sortiert"),
                      ),
                      DropdownMenuItem<CalendarSorting>(
                        value: CalendarSorting.GROUP_BY_DATE,
                        child: Text("jeder Tag einzeln"),
                      ),
                      DropdownMenuItem<CalendarSorting>(
                        value: CalendarSorting.GROUP_BY_TYPE,
                        child: Text("zusammengefasst"),
                      ),
                    ],
                    onChanged: (sorting) {
                      GetIt.instance.get<CalendarSettingsService>().setSorting(sorting);
                    },
                  )),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text("Datumsformat:"),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 4, 16, 0),
                  child: DropdownButton<CalendarDateFormat>(
                    value: _selectedDateFormat,
                    items: [
                      DropdownMenuItem<CalendarDateFormat>(
                        value: CalendarDateFormat.WEEKDAY_AND_DATE,
                        child: Text("Wochentag, Datum"),
                      ),
                      DropdownMenuItem<CalendarDateFormat>(
                        value: CalendarDateFormat.WEEKDAY,
                        child: Text("nur Wochentag"),
                      ),
                      DropdownMenuItem<CalendarDateFormat>(
                        value: CalendarDateFormat.DATE,
                        child: Text("nur Datum"),
                      ),
                    ],
                    onChanged: (dateFormat) {
                      GetIt.instance.get<CalendarSettingsService>().setCalendarDateFormat(dateFormat);
                    },
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
