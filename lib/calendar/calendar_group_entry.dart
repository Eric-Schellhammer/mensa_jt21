import 'package:flutter/material.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_widgets.dart';
import 'package:mensa_jt21/screens/calendar_details_screen.dart';

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
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CalendarDetailsScreen(
                calendarEntryGroup: group,
              ),
            ));
      },
      child: Theme(
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
      ),
    );
  }

  List<Widget> _getHeaderEntries(BuildContext context, CalendarEntry calendarEntry) {
    final textStyle = Theme.of(context).textTheme.bodyText2;
    List<Widget> entries = List();
    entries.add(Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        calendarEntry.name,
        softWrap: true,
        style: textStyle.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ));
    TitleAndElement.addIfNotNullWithStyle(entries, "Kategorie", calendarEntry.kategorie, textStyle);
    TitleAndElement.addIfNotNullWithStyle(entries, "Anbieter", calendarEntry.anbieter, textStyle);
    if (calendarEntry.dauer != null) {
      entries.add(TitleAndElement(
        title: "Dauer",
        value: Text(
          calendarEntry.dauer.toString() + " Minuten",
          style: textStyle,
        ),
        textStyle: textStyle,
      ));
    }
    TitleAndElement.addIfNotNullWithStyle(entries, "Barrierefreiheit", calendarEntry.barrierefreiheit, textStyle);
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
                builder: (context) => CalendarDetailsScreen(
                  calendarEntry: entry,
                  calendarEntryGroup: group,
                ),
              ));
        },
        child: StartTimeLine(entry),
      ),
    ]);
  }
}
