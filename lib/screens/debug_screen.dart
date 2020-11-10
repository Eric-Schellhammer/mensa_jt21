import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_settings_service.dart';
import 'package:mensa_jt21/calendar/favorites_service.dart';
import 'package:mensa_jt21/initialize/debug_settings.dart';
import 'package:mensa_jt21/online/online_service.dart';

class DebugScreen extends StatefulWidget {
  static const routeName = "/debug_screen";

  @override
  createState() => DebugScreenState();
}

class DebugScreenState extends State<DebugScreen> {
  final DebugSettings debugSettings = GetIt.instance.get<DebugSettings>();
  final TextEditingController cancelEventController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    cancelEventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Debug"),
        ),
        body: Column(
          children: [
            Row(children: [
              Text("Simuliere: Veranstaltung nr "),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: cancelEventController,
                ),
              ),
              RaisedButton(
                  child: Text("absagen"),
                  onPressed: () {
                    setState(() {
                      _cancelEvent();
                      debugSettings.simulatedCalendarUpdate = "{\"date\":\"" + DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()) + "\"}";
                      GetIt.instance.get<OnlineService>().performAutomaticPollingIfActive();
                    });
                  }),
            ]),
            Text(debugSettings.simulatedCalendarUpdate ?? ""),
            RaisedButton(
              child: Text("Simulation zurücksetzen"),
              onPressed: debugSettings.simulatedCalendarUpdate == null
                  ? null
                  : () {
                      _resetSimulation();
                    },
            ),
            RaisedButton(
              child: Text("App auf initiale Installation zurücksetzen"),
              onPressed: () {
                GetIt.instance.get<DebugSettings>().activateDebugMode = false;
                GetIt.instance.get<OnlineService>().resetToInitial();
                GetIt.instance.get<FavoritesService>().resetToInitial();
                GetIt.instance.get<CalendarSettingsService>().resetToInitial();
                // add further resetting here
                _resetSimulation();
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              child: Text("Debug-Mode ausschalten"),
              onPressed: GetIt.instance.get<DebugSettings>().isDebugModeActive()
                  ? () {
                      setState(() {
                        GetIt.instance.get<DebugSettings>().activateDebugMode = false;
                        GetIt.instance.get<FavoritesService>().refreshList();
                      });
                    }
                  : null,
            ),
          ],
        ));
  }

  void _resetSimulation() {
    setState(() {
      debugSettings.simulatedCalendarUpdate = null;
      debugSettings.simulatedCalendar = null;
    });
    GetIt.instance.get<CalendarService>().loadDefaultCalendarFile();
  }

  void _cancelEvent() {
    final String eventId = cancelEventController.text;
    final String jsonString = GetIt.instance.get<CalendarService>().getRawCalendarJson();
    cancelEventController.clear();

    final jsonEntries = JsonDecoder().convert(jsonString);
    if (jsonEntries != null) {
      jsonEntries.forEach((jsonElement) {
        final Map<String, dynamic> json = jsonElement;
        if (json["t_ID"] == eventId) json["abgesagt"] = "1";
      });
    }
    debugSettings.simulatedCalendar = JsonEncoder().convert(jsonEntries);
  }
}
