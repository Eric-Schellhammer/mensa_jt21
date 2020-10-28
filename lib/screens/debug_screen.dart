import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/initialize/debug_settings.dart';

class DebugScreen extends StatefulWidget {
  static const routeName = "/debug_screen";

  @override
  createState() => DebugScreenState();
}

class DebugScreenState extends State<DebugScreen> {

  final DebugSettings debugSettings = GetIt.instance.get<DebugSettings>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Debug"),
        ),
        body: Column(
          children: [
            FlatButton(
                child: Text("Simuliere neue Version auf Server"),
                onPressed: () {
                  setState(() {
                    debugSettings.simulatedCalendarUpdate = "{\"date\":\"" + DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()) + "\"}";
                  });
                }),
            Text(debugSettings.simulatedCalendarUpdate ?? ""),
            FlatButton(
              child: Text("Simulation zurücksetzen"),
              onPressed: debugSettings.simulatedCalendarUpdate == null
                  ? null
                  : () {
                      GetIt.instance.get<CalendarService>().loadDefaultCalendarFile();
                      setState(() {
                        debugSettings.simulatedCalendarUpdate = null;
                      });
                    },
            )
          ],
        ));
  }
}
