import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_settings_service.dart';
import 'package:mensa_jt21/calendar/favorite_button.dart';
import 'package:mensa_jt21/screens/calendar_details_screen.dart';

class CalendarListEntryWidget extends StatelessWidget {
  static bool isDebugModeActive;

  final CalendarEntry calendarEntry;

  const CalendarListEntryWidget(this.calendarEntry);

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          textTheme: TextTheme(
            bodyText2: TextStyle(
              color: calendarEntry.abgesagt ? Colors.grey : Colors.black,
              decoration: calendarEntry.abgesagt ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        // additional Builder to transfer the Theme defined above
        child: Builder(builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: new FavoriteButton(calendarEntry),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalendarDetailsScreen(calendarEntry: calendarEntry),
                                ));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _getEntryElements(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ));
        }));
  }

  List<Widget> _getEntryElements(BuildContext context) {
    List<Widget> elements = List();
    if (isDebugModeActive) elements.add(Text(calendarEntry.eventId.toString() + " (" + calendarEntry.eventGroupId.toString() + ")"));
    elements.add(Text(
      calendarEntry.name,
      softWrap: true,
      style: Theme.of(context).textTheme.bodyText2.copyWith(
            fontWeight: FontWeight.bold,
          ),
    ));
    elements.add(StartTimeLine(calendarEntry));
    return elements;
  }
}

class StartTimeLine extends StatelessWidget {
  static CalendarDateFormat calendarDateFormat;

  final CalendarEntry _calendarEntry;

  const StartTimeLine(this._calendarEntry);

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat(calendarDateFormat.startTimeFormat).format(_calendarEntry.start),
      style: TextStyle(
        color: _calendarEntry.abgesagt ? Colors.grey : Colors.black,
        decoration: _calendarEntry.abgesagt ? TextDecoration.lineThrough : null,
      ),
    );
  }
}

class TitleAndElement extends StatelessWidget {
  final String title;
  final Widget value;

  const TitleAndElement({Key key, this.title, this.value}) : super(key: key);

  static void addIfNotNull(List<Widget> entries, String title, String value) {
    if (value != null && value.isNotEmpty) entries.add(TitleAndElement(title: title, value: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title + ": ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }
}

class CalendarEntryGroup implements Comparable<CalendarEntryGroup> {
  final List<CalendarEntry> entries = List();
  bool isAllCancelled = false;
  bool _needsCalculation = true;

  void calculate() {
    if (_needsCalculation) {
      _needsCalculation = false;
      isAllCancelled = !entries.any((entry) => entry.takesPlace);
    }
  }

  @override
  int compareTo(CalendarEntryGroup other) {
    return entries[0].name.compareTo(other.entries[0].name);
  }
}

class CalendarGroupListWidget extends StatelessWidget {
  final CalendarEntryGroup group;

  const CalendarGroupListWidget(this.group);

  @override
  Widget build(BuildContext context) {
    group.calculate();
    final CalendarEntry calendarEntry = group.entries[0];
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getEntries(context, calendarEntry),
      ),
    );
  }

  List<Widget> _getEntries(BuildContext context, CalendarEntry calendarEntry) {
    final List<Widget> entries = List();
    entries.add(_getHeader(context, calendarEntry));
    group.entries.forEach((element) {
      entries.add(_getSingleDateEntry(context, element));
    });
    return entries;
  }

  Widget _getHeader(BuildContext context, CalendarEntry calendarEntry) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: TextTheme(
          bodyText2: TextStyle(
            color: group.isAllCancelled ? Colors.grey : Colors.black,
            decoration: group.isAllCancelled ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
      // additional Builder to transfer the Theme defined above
      child: Builder(builder: (BuildContext context) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: _getHeaderEntries(context, calendarEntry));
      }),
    );
  }

  List<Widget> _getHeaderEntries(BuildContext context, CalendarEntry calendarEntry) {
    List<Widget> entries = List();
    entries.add(Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        calendarEntry.name,
        softWrap: true,
        style: Theme.of(context).textTheme.bodyText2.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
      ),
    ));
    entries.add(TitleAndElement(
      title: "Kategorie",
      value: Text(
        calendarEntry.kategorie,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    ));
    TitleAndElement.addIfNotNull(entries, "Anbieter", calendarEntry.anbieter);
    if (calendarEntry.dauer != null) {
      entries.add(TitleAndElement(title: "Dauer", value: Text(calendarEntry.dauer.toString() + " Minuten")));
    }
    TitleAndElement.addIfNotNull(entries, "Barrierefreiheit", calendarEntry.barrierefreiheit);
    return entries;
  }

  Widget _getSingleDateEntry(BuildContext context, CalendarEntry entry) {
    return Row(children: [
      FavoriteButton(entry),
      GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CalendarDetailsScreen(calendarEntry: entry),
              ));
        },
        child: StartTimeLine(entry),
      ),
    ]);
  }
}
