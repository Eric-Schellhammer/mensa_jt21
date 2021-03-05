import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mensa_jt21/calendar/calendar_group_entry.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_widgets.dart';
import 'package:mensa_jt21/calendar/favorites_service.dart';
import 'package:mensa_jt21/online/online_service.dart';

class CalendarDetailsScreen extends StatefulWidget {
  final CalendarEntry calendarEntry;
  final CalendarEntryGroup calendarEntryGroup;

  const CalendarDetailsScreen({Key key, this.calendarEntry, this.calendarEntryGroup}) : super(key: key);

  @override
  createState() => CalendarDetailsScreenState();
}

enum _GroupMode { SINGLE, SELECTED, ALL }

class CalendarDetailsScreenState extends State<CalendarDetailsScreen> {
  CalendarEntry get calendarEntry {
    return widget.calendarEntry != null ? widget.calendarEntry : widget.calendarEntryGroup.entries[0];
  }

  CalendarEntryGroup get calendarEntryGroup {
    return widget.calendarEntryGroup;
  }

  bool loadImages = false;
  _GroupMode _groupMode;

  @override
  void initState() {
    super.initState();
    final favoriteService = GetIt.instance.get<FavoritesService>();
    FavoriteButton.initialize(favoriteService, (context, calendarEntry) {
      favoriteService.toggleFavorite(calendarEntry.eventId);
      if (mounted) setState(() {});
    });
    loadImages = GetIt.instance.get<OnlineService>().getOnlineModeOnce() == OnlineMode.ONLINE;
    if (calendarEntryGroup == null || calendarEntryGroup.entries.length == 1)
      _groupMode = _GroupMode.SINGLE;
    else {
      _groupMode = widget.calendarEntry != null ? _GroupMode.SELECTED : _GroupMode.ALL;
    }
  }

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
    switch (_groupMode) {
      case _GroupMode.SINGLE:
        _addSingleEventEntries(entries);
        break;
      case _GroupMode.SELECTED:
        _addSelectedEventEntries(entries);
        break;
      case _GroupMode.ALL:
        _addEventGroupEntries(entries);
        break;
    }
    return entries;
  }

  List<Widget> _addSingleEventEntries(List<Widget> entries) {
    entries.add(Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text("Einmalige Veranstaltung:"),
    ));
    entries.add(StartTimeLine(calendarEntry));
    if (calendarEntry.abgesagt) entries.add(_subtitleCancelled("Veranstaltung wurde abgesagt!"));
    _addDescription(entries);
    entries.add(_subsectionTitle("Weitere Informationen"));
    entries.add(_getShortForDate(entry: calendarEntry));
    entries.addAll(_getSingleGeneral(calendarEntry));
    return entries;
  }

  List<Widget> _addSelectedEventEntries(List<Widget> entries) {
    entries.add(Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text("Ausgewählter Termin:"),
    ));
    entries.add(StartTimeLine(calendarEntry));
    if (calendarEntry.abgesagt) {
      if (calendarEntryGroup.isAllCancelled)
        entries.add(_subtitleCancelled("Veranstaltungsreihe wurde komplett abgesagt!"));
      else
        entries.add(_subtitleCancelled("Ausgewählter Termin wurde abgesagt."));
    }
    _addDescription(entries);
    entries.add(_subsectionTitle("Allgemeine Informationen"));
    entries.addAll(_getSingleGeneral(calendarEntry));
    entries.add(_subsectionTitle("Terminspezifische Informationen"));
    entries.add(_getShortForDate(entry: calendarEntry));
    entries.add(_subsectionTitle("Weitere Termine"));
    calendarEntryGroup.entries.where((entry) => entry.eventId != calendarEntry.eventId).forEach((entry) {
      entries.add(_getShortForDate(entry: entry, withNavigation: true));
    });
    return entries;
  }

  List<Widget> _addEventGroupEntries(List<Widget> entries) {
    if (calendarEntryGroup.isAllCancelled) entries.add(_subtitleCancelled("Veranstaltungsreihe wurde komplett abgesagt!"));
    _addDescription(entries);
    List<PropertySelector> commonSelectors = List();
    List<PropertySelector> specificSelectors = List();
    _getSelectors().forEach((selector) {
      if (calendarEntryGroup.entries.any((element) => !selector.areEqual(calendarEntry, element)))
        specificSelectors.add(selector);
      else
        commonSelectors.add(selector);
    });
    entries.add(_subsectionTitle("Allgemeine Informationen"));
    commonSelectors.forEach((selector) {
      selector.addWidget(entries, calendarEntry);
    });
    entries.add(_subsectionTitle("Terminspezifische Informationen"));
    calendarEntryGroup.entries.forEach((entry) {
      entries.add(_getShortForDate(entry: entry, selectors: specificSelectors, withNavigation: true));
    });
    return entries;
  }

  Widget _subtitleCancelled(String text) {
    return Padding(
        padding: EdgeInsets.only(top: 8),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 20).copyWith(color: Colors.red),
            ),
          ],
        ));
  }

  void _addDescription(List<Widget> entries) {
    if (loadImages && calendarEntry.bild != null)
      entries.add(
        Html(
            data:
                "<img src=\"https://event-orga.mensa.de/getImage.php?h=300&jt=jt2020&name=" + calendarEntry.bild + "\" alt=\"" + calendarEntry.bildtitel + "\" class=\"center\">"),
      );
    entries.add(_subsectionTitle("Beschreibung"));
    entries.add(Html(
      data: calendarEntry.eventtext,
      blacklistedElements: loadImages ? [] : ["img"],
    ));
  }

  Widget _subsectionTitle(String title) {
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

  List<Widget> _getSingleGeneral(CalendarEntry entry) {
    List<Widget> entries = List();
    _getSelectors().forEach((element) {
      element.addWidget(entries, entry);
    });
    return entries;
  }

  Widget _getShortForDate({CalendarEntry entry, List<PropertySelector> selectors, bool withNavigation = false}) {
    final Widget lines = Column(children: _getSpecificEntries(entry, selectors));
    final Row row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FavoriteButton(entry),
        Expanded(
            child: withNavigation
                ? GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CalendarDetailsScreen(
                              calendarEntry: entry,
                              calendarEntryGroup: calendarEntryGroup,
                            ),
                          ));
                    },
                    child: lines,
                  )
                : lines),
      ],
    );
    return entry.takesPlace
        ? row
        : Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  "Veranstaltung wurde abgesagt!",
                  style: TextStyle(fontSize: 20).copyWith(color: Colors.red),
                ),
              ),
              row,
            ],
          );
  }

  List<Widget> _getSpecificEntries(CalendarEntry entry, List<PropertySelector> selectors) {
    final textStyle = CalendarEntryTextStyle(entry);
    List<Widget> entries = List();
    entries.add(Padding(
      padding: EdgeInsets.only(top: 8),
      child: TitleAndElement(
        title: "Start",
        value: StartTimeLine(entry),
        textStyle: textStyle,
      ),
    ));
    if (entry.abmarsch != null)
      entries.add(TitleAndElement(
        title: "Abmarsch",
        value: Text(
          DateFormat("HH:mm 'Uhr'").format(entry.abmarsch),
          style: textStyle,
        ),
        textStyle: textStyle,
      ));
    if (selectors != null)
      selectors.forEach((selector) {
        selector.addWidget(entries, entry);
      });
    return entries;
  }

  static List<PropertySelector> _listOfSelectors;

  static List<PropertySelector> _getSelectors() {
    if (_listOfSelectors == null) {
      _listOfSelectors = List();
      _listOfSelectors.add(TextPropertySelector("Kategorie", (entry) => entry.kategorie));
      _listOfSelectors.add(TextPropertySelector("Anbieter", (entry) => entry.anbieter));
      _listOfSelectors.add(LengthSelector());
      _listOfSelectors.add(LocationSelector());
      _listOfSelectors.add(TextPropertySelector("Gebäude", (entry) => entry.gebaeude));
      _listOfSelectors.add(TextPropertySelector("Raum", (entry) => entry.raum));
      _listOfSelectors.add(TextPropertySelector("Wordpress", (entry) => entry.wordpress));
      _listOfSelectors.add(TextPropertySelector("Barrierefreiheit", (entry) => entry.barrierefreiheit));
      _listOfSelectors.add(TextPropertySelector("Haltestelle", (entry) => entry.haltestelle));
      _listOfSelectors.add(CoordinatesSelector());
    }
    return _listOfSelectors;
  }
}

// TODO sort names entry/element/entries/calendarEntry

abstract class PropertySelector {
  bool areEqual(CalendarEntry e1, CalendarEntry e2);

  void addWidget(List<Widget> entries, CalendarEntry entry);
}

abstract class SinglePropertySelector extends PropertySelector {
  final Function(CalendarEntry) selector;

  SinglePropertySelector(this.selector);

  @override
  bool areEqual(CalendarEntry e1, CalendarEntry e2) {
    final val1 = selector.call(e1);
    final val2 = selector.call(e2);
    if (val1 == null)
      return val2 == null;
    else
      return val1 == val2;
  }
}

class TextPropertySelector extends SinglePropertySelector {
  final String name;

  TextPropertySelector(this.name, String Function(CalendarEntry) selector) : super(selector);

  @override
  void addWidget(List<Widget> entries, CalendarEntry entry) {
    return TitleAndElement.addIfNotNull(entries, name, selector.call(entry)); // TODO set style
  }
}

class LengthSelector extends SinglePropertySelector {
  LengthSelector() : super((entry) => entry.dauer);

  @override
  void addWidget(List<Widget> entries, CalendarEntry entry) {
    entries.add(TitleAndElement(title: "Dauer", value: Text(entry.dauer.toString() + " Minuten"))); // TODO set style
  }
}

class CoordinatesSelector extends PropertySelector {
  @override
  void addWidget(List<Widget> entries, CalendarEntry entry) {
    if (entry.lat != null && double.parse(entry.lat) != 0)
      entries.add(TitleAndElement(
        title: "Koordinaten",
        value: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Column(children: [Text("N" + entry.lat + "°"), Text("E" + entry.lon + "°")]),
          IconButton(
            padding: EdgeInsets.only(left: 18),
            constraints: BoxConstraints(),
            icon: Icon(Icons.map),
            onPressed: () => _openMap(entry.lat, entry.lon),
          ),
        ]),
      ));
  }

  @override
  bool areEqual(CalendarEntry e1, CalendarEntry e2) {
    return (e1.lat == e2.lat && e1.lon == e2.lon);
  }

  void _openMap(String lat, String lon) {
    //final String url = "https://www.google.com/maps/dir/?api=1&origin=" + origin + "&destination=" + destination + "&travelmode=driving&dir_action=navigate";
    final String url = "https://www.google.com/maps/dir/?api=1&destination=" + lat + "," + lon;
    if (Platform.isAndroid) {
      final AndroidIntent intent = new AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull(url),
        package: 'com.google.android.apps.maps',
      );
      intent.launch();
    }
    // else { // TODO add iOS support
    //   String url = "https://www.google.com/maps/dir/?api=1&origin=" + origin + "&destination=" + destination + "&travelmode=driving&dir_action=navigate";
    //   if (await canLaunch(url)) {
    // await launch(url);
    // } else {
    // throw 'Could not launch $url';
    // }
  }
}

class LocationSelector extends PropertySelector {
  @override
  void addWidget(List<Widget> entries, CalendarEntry entry) {
    entries.add(TitleAndElement(
      title: "Ort",
      value: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.location ?? ""),
          Text(entry.strasse ?? ""),
          Text((entry.plz ?? "") + " " + (entry.ortsname ?? "")),
        ],
      ),
    ));
  }

  @override
  bool areEqual(CalendarEntry e1, CalendarEntry e2) {
    return (e1.location == e2.location) && (e1.strasse == e2.strasse) && (e1.plz == e2.plz) && (e1.ortsname == e2.ortsname);
  }
}
