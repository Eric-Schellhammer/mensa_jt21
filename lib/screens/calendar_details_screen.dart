import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_widgets.dart';

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
    TitleAndElement.addIfNotNull(entries, "Kategorie", calendarEntry.kategorie);
    TitleAndElement.addIfNotNull(entries, "Anbieter", calendarEntry.anbieter);
    if (calendarEntry.dauer != null) {
      entries.add(TitleAndElement(title: "Dauer", value: Text(calendarEntry.dauer.toString() + " Minuten")));
    }
    entries.add(TitleAndElement(
      title: "Ort",
      value: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(calendarEntry.location ?? ""),
          Text(calendarEntry.strasse ?? ""),
          Text((calendarEntry.plz ?? "") + " " + (calendarEntry.ortsname ?? "")),
        ],
      ),
    ));
    TitleAndElement.addIfNotNull(entries, "Gebäude", calendarEntry.gebaeude);
    TitleAndElement.addIfNotNull(entries, "Raum", calendarEntry.raum);
    TitleAndElement.addIfNotNull(entries, "Wordpress", calendarEntry.wordpress);
    TitleAndElement.addIfNotNull(entries, "Barrierefreiheit", calendarEntry.barrierefreiheit);
    TitleAndElement.addIfNotNull(entries, "Haltestelle", calendarEntry.haltestelle);
    if (calendarEntry.lat != null && double.parse(calendarEntry.lat) != 0)
      entries.add(TitleAndElement(title: "Koordinaten", value: Text("N" + calendarEntry.lat + "° E" + calendarEntry.lon + "°")));
    return entries;
  }

  List<Widget> _getSpecific() {
    List<Widget> entries = List();
    entries.add(TitleAndElement(title: "Start", value: StartTimeLine(calendarEntry)));
    if (calendarEntry.abgesagt)
      entries.add(Text(
        "Veranstaltung wurde abgesagt!",
        style: TextStyle(fontSize: 20).copyWith(color: Colors.red),
      ));
    entries.add(TitleAndElement(title: "Abmarsch", value: Text(DateFormat("HH:mm 'Uhr'").format(calendarEntry.abmarsch))));
    return entries;
  }
}
