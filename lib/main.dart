import 'package:flutter/material.dart';
import 'package:mensa_jt21/screens/debug_screen.dart';
import 'package:mensa_jt21/screens/settings_screen.dart';

import 'screens/calendar_list_screen.dart';
import 'initialize/application_config.dart';

void main() {
  final Application application = Application(child: MensaJT21());
  runApp(application);
}

class MensaJT21 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mensa JT21',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalendarListScreen(),
      routes: {
        SettingsScreen.routeName: (ctx) => SettingsScreen(),
        DebugScreen.routeName: (ctx) => DebugScreen(),
      },
    );
  }
}
