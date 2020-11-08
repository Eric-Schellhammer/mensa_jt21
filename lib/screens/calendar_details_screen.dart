import 'package:flutter/cupertino.dart';
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
    _addIfNotNull(entries, "Kategorie", calendarEntry.kategorie);
    _addIfNotNull(entries, "Anbieter", calendarEntry.anbieter);
    if (calendarEntry.dauer != null) {
      entries.add(_getTitleAndElement("Dauer", Text(calendarEntry.dauer.toString() + " Minuten")));
    }
    entries.add(_getTitleAndElement(
      "Ort",
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(calendarEntry.location ?? ""),
            Text(calendarEntry.strasse ?? ""),
            Text((calendarEntry.plz ?? "") + " " + (calendarEntry.ortsname ?? "")),
          ],
        ),
      ),
    ));
    _addIfNotNull(entries, "Gebäude", calendarEntry.gebaeude);
    _addIfNotNull(entries, "Raum", calendarEntry.raum);
    _addIfNotNull(entries, "Wordpress", calendarEntry.wordpress);
    _addIfNotNull(entries, "Barrierefreiheit", calendarEntry.barrierefreiheit);
    _addIfNotNull(entries, "Haltestelle", calendarEntry.haltestelle);
    if (calendarEntry.lat != null && double.parse(calendarEntry.lat) != 0)
      entries.add(_getTitleAndElement("Koordinaten", Text("N" + calendarEntry.lat + "° E" + calendarEntry.lon + "°")));
    return entries;
  }

  void _addIfNotNull(List<Widget> entries, String title, String value) {
    if (value != null && value.isNotEmpty)
      entries.add(
        _getTitleAndElement(title, Expanded(child: Text(value))),
      );
  }

  Widget _getTitleAndElement(String title, Widget value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title + ": ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        value,
      ],
    );
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
