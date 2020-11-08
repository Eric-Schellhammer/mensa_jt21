import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_settings_service.dart';

class CalendarDetailsScreen extends StatelessWidget {
  final CalendarEntry calendarEntry;

  const CalendarDetailsScreen({Key key, this.calendarEntry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(calendarEntry.name),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: ListView(
          children: _getEntries(),
        ),
      ),
    );
  }

  List<Widget> _getEntries() {
    List<Widget> entries = List();
    entries.add(Text(
      calendarEntry.name,
      softWrap: true,
      style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 20),
    ));
    entries.add(_subtitle("Beschreibung"));
    entries.add(Html(
      data: calendarEntry.eventtext,
    ));
    entries.add(_subtitle("Allgemeine Informationen"));
    entries.addAll(_getGeneral());
    entries.add(_subtitle("Terminspezifische Informationen"));
    entries.addAll(_getSpecific());
    return entries;
  }

  Widget _subtitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Container(
        color: Colors.amberAccent,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 18),
          ),
        ),
      ),
    );
  }

  List<Widget> _getGeneral() {
    List<Widget> entries = List();
    entries.add(Text("Kategorie: " + calendarEntry.kategorie));
    entries.add(Text("Anbieter: " + calendarEntry.anbieter));
    entries.add(Text("Dauer: " + calendarEntry.dauer));
    entries.add(Text("Location: " + calendarEntry.location));
    entries.add(Text("Strasse: " + calendarEntry.strasse));
    entries.add(Text("PLZ: " + calendarEntry.plz));
    entries.add(Text("Ortsname: " + calendarEntry.ortsname));
    entries.add(Text("Gebäude: " + calendarEntry.gebaeude));
    entries.add(Text("Raum: " + calendarEntry.raum));
    entries.add(Text("LAT: " + calendarEntry.lat));
    entries.add(Text("LON: " + calendarEntry.lon));
    entries.add(Text("Wordpress: " + calendarEntry.wordpress));
    entries.add(Text("Barrierefreiheit: " + calendarEntry.barrierefreiheit));
    entries.add(Text("Haltestelle: " + calendarEntry.haltestelle));
    return entries;
  }

  List<Widget> _getSpecific() {
    final CalendarDateFormat calendarDateFormat = GetIt.instance.get<CalendarSettingsService>().getDateFormatOnce();
    List<Widget> entries = List();
    entries.add(Text(
      DateFormat(calendarDateFormat.startTimeFormat).format(calendarEntry.start),
    ));
    if (calendarEntry.abgesagt)
      entries.add(Text(
        "Veranstaltung wurde abgesagt!",
        style: TextStyle(fontSize: 20).copyWith(color: Colors.red),
      ));
    entries.add(Text("Abmarsch: " + calendarEntry.abmarsch));
    return entries;
  }
}
